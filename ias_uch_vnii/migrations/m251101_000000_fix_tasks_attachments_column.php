<?php

use yii\db\Migration;

/**
 * Исправляет тип колонки attachments в таблице tasks
 * Меняет с integer[] на text для корректного хранения JSON
 */
class m251101_000000_fix_tasks_attachments_column extends Migration
{
    /**
     * {@inheritdoc}
     */
    public function safeUp()
    {
        echo "Изменение типа колонки attachments...\n";
        
        // 1. Сохраняем текущие данные во временной колонке
        $this->addColumn('tasks', 'attachments_temp', $this->text());
        
        // 2. Копируем данные, конвертируя PostgreSQL массивы в JSON
        $this->execute("
            UPDATE tasks 
            SET attachments_temp = 
                CASE 
                    WHEN attachments IS NULL THEN '[]'
                    WHEN attachments = '{}' THEN '[]'
                    ELSE 
                        '[' || array_to_string(attachments, ',') || ']'
                END
        ");
        
        // 3. Удаляем старую колонку
        $this->dropColumn('tasks', 'attachments');
        
        // 4. Переименовываем временную колонку
        $this->renameColumn('tasks', 'attachments_temp', 'attachments');
        
        echo "Тип колонки успешно изменен с integer[] на text (JSON)\n";
    }

    /**
     * {@inheritdoc}
     */
    public function safeDown()
    {
        echo "Откат изменения типа колонки attachments...\n";
        
        // 1. Создаем временную колонку с типом integer[]
        $this->execute("ALTER TABLE tasks ADD COLUMN attachments_temp integer[]");
        
        // 2. Копируем данные, конвертируя JSON в PostgreSQL массивы
        $this->execute("
            UPDATE tasks 
            SET attachments_temp = 
                CASE 
                    WHEN attachments IS NULL OR attachments = '' OR attachments = '[]' THEN '{}'::integer[]
                    ELSE 
                        -- Преобразуем JSON массив в PostgreSQL массив
                        (SELECT array_agg(value::integer) 
                         FROM json_array_elements_text(attachments::json) 
                         WHERE value::text ~ '^[0-9]+$')
                END
        ");
        
        // 3. Удаляем колонку text
        $this->dropColumn('tasks', 'attachments');
        
        // 4. Переименовываем временную колонку
        $this->renameColumn('tasks', 'attachments_temp', 'attachments');
        
        echo "Тип колонки возвращен к integer[]\n";
    }
}

