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
            if ($tableName === 'equipment' && isset($row['id'])) {
                $charsText = $this->getEquipmentCharsText((int) $row['id']);
                if ($charsText !== '') {
                    $content .= "\nХарактеристики: " . $charsText;
                }
            }
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

    /**
     * Возвращает строку характеристик оборудования (ЦП, ОЗУ, диск, дата) для вставки в документ RAG.
     */
    private function getEquipmentCharsText(int $equipmentId): string
    {
        $db = Yii::$app->db;
        $idCol = 'equipment_id';
        try {
            $schema = $db->getTableSchema('part_char_values', true);
            if ($schema && !isset($schema->columns['equipment_id']) && isset($schema->columns['id_arm'])) {
                $idCol = 'id_arm';
            }
        } catch (\Throwable $e) {
            return '';
        }
        try {
            $rows = (new Query())
                ->select([
                    'part_name' => 'sp.name',
                    'char_name' => 'sc.name',
                    'value_text' => new \yii\db\Expression('COALESCE(pcv.value_text, pcv.value_num::text)'),
                ])
                ->from(['pcv' => 'part_char_values'])
                ->innerJoin(['sp' => 'spr_parts'], 'sp.id = pcv.part_id')
                ->innerJoin(['sc' => 'spr_chars'], 'sc.id = pcv.char_id')
                ->where(['pcv.' . $idCol => $equipmentId])
                ->all($db);
        } catch (\Throwable $e) {
            return '';
        }
        $parts = [];
        foreach ($rows as $row) {
            $part = trim((string) ($row['part_name'] ?? ''));
            $char = trim((string) ($row['char_name'] ?? ''));
            $val = trim((string) ($row['value_text'] ?? ''));
            if ($val === '') {
                continue;
            }
            $p = mb_strtolower($part, 'UTF-8');
            $c = mb_strtolower($char, 'UTF-8');
            if (($part === 'ЦП' && $char === 'Модель') || (($p === 'цп' || strpos($p, 'процессор') !== false || $p === 'cpu') && (strpos($c, 'модель') !== false || strpos($c, 'частота') !== false))) {
                $parts['cpu'] = ($parts['cpu'] ?? '') . ($parts['cpu'] !== '' ? ' ' : '') . $val;
            } elseif ($part === 'ОЗУ' && $char === 'Объём' || (($p === 'озу' || $p === 'ram') && strpos($c, 'объём') !== false)) {
                $parts['ram'] = $val;
            } elseif (strpos($p, 'диск') !== false || strpos($p, 'накопитель') !== false) {
                $parts['disk'] = ($parts['disk'] ?? '') . ($parts['disk'] !== '' ? ', ' : '') . $val;
            }
        }
        $out = [];
        if (!empty($parts['cpu'])) {
            $out[] = 'ЦП ' . trim($parts['cpu']);
        }
        if (!empty($parts['ram'])) {
            $out[] = 'ОЗУ ' . $parts['ram'];
        }
        if (!empty($parts['disk'])) {
            $out[] = 'Диск ' . $parts['disk'];
        }
        return implode('; ', $out);
    }
}
