<?php

namespace app\components;

use app\models\entities\PhoneDirectory;
use app\models\entities\Users;
use Yii;

/**
 * Внутренние телефонные номера предприятия.
 *
 * Формат: X-XX, серии 4…8, суффикс 01…99 (например 4-15, 8-03).
 * Жёсткая уникальность не требуется — допускается несколько человек на одном номере;
 * в UI показывается предупреждение о занятости.
 */
class InternalPhoneHelper
{
    public const EMPTY_LABEL = 'Не указан';

    /** Серии внутренних номеров. */
    public const SERIES = [4, 5, 6, 7, 8];

    /**
     * Проверка канонического формата X-XX (серии 4–8, 01–99).
     */
    public static function isValid(?string $phone): bool
    {
        if ($phone === null || $phone === '') {
            return true;
        }

        return (bool) preg_match('/^[4-8]-(0[1-9]|[1-9][0-9])$/', $phone);
    }

    /**
     * Нормализация: пустая строка → null; обрезка пробелов.
     */
    public static function normalize(?string $phone): ?string
    {
        if ($phone === null) {
            return null;
        }
        $phone = trim($phone);
        if ($phone === '') {
            return null;
        }

        // Допускаем ввод без дефиса: 415 → 4-15, 803 → 8-03
        if (preg_match('/^([4-8])(\d{2})$/', $phone, $m)) {
            $suffix = (int) $m[2];
            if ($suffix >= 1 && $suffix <= 99) {
                return $m[1] . '-' . str_pad((string) $suffix, 2, '0', STR_PAD_LEFT);
            }
        }

        return $phone;
    }

    /**
     * Полный список номеров диапазона (без учёта занятости).
     *
     * @return string[]
     */
    public static function allNumbers(): array
    {
        $list = [];
        foreach (self::SERIES as $series) {
            for ($n = 1; $n <= 99; $n++) {
                $list[] = $series . '-' . str_pad((string) $n, 2, '0', STR_PAD_LEFT);
            }
        }

        return $list;
    }

    /**
     * Карта занятости: номер → список подписей держателей.
     *
     * @return array<string, string[]>
     */
    public static function occupancyMap(
        ?int $excludeUserId = null,
        ?int $excludeDirectoryId = null
    ): array {
        $map = [];

        try {
            $dirQuery = PhoneDirectory::find()
                ->select(['id', 'full_name', 'internal_phone', 'user_id', 'entry_type'])
                ->where(['is_published' => true])
                ->andWhere(['not', ['internal_phone' => null]])
                ->andWhere(['<>', 'internal_phone', '']);

            if ($excludeDirectoryId !== null) {
                $dirQuery->andWhere(['<>', 'id', $excludeDirectoryId]);
            }

            foreach ($dirQuery->asArray()->all() as $row) {
                $phone = self::normalize($row['internal_phone'] ?? null);
                if ($phone === null || !self::isValid($phone)) {
                    continue;
                }
                if ($excludeUserId !== null && (int) ($row['user_id'] ?? 0) === $excludeUserId) {
                    continue;
                }
                $label = trim((string) ($row['full_name'] ?? ''));
                if ($label === '') {
                    $label = 'запись справочника #' . (int) $row['id'];
                }
                $map[$phone][] = $label;
            }
        } catch (\Throwable $e) {
            Yii::warning('InternalPhoneHelper occupancy (directory): ' . $e->getMessage(), __METHOD__);
        }

        try {
            $userQuery = Users::find()
                ->select(['id', 'full_name', 'phone'])
                ->andWhere(['is_deleted' => false])
                ->andWhere(['not', ['phone' => null]])
                ->andWhere(['<>', 'phone', '']);

            if ($excludeUserId !== null) {
                $userQuery->andWhere(['<>', 'id', $excludeUserId]);
            }

            foreach ($userQuery->asArray()->all() as $row) {
                $phone = self::normalize($row['phone'] ?? null);
                if ($phone === null || !self::isValid($phone)) {
                    continue;
                }
                // Уже учтено через связанную запись справочника
                $already = false;
                if (isset($map[$phone])) {
                    foreach ($map[$phone] as $existing) {
                        if ($existing === (string) $row['full_name']) {
                            $already = true;
                            break;
                        }
                    }
                }
                if ($already) {
                    continue;
                }
                $label = trim((string) ($row['full_name'] ?? ''));
                if ($label === '') {
                    $label = 'пользователь #' . (int) $row['id'];
                }
                $map[$phone][] = $label;
            }
        } catch (\Throwable $e) {
            Yii::warning('InternalPhoneHelper occupancy (users): ' . $e->getMessage(), __METHOD__);
        }

        return $map;
    }

