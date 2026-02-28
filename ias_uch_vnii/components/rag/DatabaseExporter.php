<?php

namespace app\components\rag;

use Yii;
use yii\base\Component;
use yii\db\Query;

/**
 * Экспорт таблиц БД в текстовые документы для векторного RAG (ChromaDB).
 * Учитывает флаги is_archived, is_deleted, is_active по таблицам.
 */
class DatabaseExporter extends Component
{
    /** Максимальная длина значения поля в тексте (символов) */
    private const MAX_FIELD_LENGTH = 800;

    /**
     * Экспорт указанных таблиц в массив документов.
     *
     * @param array $tables Список имён таблиц; пусто — из params['rag_tables']
     * @return array<int, array{content: string, metadata: array{table: string, id: mixed, source: string}}>
     */
    public function exportTablesToDocuments(array $tables = []): array
    {
        $params = Yii::$app->params;
        if (empty($tables)) {
            $tables = $params['rag_tables'] ?? ['tasks', 'equipment', 'locations', 'users'];
        }
        $limitPerTable = (int) ($params['rag_limit_per_table'] ?? 1000);

        $documents = [];
        foreach ($tables as $table) {
            $table = (string) $table;
            if ($table === '') {
                continue;
            }
            $documents = array_merge(
                $documents,
                $this->exportTable($table, $limitPerTable)
            );
        }

        return $documents;
    }

    /**
     * Экспорт одной таблицы с учётом фильтров по флагам.
     *
     * @return array<int, array{content: string, metadata: array{table: string, id: mixed, source: string}}>
     */
    private function exportTable(string $tableName, int $limit): array
    {
        $db = Yii::$app->db;
        $schema = $db->getSchema()->getTableSchema($tableName);
        if ($schema === null) {
            Yii::warning("RAG DatabaseExporter: table {$tableName} not found.", __METHOD__);
            return [];
        }

        $columnNames = array_keys($schema->columns);
        $query = (new Query())
            ->from($tableName)
            ->limit($limit);
        $this->applyTableFilters($query, $tableName, $schema);
        $rows = $query->all($db);

        $documents = [];
        foreach ($rows as $row) {
            $content = $this->formatRowAsText($tableName, $columnNames, $row, $schema);
            if ($content === '') {
                continue;
            }
            $id = $row['id'] ?? null;
            $documents[] = [
                'content' => $content,
                'metadata' => [
                    'table' => $tableName,
                    'id' => $id,
                    'source' => 'database_dump',
                ],
            ];
        }

        return $documents;
    }

    /**
     * Добавляет условия WHERE по флагам таблицы (архив, удаление, активность).
     */
    private function applyTableFilters(Query $query, string $tableName, \yii\db\TableSchema $schema): void
    {
        $columns = $schema->columns;
        if (isset($columns['is_archived'])) {
            $query->andWhere(['is_archived' => false]);
        }
        if (isset($columns['is_deleted'])) {
            $query->andWhere(['is_deleted' => false]);
        }
        if ($tableName === 'users' && isset($columns['is_active'])) {
            $query->andWhere(['is_active' => true]);
        }
    }

    /**
     * Форматирует строку таблицы в текст для индексации.
     * Пропускает бинарные и слишком длинные значения.
     */
    private function formatRowAsText(string $table, array $columns, array $row, \yii\db\TableSchema $schema): string
    {
        $lines = ["Запись из таблицы «{$table}»:"];

        foreach ($columns as $column) {
            if (!array_key_exists($column, $row)) {
                continue;
            }
            $value = $row[$column];
            if ($value === null || $value === '') {
                continue;
            }

            $columnSchema = $schema->columns[$column] ?? null;
            if ($columnSchema !== null) {
                $type = $columnSchema->type;
                if (in_array(strtolower($type), ['binary', 'blob', 'mediumblob', 'longblob'], true)) {
                    continue;
                }
            }

            if (!is_scalar($value)) {
                continue;
            }
            $value = (string) $value;
            if (strlen($value) > self::MAX_FIELD_LENGTH) {
                $value = mb_substr($value, 0, self::MAX_FIELD_LENGTH) . '…';
            }
            $lines[] = "- {$column}: {$value}";
        }

        $text = implode("\n", $lines);
        return $text;
    }
}
