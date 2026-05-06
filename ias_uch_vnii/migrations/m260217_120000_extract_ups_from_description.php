<?php

use yii\db\Migration;

/**
 * Извлекает ИБП из поля description (Другая техника) в отдельные записи equipment.
 * В загруженных данных в description указаны строки вида «ИБП <марка и модель>» (например «ИБП APC Back-UPS 650 ВА (BX650CI-RS)»).
 * Создаются записи с equipment_type = 'ИБП', name = текст после «ИБП » (марка и модель), тот же ответственный и локация.
 * Инв. номера: МЦ.04-ups-001 … (синтетические для МЦ.04). После извлечения description в исходных строках очищается.
 *
 * См. docs/sistema/УТОЧНЕНИЕ_УЧЕТ_МОНИТОРЫ_ИБП_МЦ04.md, docs/import_ou/РЕГЛАМЕНТ_ПАРСИНГА_ОУ_ТЕСТ.md (столбец Другая техника).
 */
class m260217_120000_extract_ups_from_description extends Migration
{
    public function safeUp()
    {
        $table = 'equipment';
        $rows = $this->db->createCommand(
            "SELECT id, description, responsible_user_id, location_id, status_id 
             FROM {{%equipment}} 
             WHERE description IS NOT NULL 
               AND TRIM(description) <> '' 
               AND description LIKE '%ИБП%'
               AND (is_archived IS NULL OR is_archived = false)
               AND (is_deleted IS NULL OR is_deleted = false)"
        )->queryAll();

        $toInsert = [];
        $idsToClear = [];
        $n = 0;

        foreach ($rows as $row) {
            $desc = trim($row['description']);
            // Извлекаем текст после первого вхождения «ИБП » (тип + пробел) — это марка и модель
            $name = preg_replace('/^.*?ИБП\s+/u', '', $desc);
            $name = trim($name);
            if ($name === '') {
                continue;
            }
            $n++;
            $invNum = 'МЦ.04-ups-' . str_pad((string) $n, 3, '0', STR_PAD_LEFT);
            $toInsert[] = [
                $invNum,
                null,
                $name,
                (int) $row['status_id'],
                (int) $row['responsible_user_id'],
                (int) $row['location_id'],
                null,
                'ИБП',
                false,
                false,
            ];
            $idsToClear[] = $row['id'];
        }

        if (empty($toInsert)) {
            return true;
        }

        $columns = [
            'inventory_number',
            'serial_number',
            'name',
            'status_id',
            'responsible_user_id',
            'location_id',
            'description',
            'equipment_type',
            'is_archived',
            'is_deleted',
        ];
        $this->batchInsert($table, $columns, $toInsert);

        // Очищаем description в исходных записях (ИБП перенесён в отдельные активы)
        $this->update(
            $table,
            ['description' => null],
            ['id' => $idsToClear]
        );

        return true;
    }

    public function safeDown()
    {
        // Удаляем записи с типом ИБП и синтетическими инв. номерами МЦ.04-ups-*
        $this->db->createCommand(
            "DELETE FROM {{%equipment}} WHERE equipment_type = 'ИБП' AND inventory_number LIKE 'МЦ.04-ups-%'"
        )->execute();
        // Восстановить description в исходных строках по данным нельзя однозначно без сохранения маппинга.
        return true;
    }
}
