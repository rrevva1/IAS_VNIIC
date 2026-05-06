<?php

use yii\db\Migration;

/**
 * Создаёт 17 записей оборудования типа «Монитор» по данным из part_char_values (колонка «Монитор» в гриде).
 * Принцип: 1 запись equipment = 1 физический монитор (см. docs/sistema/УТОЧНЕНИЕ_УЧЕТ_МОНИТОРЫ_ИБП_МЦ04.md).
 *
 * Источники (equipment_id → кол-во мониторов, ответственный, локация, модель):
 * - 4: 1 шт, user 4, loc 2 — Samsung SyncMaster SA200
 * - 5: 1 шт, user 4, loc 2 — Samsung SyncMaster SA200
 * - 6: 1 шт, user 5, loc 2 — BENQ BL2201M
 * - 7: 1 шт, user 6, loc 2 — Nec MultiSync E222W
 * - 8: 1 шт, user 7, loc 3 — Philips 23.8" 241B8QJEB
 * - 9: 1 шт, user 8, loc 3 — Nec MultiSync E222W
 * - 10: 1 шт, user 9, loc 4 — Samsung S22C200
 * - 11: встроенный экран моноблока — отдельную запись не создаём
 * - 12: 2 шт, user 9, loc 4 — AOC 24P2Q (запись id=12 архивируется)
 * - 15: 1 шт, user 13, loc 5 — MB27V13FS51
 * - 16: 1 шт, user 14, loc 5 — BenQ BL2405
 * - 17: 1 шт, user 15, loc 5 — BenQ BL2405
 * - 18: 1 шт, user 16, loc 5 — MB27V13FS51
 * - 20: 1 шт, user 17, loc 5 — BENQ BL2405
 * - 21: 1 шт, user 18, loc 5 — BENQ GL2460
 * - 22: 2 шт, user 19, loc 6 — Philips 23.8" 241B8QJEB
 *
 * Инв. номера: МЦ.04-mon-001 … МЦ.04-mon-017 (синтетические для МЦ.04).
 */
class m260217_100000_seed_17_monitors extends Migration
{
    public function safeUp()
    {
        $table = 'equipment';
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

        $rows = [
            ['МЦ.04-mon-001', null, 'Samsung SyncMaster SA200', 1, 4, 2, null, 'Монитор', false, false],
            ['МЦ.04-mon-002', null, 'Samsung SyncMaster SA200', 1, 4, 2, null, 'Монитор', false, false],
            ['МЦ.04-mon-003', null, 'BENQ BL2201M', 1, 5, 2, null, 'Монитор', false, false],
            ['МЦ.04-mon-004', null, 'Nec MultiSync E222W', 1, 6, 2, null, 'Монитор', false, false],
            ['МЦ.04-mon-005', null, 'Philips 23.8" 241B8QJEB', 1, 7, 3, null, 'Монитор', false, false],
            ['МЦ.04-mon-006', null, 'Nec MultiSync E222W', 1, 8, 3, null, 'Монитор', false, false],
            ['МЦ.04-mon-007', null, 'Samsung S22C200', 1, 9, 4, null, 'Монитор', false, false],
            ['МЦ.04-mon-008', null, 'AOC 24P2Q', 1, 9, 4, null, 'Монитор', false, false],
            ['МЦ.04-mon-009', null, 'AOC 24P2Q', 1, 9, 4, null, 'Монитор', false, false],
            ['МЦ.04-mon-010', null, 'MB27V13FS51', 1, 13, 5, null, 'Монитор', false, false],
            ['МЦ.04-mon-011', null, 'BenQ BL2405', 1, 14, 5, null, 'Монитор', false, false],
            ['МЦ.04-mon-012', null, 'BenQ BL2405', 1, 15, 5, null, 'Монитор', false, false],
            ['МЦ.04-mon-013', null, 'MB27V13FS51', 1, 16, 5, null, 'Монитор', false, false],
            ['МЦ.04-mon-014', null, 'BENQ BL2405', 1, 17, 5, null, 'Монитор', false, false],
            ['МЦ.04-mon-015', null, 'BENQ GL2460', 1, 18, 5, null, 'Монитор', false, false],
            ['МЦ.04-mon-016', null, 'Philips 23.8" 241B8QJEB', 1, 19, 6, null, 'Монитор', false, false],
            ['МЦ.04-mon-017', null, 'Philips 23.8" 241B8QJEB', 1, 19, 6, null, 'Монитор', false, false],
        ];

        // 17 записей (встроенный экран моноблока eq 11 не создаём как отдельный актив)
        $this->batchInsert($table, $columns, $rows);

        // Архивируем старую запись id=12 (одна запись «2 AOC 24P2Q»), заменённую двумя активами МЦ.04-mon-008, МЦ.04-mon-009
        $this->update(
            $table,
            [
                'is_archived' => true,
                'archived_at' => date('Y-m-d H:i:sP'),
                'archive_reason' => 'Разнесение на отдельные записи: 1 актив = 1 запись (мониторы МЦ.04-mon-008, МЦ.04-mon-009)',
            ],
            ['id' => 12]
        );

        return true;
    }

    public function safeDown()
    {
        $this->delete('equipment', [
            'inventory_number' => [
                'МЦ.04-mon-001', 'МЦ.04-mon-002', 'МЦ.04-mon-003', 'МЦ.04-mon-004', 'МЦ.04-mon-005',
                'МЦ.04-mon-006', 'МЦ.04-mon-007', 'МЦ.04-mon-008', 'МЦ.04-mon-009', 'МЦ.04-mon-010',
                'МЦ.04-mon-011', 'МЦ.04-mon-012', 'МЦ.04-mon-013', 'МЦ.04-mon-014', 'МЦ.04-mon-015',
                'МЦ.04-mon-016', 'МЦ.04-mon-017',
            ],
        ]);
        $this->update('equipment', [
            'is_archived' => false,
            'archived_at' => null,
            'archive_reason' => null,
        ], ['id' => 12]);
        return true;
    }
}
