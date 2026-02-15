<?php
/**
 * Журнал аудита: список событий в AG Grid.
 * Фильтры по дате, пользователю, типу операции и типу объекта; данные из audit/get-grid-data.
 */

use app\assets\AuditGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;
use yii\widgets\ActiveForm;

/* @var $this yii\web\View */
/* @var $users array [id => full_name] */

AuditGridAsset::register($this);

$this->title = 'Журнал аудита';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="audit-index">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
        <?= Html::button('<i class="glyphicon glyphicon-refresh"></i> Обновить', [
            'class' => 'btn btn-outline-secondary',
            'onclick' => 'refreshAuditGrid()',
        ]) ?>
    </div>

    <?php $form = ActiveForm::begin([
        'id' => 'audit-filter-form',
        'method' => 'get',
        'action' => ['index'],
        'options' => ['class' => 'mb-3'],
    ]); ?>
    <div class="row g-2 align-items-end">
        <div class="col-md-2">
            <label class="form-label">С</label>
            <input type="date" name="from" class="form-control" value="<?= Html::encode(Yii::$app->request->get('from')) ?>">
        </div>
        <div class="col-md-2">
            <label class="form-label">По</label>
            <input type="date" name="to" class="form-control" value="<?= Html::encode(Yii::$app->request->get('to')) ?>">
        </div>
        <div class="col-md-2">
            <label class="form-label">Пользователь</label>
            <?= Html::dropDownList('actor_id', Yii::$app->request->get('actor_id'), ['' => '—'] + ($users ?? []), ['class' => 'form-select']) ?>
        </div>
        <div class="col-md-2">
            <label class="form-label">Тип операции</label>
            <input type="text" name="action_type" class="form-control" value="<?= Html::encode(Yii::$app->request->get('action_type')) ?>" placeholder="task.create">
        </div>
        <div class="col-md-2">
            <label class="form-label">Тип объекта</label>
            <?= Html::dropDownList('object_type', Yii::$app->request->get('object_type'), [
                '' => '—',
                'task' => 'Заявка',
                'user' => 'Пользователь',
                'attachment' => 'Вложение',
                'equipment' => 'Актив',
                'software' => 'ПО',
                'license' => 'Лицензия',
                'equipment_software' => 'ПО на технике',
            ], ['class' => 'form-select']) ?>
        </div>
        <div class="col-md-2">
            <?= Html::submitButton('Фильтр', ['class' => 'btn btn-primary']) ?>
        </div>
        <div class="col-md-2">
            <?= Html::a('Сбросить фильтры', ['index'], ['class' => 'btn btn-outline-secondary']) ?>
        </div>
    </div>
    <?php ActiveForm::end(); ?>

    <p class="text-muted small">
        Если записей нет, загрузите тестовые данные: <code>psql -U postgres -d ias_vniic -f tests/seed_audit_only.sql</code> (см. <code>tests/LOAD_TEST_DATA_FROM_DUMP.md</code>).
    </p>

    <div id="agGridAuditContainer" class="ag-theme-quartz" style="width: 100%; height: 65vh; min-height: 400px;">
        <div class="text-center p-4 text-muted">
            <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
            <p>Загрузка таблицы...</p>
        </div>
    </div>
</div>
<?php
$this->registerJs(
    "window.agGridAuditDataUrl = " . json_encode(Url::to(['audit/get-grid-data'])) . ";",
    \yii\web\View::POS_HEAD
);