    /**
     * Элементы select: '' => «Не указан», далее номера с пометкой занятости.
     *
     * @return array<string, string>
     */
    public static function dropdownItems(
        ?string $currentValue = null,
        ?int $excludeUserId = null,
        ?int $excludeDirectoryId = null
    ): array {
        $currentValue = self::normalize($currentValue);
        $occupancy = self::occupancyMap($excludeUserId, $excludeDirectoryId);
        $items = ['' => self::EMPTY_LABEL];

        foreach (self::SERIES as $series) {
            for ($n = 1; $n <= 99; $n++) {
                $phone = $series . '-' . str_pad((string) $n, 2, '0', STR_PAD_LEFT);
                $items[$phone] = self::formatOptionLabel($phone, $occupancy[$phone] ?? []);
            }
        }

        // Текущее значение вне диапазона (устаревшие данные) — сохраняем в списке
        if ($currentValue !== null && !isset($items[$currentValue])) {
            $items[$currentValue] = $currentValue . ' (вне текущего диапазона)';
        }

        return $items;
    }

    /**
     * Optgroups для select: серия → номера (без пункта «Не указан» — его задаёт prompt).
     *
     * @return array<string, array<string, string>>
     */
    public static function dropdownGroups(
        ?string $currentValue = null,
        ?int $excludeUserId = null,
        ?int $excludeDirectoryId = null
    ): array {
        $currentValue = self::normalize($currentValue);
        $occupancy = self::occupancyMap($excludeUserId, $excludeDirectoryId);
        $groups = [];

        foreach (self::SERIES as $series) {
            $groupLabel = 'Серия ' . $series;
            $groups[$groupLabel] = [];
            for ($n = 1; $n <= 99; $n++) {
                $phone = $series . '-' . str_pad((string) $n, 2, '0', STR_PAD_LEFT);
                $groups[$groupLabel][$phone] = self::formatOptionLabel($phone, $occupancy[$phone] ?? []);
            }
        }

        if ($currentValue !== null && !self::isValid($currentValue)) {
            $groups['Прочее'] = [
                $currentValue => $currentValue . ' (вне текущего диапазона)',
            ];
        }

        return $groups;
    }

    /**
     * @param string[] $holders
     */
    public static function formatOptionLabel(string $phone, array $holders): string
    {
        if ($holders === []) {
            return $phone;
        }
        $holders = array_values(array_unique($holders));
        if (count($holders) === 1) {
            return $phone . ' — занят: ' . $holders[0];
        }

        return $phone . ' — занят (' . count($holders) . '): ' . $holders[0] . ' и др.';
    }

    /**
     * Текст предупреждения при выборе занятого номера (мягкое, без блокировки).
     */
    public static function occupancyWarning(
        ?string $phone,
        ?int $excludeUserId = null,
        ?int $excludeDirectoryId = null
    ): ?string {
        $phone = self::normalize($phone);
        if ($phone === null || !self::isValid($phone)) {
            return null;
        }
        $holders = self::occupancyMap($excludeUserId, $excludeDirectoryId)[$phone] ?? [];
        if ($holders === []) {
            return null;
        }
        $holders = array_values(array_unique($holders));

        return 'Номер ' . $phone . ' уже используется: ' . implode(', ', $holders)
            . '. Сохранение допускается (общий номер).';
    }

    /**
     * Валидатор для ActiveRecord (атрибут phone / internal_phone).
     */
    public static function validateAttribute($model, string $attribute): void
    {
        $value = self::normalize($model->$attribute);
        $model->$attribute = $value;
        if ($value === null) {
            return;
        }
        if (!self::isValid($value)) {
            $model->addError(
                $attribute,
                'Внутренний номер должен быть в формате X-XX, серии 4–8 (например 4-15, 8-03).'
            );
        }
    }
}
