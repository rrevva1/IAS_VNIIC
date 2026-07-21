<?php

use app\components\InternalPhoneHelper;
use yii\helpers\Html;

/**
 * Выпадающий список внутреннего номера (серии 4–8, формат X-XX).
 *
 * @var yii\widgets\ActiveForm $form
 * @var yii\base\Model $model
 * @var string $attribute
 * @var string $inputId
 * @var string|null $cssClass
 * @var int|null $excludeUserId
 * @var int|null $excludeDirectoryId
 * @var bool $showHint
 */

$attribute = $attribute ?? 'phone';
$inputId = $inputId ?? ($attribute === 'internal_phone' ? 'internal-phone' : 'phone');
$cssClass = $cssClass ?? 'form-select';
$excludeUserId = $excludeUserId ?? null;
$excludeDirectoryId = $excludeDirectoryId ?? null;
$showHint = $showHint ?? true;

$current = InternalPhoneHelper::normalize($model->$attribute ?? null);
$groups = InternalPhoneHelper::dropdownGroups($current, $excludeUserId, $excludeDirectoryId);
$warning = InternalPhoneHelper::occupancyWarning($current, $excludeUserId, $excludeDirectoryId);
?>

<?= $form->field($model, $attribute, ['options' => ['class' => 'mb-0']])->dropDownList($groups, [
    'id' => $inputId,
    'class' => $cssClass,
    'prompt' => InternalPhoneHelper::EMPTY_LABEL,
    'data-phone-select' => '1',
    'data-exclude-user-id' => $excludeUserId !== null ? (string) $excludeUserId : '',
    'data-exclude-directory-id' => $excludeDirectoryId !== null ? (string) $excludeDirectoryId : '',
])->label(false) ?>

<div class="internal-phone-occupancy-warn text-warning small mt-1<?= $warning ? '' : ' d-none' ?>"
     data-phone-occupancy-warn
     role="status">
    <?php if ($warning): ?>
        <i class="fas fa-triangle-exclamation" aria-hidden="true"></i>
        <?= Html::encode($warning) ?>
    <?php endif; ?>
</div>

<?php if ($showHint): ?>
    <p class="internal-phone-hint text-muted small mt-1 mb-0">
        Формат X-XX, серии 4–8 (<?= Html::encode(implode(', ', array_map(static fn ($s) => $s . '-01…' . $s . '-99', InternalPhoneHelper::SERIES))) ?>).
        Общий номер допускается — система только предупредит о занятости.
    </p>
<?php endif; ?>
