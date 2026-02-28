#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Построение векторной БД ChromaDB из JSON-документов, экспортированных из Yii2 (DatabaseExporter).
Вызов: python build_vector_db.py <путь к rag_docs.json> <путь к каталогу ChromaDB>
"""
import sys
import os
import ssl

# Отключение проверки SSL при загрузке модели с Hugging Face (корпоративный прокси)
os.environ["HF_HUB_SSL_VERIFY"] = "0"
ssl._create_default_https_context = ssl._create_unverified_context

import json
import uuid

def chunk_text(text, chunk_size=600, overlap=50):
    """Разбивает текст на чанки с перекрытием."""
    if len(text) <= chunk_size:
        return [text] if text.strip() else []
    chunks = []
    start = 0
    while start < len(text):
        end = start + chunk_size
        chunk = text[start:end]
        if end < len(text):
            last_sep = max(chunk.rfind('\n'), chunk.rfind('. '), chunk.rfind('; '))
            if last_sep > chunk_size // 2:
                end = start + last_sep + 1
                chunk = text[start:end]
        chunks.append(chunk.strip())
        start = end - overlap
        if start >= len(text):
            break
    return [c for c in chunks if c]


def main():
    if len(sys.argv) < 3:
        print("Usage: python build_vector_db.py <docs.json> <chroma_db_path>", file=sys.stderr)
        sys.exit(1)

    docs_path = os.path.abspath(sys.argv[1])
    persist_directory = os.path.abspath(sys.argv[2])
    model_path = os.environ.get("RAG_EMBEDDING_MODEL_PATH", "").strip() or (sys.argv[3] if len(sys.argv) > 3 else "")
    if model_path and os.path.isdir(model_path):
        model_name = os.path.abspath(model_path)
    else:
        model_name = "intfloat/multilingual-e5-base"

    if not os.path.isfile(docs_path):
        print(f"File not found: {docs_path}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(docs_path, 'r', encoding='utf-8') as f:
            docs_data = json.load(f)
    except Exception as e:
        print(f"JSON load error: {e}", file=sys.stderr)
        sys.exit(1)

    # Chunk documents
    all_chunks = []
    for doc in docs_data:
        content = doc.get('content', '')
        meta = doc.get('metadata', {})
        if not content or not content.strip():
            continue
        for i, chunk in enumerate(chunk_text(content)):
            all_chunks.append({
                'content': chunk,
                'metadata': dict(meta),
            })

    if not all_chunks:
        print("No chunks to index.", file=sys.stderr)
        sys.exit(1)

    try:
        import chromadb
        from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
    except ImportError as e:
        print(f"Import error. Install: pip install chromadb sentence-transformers. {e}", file=sys.stderr)
        sys.exit(1)

    embedding_fn = SentenceTransformerEmbeddingFunction(
        model_name=model_name,
        device="cpu",
        normalize_embeddings=True,
    )

    client = chromadb.PersistentClient(path=persist_directory)
    collection_name = "ias_rag"
    try:
        client.delete_collection(collection_name)
    except Exception:
        pass
    collection = client.create_collection(
        name=collection_name,
        embedding_function=embedding_fn,
        metadata={"description": "RAG index for IAS assistant"},
    )

    documents = [c['content'] for c in all_chunks]
    metadatas = []
    for c in all_chunks:
        m = c['metadata']
        for k, v in list(m.items()):
            if v is not None and not isinstance(v, (str, int, float, bool)):
                m[k] = str(v)
        metadatas.append(m)
    ids = [str(uuid.uuid4()) for _ in all_chunks]

    collection.add(documents=documents, metadatas=metadatas, ids=ids)

    print(f"Chunks: {len(all_chunks)}")
    print(f"Persist directory: {persist_directory}")
    print("Done.")


if __name__ == "__main__":
    main()
