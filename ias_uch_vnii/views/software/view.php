<?php
/**
 * Карточка ПО.
 * @var yii\web\View $this
 * @var app\models\entities\Software $model
 */

use yii\helpers\Html;
use yii\helpers\Url;

$this->title = Html::encode($model->name);
$this->params['breadcrumbs'][] = ['label' => 'Лицензии ПО', 'url' => ['index']];
$this->params['breadcrumbs'][] = $this->title;

$this->registerCssFile(Url::to('@web/css/arm/index.css'), ['depends' => [\yii\bootstrap5\BootstrapAsset::class]]);
$this->registerCssFile(Url::to('@web/css/arm/form.css'), ['depends' => [\yii\bootstrap5\BootstrapAsset::class]]);
$this->registerCssFile(Url::to('@web/css/arm/view.css'), ['depends' => [\yii\bootstrap5\BootstrapAsset::class]]);
$this->registerCssFile(Url::to('@web/css/software/page.css'), ['depends' => [\yii\bootstrap5\BootstrapAsset::class]]);
$this->registerJsFile(Url::to('@web/js/software/license-attachments.js'), ['depends' => [\yii\web\JqueryAsset::class]]);
$this->registerJsFile(Url::to('@web/js/software/license-form-modal.js'), ['depends' => [\yii\web\JqueryAsset::class]]);
$this->registerJs(
    'window.agGridSoftwareLicenseCreateModalUrl = ' . json_encode(Url::to(['license-create-modal'])) . ';'
    . 'window.agGridSoftwareLicenseUpdateModalUrlTemplate = ' . json_encode(Url::to(['license-update-modal', 'id' => '__ID__'])) . ';',
    \yii\web\View::POS_HEAD
);
?>
<div class="software-view">
    <h1><?= Html::encode($model->name) ?></h1>
    <p>
        <?= Html::a('Изменить', ['update', 'id' => $model->id], ['class' => 'btn btn-primary']) ?>
        <?= Html::a('Удалить', ['delete', 'id' => $model->id], ['class' => 'btn btn-danger', 'data' => ['confirm' => 'Удалить это ПО и все связанные лицензии и установки?', 'method' => 'post']]) ?>
        <?= Html::a('К списку', ['index'], ['class' => 'btn btn-outline-secondary']) ?>
    </p>
    <table class="table table-bordered">
        <tr><th>Версия</th><td><?= Html::encode($model->version ?: '—') ?></td></tr>
    </table>

    <h3>
        Лицензии
        <?= Html::button('Добавить', [
            'class' => 'btn btn-sm btn-success',
            'type' => 'button',
            'data-software-license-create' => (int) $model->id,
        ]) ?>
    </h3>
    <?php
    $licenses = $model->licenses;
    if (empty($licenses)):
        echo '<p class="text-muted">Нет лицензий.</p>';
    else:
        echo '<table class="table table-striped"><thead><tr>'
            . '<th>Поставщик</th><th>Закупка</th><th>Срок действия</th><th>Примечание</th><th></th>'
            . '</tr></thead><tbody>';
        foreach ($licenses as $l) {
            $status = $l->getExpiryStatus();
            $period = $l->getValidityDisplay();
            echo '<tr>';
            echo '<td>' . Html::encode($l->supplier ?: '—') . '</td>';
            echo '<td>' . ($l->purchase_date ? Yii::$app->formatter->asDate($l->purchase_date) : '—') . '</td>';
            echo '<td>' . Html::encode($period);
            if ($status === 'expired') {
                echo ' <span class="badge bg-danger">Истекла</span>';
            } elseif ($status === 'expiring') {
                echo ' <span class="badge bg-warning">Скоро истекает</span>';
            }
            echo '</td>';
            echo '<td>' . Html::encode($l->notes ?: '—') . '</td>';
            echo '<td>'
                . Html::button('Изменить', [
                    'class' => 'btn btn-link btn-sm p-0',
                    'type' => 'button',
                    'data-software-license-edit' => (int) $l->id,
                ])
                . ' '
                . Html::a('Удалить', ['license-delete', 'id' => $l->id], [
                    'class' => 'btn btn-link btn-sm text-danger p-0',
                    'data' => ['confirm' => 'Удалить лицензию?', 'method' => 'post'],
                ])
                . '</td></tr>';
        }
        echo '</tbody></table>';
    endif;
    ?>

    <h3>Установлено на оборудовании <?= Html::a('Добавить', ['equipment-software-create', 'software_id' => $model->id], ['class' => 'btn btn-sm btn-success']) ?></h3>
    <?php
    $installs = $model->equipmentSoftware;
    if (empty($installs)):
        echo '<p class="text-muted">Нет записей об установке.</p>';
    else:
        echo '<ul class="list-group">';
        foreach ($installs as $inst) {
            $eq = $inst->equipment;
            $line = $eq ? Html::a(Html::encode($eq->inventory_number . ' — ' . $eq->name), ['/arm/view', 'id' => $eq->id], ['target' => '_blank']) : '—';
            if ($inst->license_id && $inst->license) {
                $line .= ' <span class="text-muted small">(лиц. #' . (int) $inst->license_id . ')</span>';
            }
            if ($inst->installed_at) {
                $line .= ' <span class="text-muted">(' . Yii::$app->formatter->asDate($inst->installed_at) . ')</span>';
            }
            $line .= ' ' . Html::a('Удалить', ['equipment-software-delete', 'id' => $inst->id], ['class' => 'btn btn-sm btn-outline-danger', 'data' => ['confirm' => 'Удалить связь?', 'method' => 'post']]);
            echo '<li class="list-group-item">' . $line . '</li>';
        }
        echo '</ul>';
    endif;
    ?>
</div>

<div id="agGridSoftwareContainer" style="display:none"
     data-license-create-modal-url="<?= Html::encode(Url::to(['license-create-modal'])) ?>"
     data-license-update-modal-url-template="<?= Html::encode(Url::to(['license-update-modal', 'id' => '__ID__'])) ?>">
</div>

<?= $this->render('_license_modal', [
    'createTitle' => 'Добавить лицензию',
    'updateTitle' => 'Редактировать лицензию',
]) ?>
