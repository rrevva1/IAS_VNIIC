<?php

namespace app\components;

use app\models\entities\Equipment;
use app\models\entities\PartCharValues;
use app\models\entities\SprChars;
use app\models\entities\SprParts;
use Yii;

/**
 * Сохранение характеристик техники (PartChar, накопители, OrgTech) — общая логика для ARM и поставок.
 */
class EquipmentPartCharService
{
    /**
     * Применяет шаблон характеристик строки поставки к созданной единице техники.
     *
     * @param array<string, mixed> $template
     */
    public function applyCharTemplate(int $equipmentId, array $template, ?string $equipmentTypeName = null): void
    {
        $partChar = $template['PartChar'] ?? [];
        if (!is_array($partChar)) {
            $partChar = [];
        }

        $disksSubmitted = !empty($template['PartCharDisksSubmitted']);
        $disks = $template['PartCharDisks'] ?? null;
        if ($disksSubmitted || (is_array($disks) && $disks !== [])) {
            $this->saveDiskValues($equipmentId, is_array($disks) ? $disks : []);
            unset($partChar['disk']);
        }

        if ($partChar !== []) {
            $this->savePartCharValues($equipmentId, $partChar, $equipmentTypeName);
        }

        $equipment = Equipment::findOne($equipmentId);
        if ($equipment === null) {
            return;
        }

        if (!empty($template['OrgTechSubmitted'])) {
            $orgTech = $template['OrgTech'] ?? [];
            if (!is_array($orgTech)) {
                $orgTech = [];
            }
            $this->applyOrgTechDescription($equipment, $orgTech);
        }
    }

    /**
     * @param array<string, string> $partChar
     */
    public function savePartCharValues(int $equipmentId, array $partChar, ?string $equipmentTypeName = null): void
    {
        $equipment = Equipment::findOne($equipmentId);
        $typeName = $equipmentTypeName ?? ($equipment ? $equipment->resolveEquipmentTypeName() : '');
        $isOrgTech = EquipmentCharCatalog::isPrinterOrMfuType($typeName);
        $isScanner = EquipmentCharCatalog::isScannerType($typeName);

        $map = [
            'cpu' => ['ЦП', 'Модель'],
            'ram' => ['ОЗУ', 'Объём'],
            'monitor' => ['Монитор', 'Модель'],
            'hostname' => ['ПК', 'Имя ПК'],
            'ip' => $isOrgTech ? ['Принтер', 'IP адрес'] : ['ПК', 'IP адрес'],
            'os' => ['ПК', 'ОС'],
            'model' => ['Монитор', 'Модель'],
            'screen_diagonal' => ['Монитор', 'Диагональ экрана'],
            'monitor_inv' => ['Монитор', '№ монитора'],
            'ups_battery' => ['ИБП', 'Модель аккумулятора'],
            'ups_battery_replaced_at' => ['ИБП', 'Дата замены аккумулятора'],
            'ups_battery_service_life' => ['ИБП', 'Срок службы аккумулятора'],
            'cpu_count' => ['ЦП', 'Количество процессоров'],
            'misc_description' => ['Прочее', 'Описание'],
            'misc_ip' => ['Прочее', 'IP адрес'],
        ];
        if ($isOrgTech) {
            $map = array_merge($map, EquipmentCharCatalog::getPrinterMfuPartCharSaveMap());
        }
        if ($isScanner) {
            $map = array_merge($map, EquipmentCharCatalog::getScannerPartCharSaveMap());
        }

        foreach ($partChar as $key => $value) {
            if (!is_string($value)) {
                continue;
            }
            $value = in_array($key, EquipmentCharCatalog::getMultilinePartCharFieldNames(), true)
                ? EquipmentCharCatalog::normalizeEquipmentComment($value)
                : trim($value);
            if ($value === '') {
                continue;
            }
            $m = $map[$key] ?? null;
            if (!$m) {
                continue;
            }
            $this->upsertPartCharValue($equipmentId, $m[0], $m[1], $value);
        }
    }

