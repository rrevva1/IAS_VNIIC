<?php

namespace app\components;

/**
 * Версионирование данных для фонового обновления интерфейса без перезагрузки страницы.
 */
class RealtimeSyncService
{
    /**
     * @param string[] $fingerprints Строки вида «id:метка_изменения».
     */
    public static function hashFingerprints(array $fingerprints): string
    {
        $normalized = array_values(array_filter(array_map('strval', $fingerprints), static fn(string $v): bool => $v !== ''));
        sort($normalized, SORT_STRING);

        return hash('sha256', implode("\n", $normalized));
    }
}
