<?php
/**
 * Журнал аудита: список событий в AG Grid.
 */

use app\assets\AuditGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var array $users [id => full_name] */

AuditGridAsset::register($this);

$req = Yii::$app->request;
$filterFrom = (string) $req->get('from', '');
$filterTo = (string) $req->get('to', '');
$filterActorId = $req->get('actor_id', '');
$filterActionType = (string) $req->get('action_type', '');
$filterObjectType = (string) $req->get('object_type', '');

$this->title = 'Журнал аудита';
$this->params['breadcrumbs'] = [];
?>
<div class="arm-page audit-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
        </div>
    </header>

    <div class="arm-command-bar audit-command-bar" role="region" aria-label="Поиск и фильтры">
        <div class="audit-command-bar__top">
            <div class="arm-search">
                <label class="visually-hidden" for="auditQuickFilter">Поиск по таблице</label>
                <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
                <input type="search" id="auditQuickFilter" class="form-control arm-search__input"
                       placeholder="Поиск" autocomplete="off">
                <button type="button" class="arm-search__clear" id="auditQuickFilterClear"
                        aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
            </div>

            <div class="arm-command-bar__tools">
                <?= Html::button('<i class="fas fa-filter" aria-hidden="true"></i><span class="arm-btn-label">Применить</span>', [
                    'class' => 'btn btn-primary arm-tool-btn',
                    'type' => 'button',
                    'id' => 'auditApplyFilters',
                    'title' => 'Применить фильтры',
                ]) ?>
                <?= Html::a('<i class="fas fa-rotate-left" aria-hidden="true"></i><span class="arm-btn-label">Сбросить</span>', ['index'], [
                    'class' => 'btn btn-outline-secondary arm-tool-btn',
                    'title' => 'Сбросить все фильтры',
                ]) ?>
                <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span class="arm-btn-label">Обновить</span>', [
                    'class' => 'btn btn-outline-secondary arm-tool-btn',
                    'type' => 'button',
                    'id' => 'auditRefreshGrid',
                    'title' => 'Перезагрузить данные',
                ]) ?>
            </div>
        </div>

        <form id="audit-filter-form" class="audit-filters" method="get" action="<?= Html::encode(Url::to(['index'])) ?>">
            <div class="audit-filters__field">
                <label class="audit-filters__label" for="audit-filter-from">С</label>
                <input type="date" name="from" id="audit-filter-from" class="form-control form-control-sm"
                       value="<?= Html::encode($filterFrom) ?>">
            </div>
            <div class="audit-filters__field">
                <label class="audit-filters__label" for="audit-filter-to">По</label>
                <input type="date" name="to" id="audit-filter-to" class="form-control form-control-sm"
                       value="<?= Html::encode($filterTo) ?>">
            </div>
            <div class="audit-filters__field audit-filters__field--wide">
                <label class="audit-filters__label" for="audit-filter-actor">Пользователь</label>
                <?= Html::dropDownList('actor_id', $filterActorId, ['' => '— все —'] + ($users ?? []), [
                    'class' => 'form-select form-select-sm js-user-select-search',
                    'id' => 'audit-filter-actor',
                    'data-placeholder' => '— все —',
                ]) ?>
            </div>
            <div class="audit-filters__field">
                <label class="audit-filters__label" for="audit-filter-action">Тип операции</label>
                <input type="text" name="action_type" id="audit-filter-action" class="form-control form-control-sm"
                       value="<?= Html::encode($filterActionType) ?>" placeholder="task.create">
            </div>
            <div class="audit-filters__field">
                <label class="audit-filters__label" for="audit-filter-object">Тип объекта</label>
                <?= Html::dropDownList('object_type', $filterObjectType, [
                    '' => '— все —',
                    'task' => 'Заявка',
                    'work_task' => 'Задача',
                    'user' => 'Пользователь',
                    'attachment' => 'Вложение',
                    'equipment' => 'Актив',
                    'software' => 'ПО',
                    'license' => 'Лицензия',
                    'equipment_software' => 'ПО на технике',
                ], [
                    'class' => 'form-select form-select-sm',
                    'id' => 'audit-filter-object',
                ]) ?>
            </div>
        </form>
    </div>

    <div class="arm-grid-card">
        <div id="agGridAuditContainer" class="ag-theme-quartz arm-grid-loading">
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>
<?php
$this->registerJs(
    'window.agGridAuditDataUrl = ' . json_encode(Url::to(['audit/get-grid-data'])) . ';',
    \yii\web\View::POS_HEAD
);
?>