    /**
     * @param array<int, string> $disksRaw
     */
    public function saveDiskValues(int $equipmentId, array $disksRaw): void
    {
        $value = EquipmentCharCatalog::joinDiskList($disksRaw);

        $part = SprParts::find()->where(['name' => 'Накопитель'])->one();
        if (!$part) {
            return;
        }

        $eqCol = $this->resolvePartCharEquipmentIdColumn();
        PartCharValues::deleteAll([
            $eqCol => $equipmentId,
            'part_id' => $part->id,
        ]);

        if ($value === '') {
            return;
        }

        $char = SprChars::find()->where(['name' => 'Модель'])->one()
            ?? SprChars::find()->where(['name' => 'Объём'])->one();
        if (!$char) {
            return;
        }

        $pcv = new PartCharValues();
        $pcv->setAttribute($eqCol, $equipmentId);
        $pcv->part_id = $part->id;
        $pcv->char_id = $char->id;
        $pcv->value_text = $value;
        $pcv->save(false);
    }

    /**
     * @param array<string, mixed> $orgTech
     */
    public function applyOrgTechDescription(Equipment $equipment, array $orgTech): void
    {
        if (!EquipmentCharCatalog::isPrinterOrMfuType($equipment->resolveEquipmentTypeName())) {
            return;
        }

        $code = trim((string) ($orgTech['cartridge_procurement'] ?? ''));
        if ($code !== 'yes' && $code !== 'no') {
            $code = '';
        }

        $equipment->description = EquipmentCharCatalog::buildPrinterDescription(
            $code,
            (string) ($equipment->description ?? '')
        );
        $equipment->save(false);
    }

    /**
     * Собирает JSON-шаблон характеристик из POST (как форма «Учёт ТС»).
     *
     * @param array<string, mixed> $post
     * @return array<string, mixed>
     */
    public function buildCharTemplateFromPost(array $post): array
    {
        $template = [];
        if (isset($post['PartChar']) && is_array($post['PartChar'])) {
            $template['PartChar'] = $post['PartChar'];
        }
        if (isset($post['PartCharDisks']) && is_array($post['PartCharDisks'])) {
            $template['PartCharDisks'] = $post['PartCharDisks'];
        }
        if (isset($post['PartCharDisksSubmitted'])) {
            $template['PartCharDisksSubmitted'] = $post['PartCharDisksSubmitted'];
        }
        if (isset($post['OrgTech']) && is_array($post['OrgTech'])) {
            $template['OrgTech'] = $post['OrgTech'];
        }
        if (isset($post['OrgTechSubmitted'])) {
            $template['OrgTechSubmitted'] = $post['OrgTechSubmitted'];
        }

        return $template;
    }

    private function upsertPartCharValue(int $equipmentId, string $partName, string $charName, string $value): void
    {
        $part = SprParts::find()->where(['name' => $partName])->one();
        $char = SprChars::find()->where(['name' => $charName])->one();
        if (!$part || !$char) {
            return;
        }

        $existing = PartCharValues::findOne([
            'equipment_id' => $equipmentId,
            'part_id' => $part->id,
            'char_id' => $char->id,
        ]);
        if ($existing) {
            $existing->value_text = $value;
            $existing->save(false);

            return;
        }

        $pcv = new PartCharValues();
        $pcv->equipment_id = $equipmentId;
        $pcv->part_id = $part->id;
        $pcv->char_id = $char->id;
        $pcv->value_text = $value;
        $pcv->save(false);
    }

    private function resolvePartCharEquipmentIdColumn(): string
    {
        $schema = Yii::$app->db->getTableSchema('part_char_values', true);
        if ($schema && isset($schema->columns['equipment_id'])) {
            return 'equipment_id';
        }

        return 'id_arm';
    }
}
