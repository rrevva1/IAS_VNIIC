#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Поиск релевантных чанков в ChromaDB по запросу пользователя.
Вызов: python search_context.py <путь к query.json> <путь к каталогу ChromaDB>
Входной JSON: {"query": "текст запроса", "top_k": 5}
Вывод в stdout: JSON-массив [{"content": "...", "metadata": {...}, "relevance_score": float}, ...]
"""
import sys
import os
import ssl

os.environ["HF_HUB_SSL_VERIFY"] = "0"
ssl._create_default_https_context = ssl._create_unverified_context

import json


def main():
    if len(sys.argv) < 3:
        print("[]")
        sys.exit(1)

    query_file = os.path.abspath(sys.argv[1])
    persist_directory = os.path.abspath(sys.argv[2])

    if not os.path.isfile(query_file):
        print("[]")
        sys.exit(1)

    try:
        with open(query_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception:
        print("[]")
        sys.exit(1)

    query = data.get('query', '')
    top_k = int(data.get('top_k', 5))
    if not query or top_k < 1:
        print("[]")
        sys.exit(0)

    model_path = os.environ.get("RAG_EMBEDDING_MODEL_PATH", "").strip() or (sys.argv[3] if len(sys.argv) > 3 else "")
    if model_path and os.path.isdir(model_path):
        model_name = os.path.abspath(model_path)
    else:
        model_name = "intfloat/multilingual-e5-base"

    if not os.path.isdir(persist_directory):
        print("[]")
        sys.exit(1)

    try:
        import chromadb
        from chromadb.utils.embedding_functions import SentenceTransformerEmbeddingFunction
    except ImportError:
        print("[]")
        sys.exit(1)

    try:
        embedding_fn = SentenceTransformerEmbeddingFunction(
            model_name=model_name,
            device="cpu",
            normalize_embeddings=True,
        )
        client = chromadb.PersistentClient(path=persist_directory)
        collection = client.get_collection(
            name="ias_rag",
            embedding_function=embedding_fn,
        )
    except Exception:
        print("[]")
        sys.exit(1)

    try:
        results = collection.query(
            query_texts=[query],
            n_results=min(top_k, 100),
            include=["documents", "metadatas", "distances"],
        )
    except Exception:
        print("[]")
        sys.exit(1)

    out = []
    if results and results.get("documents") and results["documents"][0]:
        docs = results["documents"][0]
        metas = results.get("metadatas") or [[]]
        if metas:
            metas = metas[0]
        dists = results.get("distances") or [[]]
        if dists:
            dists = dists[0]
        for i, doc in enumerate(docs):
            meta = metas[i] if i < len(metas) else {}
            dist = dists[i] if i < len(dists) else 0.0
            out.append({
                "content": doc,
                "metadata": meta,
                "relevance_score": float(dist),
            })

    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    main()
