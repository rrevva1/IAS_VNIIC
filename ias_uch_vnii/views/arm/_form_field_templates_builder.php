<?php

/**
 * Шаблоны полей «Конфигурация» для формы техники.
 *
 * @return array{templates: array<string, array<int, array<string, mixed>>>, placeholders: array<string, string>}
 */
return static function (array $orgTechFields): array {
    $configPlaceholders = require __DIR__ . '/_form_config_field_placeholders.php';

    $withPlaceholder = static function (array $field) use ($configPlaceholders): array {
        $name = (string) ($field['name'] ?? '');
        if ($name !== '' && isset($configPlaceholders[$name]) && !isset($field['placeholder'])) {
            $field['placeholder'] = $configPlaceholders[$name];
        }

        return $field;
    };

    $pcFields = array_map($withPlaceholder, [
        ['name' => 'cpu', 'label' => 'Процессор (ЦП)', 'part' => 'ЦП', 'char' => 'Модель', 'widget' => 'cpu-datalist'],
        ['name' => 'ram', 'label' => 'Оперативная память (ОЗУ)', 'part' => 'ОЗУ', 'char' => 'Объём', 'widget' => 'ram-datalist'],
        ['name' => 'disk', 'label' => 'Накопители (диски)', 'part' => 'Накопитель', 'char' => 'Модель', 'widget' => 'disk-datalist-multi'],
        ['name' => 'hostname', 'label' => 'Имя компьютера', 'part' => 'ПК', 'char' => 'Имя ПК'],
        ['name' => 'ip', 'label' => 'IP-адрес', 'part' => 'ПК', 'char' => 'IP адрес', 'widget' => 'ip-datalist'],
        ['name' => 'os', 'label' => 'Операционная система', 'part' => 'ПК', 'char' => 'ОС', 'widget' => 'os-datalist'],
    ]);
    $portablePcFields = array_merge($pcFields, [
        $withPlaceholder([
            'name' => 'screen_diagonal',
            'label' => 'Диагональ экрана',
            'part' => 'Монитор',
            'char' => 'Диагональ экрана',
            'widget' => 'screen-diagonal-datalist',
        ]),
    ]);

    $orgTechFields = array_map($withPlaceholder, $orgTechFields);

    $templates = [
        'ПК' => $pcFields,
        'Системный блок' => $pcFields,
        'Ноутбук' => $portablePcFields,
        'Моноблок' => $portablePcFields,
        'Монитор' => [
            $withPlaceholder([
                'name' => 'screen_diagonal',
                'label' => 'Диагональ экрана',
                'part' => 'Монитор',
                'char' => 'Диагональ экрана',
                'widget' => 'screen-diagonal-datalist',
            ]),
        ],
        'Принтер' => $orgTechFields,
        'МФУ' => $orgTechFields,
        'ИБП' => [
            $withPlaceholder([
                'name' => 'ups_battery',
                'label' => 'Модель аккумулятора',
                'part' => 'ИБП',
                'char' => 'Модель аккумулятора',
                'widget' => 'ups-battery-datalist',
            ]),
            $withPlaceholder([
                'name' => 'ups_battery_replaced_at',
                'label' => 'Дата замены аккумулятора',
                'part' => 'ИБП',
                'char' => 'Дата замены аккумулятора',
                'widget' => 'date',
            ]),
            $withPlaceholder([
                'name' => 'ups_battery_service_life',
                'label' => 'Срок службы аккумулятора, лет',
                'part' => 'ИБП',
                'char' => 'Срок службы аккумулятора',
                'widget' => 'number',
            ]),
        ],
    ];

    return [
        'templates' => $templates,
        'placeholders' => $configPlaceholders,
    ];
};
