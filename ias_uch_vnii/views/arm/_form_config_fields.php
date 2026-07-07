<?php

use yii\helpers\Html;

/** @var array<int, array<string, mixed>> $fields */
/** @var array<string, string> $chars */
/** @var array<string, string> $orgTech */

$chars = $chars ?? [];
$orgTech = $orgTech ?? [];

$datalistMap = [
    'cpu-datalist' => 'arm-cpu-datalist',
    'ram-datalist' => 'arm-ram-datalist',
    'os-datalist' => 'arm-os-datalist',
    'ip-datalist' => 'arm-ip-datalist',
    'ups-battery-datalist' => 'arm-ups-battery-datalist',
    'screen-diagonal-datalist' => 'arm-screen-diagonal-datalist',
];

$normalizeDate = static function (string $value): string {
    $value = trim($value);
    if ($value === '') {
        return '';
    }
    if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) {
        return $value;
    }
    if (preg_match('/^(\d{1,2})\.(\d{1,2})\.(\d{4})$/', $value, $m)) {
        return sprintf('%04d-%02d-%02d', (int) $m[3], (int) $m[2], (int) $m[1]);
    }

    return $value;
};

foreach ($fields as $field):
    $name = (string) ($field['name'] ?? '');
    if ($name === '') {
        continue;
    }
    $label = (string) ($field['label'] ?? $name);
    $widget = (string) ($field['widget'] ?? '');
    $placeholder = (string) ($field['placeholder'] ?? '');
    ?>
    <div class="arm-dynamic-field<?= $widget === 'disk-datalist-multi' || $name === 'disk' ? ' arm-dynamic-field--disks' : '' ?>">
        <?php if ($widget === 'cartridge-select' || $name === 'cartridge_procurement'): ?>
            <label class="form-label"><?= Html::encode($label) ?></label>
            <input type="hidden" name="OrgTechSubmitted" value="1">
            <?php
            $current = trim((string) ($orgTech['cartridge_procurement'] ?? ''));
            echo Html::dropDownList(
                'OrgTech[cartridge_procurement]',
                $current,
                [
                    '' => '— не указано —',
                    'yes' => 'Учтен',
                    'no' => 'Не учтен',
                ],
                ['class' => 'form-select']
            );
            ?>
        <?php elseif ($widget === 'choice-select' && !empty($field['options'])): ?>
            <label class="form-label"><?= Html::encode($label) ?></label>
            <?php
            $options = [];
            foreach ($field['options'] as $opt) {
                $val = (string) ($opt['value'] ?? '');
                $options[$val] = (string) ($opt['label'] ?? $val);
            }
            echo Html::dropDownList(
                'PartChar[' . $name . ']',
                trim((string) ($chars[$name] ?? '')),
                $options,
                ['class' => 'form-select']
            );
            ?>
        <?php elseif ($widget === 'date'): ?>
            <label class="form-label"><?= Html::encode($label) ?></label>
            <?= Html::input(
                'date',
                'PartChar[' . $name . ']',
                $normalizeDate((string) ($chars[$name] ?? '')),
                [
                    'class' => 'form-control',
                    'data-part' => (string) ($field['part'] ?? ''),
                    'data-char' => (string) ($field['char'] ?? ''),
                    'title' => $placeholder !== '' ? $placeholder : null,
                ]
            ) ?>
        <?php elseif ($widget === 'number'): ?>
            <label class="form-label"><?= Html::encode($label) ?></label>
            <?= Html::input(
                'number',
                'PartChar[' . $name . ']',
                (string) ($chars[$name] ?? ''),
                [
                    'class' => 'form-control',
                    'min' => 0,
                    'max' => 30,
                    'step' => '0.5',
                    'inputmode' => 'decimal',
                    'placeholder' => $placeholder !== '' ? $placeholder : null,
                    'data-part' => (string) ($field['part'] ?? ''),
                    'data-char' => (string) ($field['char'] ?? ''),
                ]
            ) ?>
        <?php else: ?>
            <?php
            $listId = $datalistMap[$widget] ?? ($datalistMap[$name] ?? null);
            if ($name === 'cpu') {
                $listId = 'arm-cpu-datalist';
            } elseif ($name === 'ram') {
                $listId = 'arm-ram-datalist';
            } elseif ($name === 'os') {
                $listId = 'arm-os-datalist';
            } elseif ($name === 'ip') {
                $listId = 'arm-ip-datalist';
            } elseif ($name === 'ups_battery') {
                $listId = 'arm-ups-battery-datalist';
            } elseif ($name === 'screen_diagonal') {
                $listId = 'arm-screen-diagonal-datalist';
            }
            ?>
            <label class="form-label"><?= Html::encode($label) ?></label>
            <?= Html::textInput(
                'PartChar[' . $name . ']',
                (string) ($chars[$name] ?? ''),
                [
                    'class' => 'form-control',
                    'list' => $listId,
                    'autocomplete' => 'off',
                    'placeholder' => $placeholder !== '' ? $placeholder : null,
                    'data-part' => (string) ($field['part'] ?? ''),
                    'data-char' => (string) ($field['char'] ?? ''),
                ]
            ) ?>
        <?php endif; ?>
    </div>
<?php endforeach; ?>
