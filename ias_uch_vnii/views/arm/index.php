<?php
/**
 * Учет ТС: список оборудования в AG Grid.
 * Колонки — по Основному учёту (см. docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
 */

use app\assets\ArmGridAsset;
use app\assets\IssueKitAsset;
use app\components\EquipmentCharCatalog;
use yii\helpers\Html;
use yii\helpers\Url;

ArmGridAsset::register($this);
if (($locationScope ?? '') === 'warehouse_only') {
    IssueKitAsset::register($this);
}

$this->params['breadcrumbs'] = [];

$equipmentTypes = $equipmentTypes ?? [];
$isAdmin = $isAdmin ?? false;
$pageTitle = $pageTitle ?? 'Учет ТС';
$locationScope = $locationScope ?? 'exclude_warehouse';
$gridDataRoute = $gridDataRoute ?? ['arm/get-grid-data'];
$exportRoute = $exportRoute ?? ['arm/export-xlsx'];
$hideAllEquipmentTab = $hideAllEquipmentTab ?? false;
$defaultEquipmentTypeId = $defaultEquipmentTypeId ?? '';
$this->title = $pageTitle;
?>
<div class="arm-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($pageTitle) ?></h1>
        </div>
    </header>

    <div class="arm-command-bar" role="region" aria-label="Фильтры и действия с таблицей">
        <div class="arm-search">
            <label class="visually-hidden" for="armQuickFilter">Поиск по таблице</label>
            <i class="fas fa-search arm-search__icon" aria-hidden="true"></i>
            <input type="search" id="armQuickFilter" class="form-control arm-search__input"
                   placeholder="Поиск" autocomplete="off">
            <button type="button" class="arm-search__clear" id="armQuickFilterClear"
                    aria-label="Очистить поиск" title="Очистить поиск" hidden>×</button>
        </div>

        <div class="arm-command-bar__tabs" role="tablist" aria-label="Тип техники">
            <ul class="nav nav-tabs arm-type-tabs">
                <?php if (!$hideAllEquipmentTab): ?>
                <li class="nav-item">
                    <a class="nav-link active arm-type-tab" href="#" data-type-id="" role="tab" aria-selected="true">Вся техника</a>
                </li>
                <?php endif; ?>
                <?php foreach ($equipmentTypes as $index => $type):
                    $typeId = (string) ($type['id'] ?? '');
                    $tabActive = $hideAllEquipmentTab && $index === 0;
                    ?>
                <li class="nav-item">
                    <a class="nav-link arm-type-tab<?= $tabActive ? ' active' : '' ?>" href="#" role="tab"
                       aria-selected="<?= $tabActive ? 'true' : 'false' ?>"
                       data-type-id="<?= Html::encode($typeId) ?>"><?= Html::encode($type['name'] ?? '') ?></a>
                </li>
                <?php endforeach; ?>
            </ul>
        </div>

        <div class="arm-command-bar__tools">
            <?php if ($isAdmin && $locationScope === 'warehouse_only'): ?>
            <?= Html::button('<i class="fas fa-box-open" aria-hidden="true"></i><span class="arm-btn-label">Выдать комплект</span>', [
                'class' => 'btn btn-primary arm-tool-btn',
                'type' => 'button',
                'id' => 'btnIssueKit',
                'title' => 'Выдать системный блок с монитором и ИБП со склада',
            ]) ?>
            <?php endif; ?>
            <?php if ($isAdmin): ?>
            <?= Html::button('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">Добавить</span>', [
                'class' => 'btn btn-primary arm-tool-btn',
                'type' => 'button',
                'data-arm-create-open' => '1',
                'title' => 'Добавить технику',
            ]) ?>
            <?php endif; ?>
            <?= Html::button('<i class="fas fa-table-columns" aria-hidden="true"></i><span class="arm-btn-label">Колонки</span>', [
                'class' => 'btn btn-outline-secondary arm-tool-btn',
                'id' => 'btnArmColumns',
                'title' => 'Видимые столбцы',
            ]) ?>
            <?php if ($isAdmin): ?>
            <div class="dropdown arm-files-dropdown">
                <button class="btn btn-outline-secondary arm-tool-btn dropdown-toggle" type="button"
                        id="armFilesDropdown" data-bs-toggle="dropdown" aria-expanded="false"
                        title="Экспорт и импорт Excel">
                    <i class="fas fa-file-excel" aria-hidden="true"></i><span class="arm-btn-label">Excel</span>
                </button>
                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="armFilesDropdown">
                    <li>
                        <?= Html::button('<i class="fas fa-file-export me-2" aria-hidden="true"></i>Экспорт таблицы', [
                            'class' => 'dropdown-item',
                            'id' => 'btnArmExportXlsx',
                        ]) ?>
                    </li>
                    <li>
                        <?= Html::button('<i class="fas fa-file-import me-2" aria-hidden="true"></i>Импорт из файла', [
                            'class' => 'dropdown-item',
                            'id' => 'btnArmImportXlsx',
                        ]) ?>
                    </li>
                    <li><hr class="dropdown-divider"></li>
                    <li>
                        <?= Html::button('<i class="fas fa-file-download me-2" aria-hidden="true"></i>Шаблон для импорта', [
                            'class' => 'dropdown-item',
                            'id' => 'btnArmTemplateXlsx',
                        ]) ?>
                    </li>
                </ul>
            </div>
            <?php endif; ?>
        </div>
    </div>

    <div class="arm-grid-card">
        <div id="agGridArmContainer" class="ag-theme-quartz arm-grid-loading"
             data-create-modal-url="<?= Html::encode(Url::to(['/arm/create-modal'])) ?>"
             data-update-modal-url-template="<?= Html::encode(Url::to(['/arm/update-modal', 'id' => '__ID__'])) ?>"
             data-view-modal-url-template="<?= Html::encode(Url::to(['/arm/view-modal', 'id' => '__ID__'])) ?>">
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
        <?php if ($isAdmin): ?>
        <div id="armSelectionBar" class="arm-selection-bar" aria-live="polite">
            <p class="arm-selection-bar__text">
                Выбрано: <strong id="armSelectionCount">0</strong>
            </p>
            <div class="arm-selection-bar__actions">
                <?= Html::button('<i class="fas fa-user-pen" aria-hidden="true"></i> Изменить', [
                    'class' => 'btn btn-primary arm-selection-bar__btn',
                    'id' => 'armSelectionReassign',
                    'type' => 'button',
                ]) ?>
                <?= Html::button('Снять выбор', [
                    'class' => 'btn btn-outline-secondary arm-selection-bar__btn',
                    'id' => 'armSelectionClear',
                    'type' => 'button',
                ]) ?>
            </div>
        </div>
        <?php endif; ?>
    </div>
</div>

<?= $this->render('_view_modal') ?>
<?= $this->render('_create_modal') ?>
<?= $this->render('_photo_preview_modal') ?>
<?php if ($isAdmin && $locationScope === 'warehouse_only'): ?>
<?= $this->render('_issue_kit_modal', [
    'users' => $users ?? [],
    'locations' => $locations ?? [],
    'statuses' => $statuses ?? [],
    'warehouseLocations' => $warehouseLocations ?? [],
]) ?>
<?php endif; ?>

<input type="file" id="armImportFileInput" accept=".xlsx,.xls" style="display:none;">

<div class="modal fade arm-columns-modal" id="armColumnsModal" tabindex="-1" aria-labelledby="armColumnsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable arm-columns-modal__dialog">
        <div class="modal-content arm-columns-modal__content">
            <div class="modal-header arm-columns-modal__header">
                <div class="arm-columns-modal__header-main">
                    <div class="arm-columns-modal__header-icon" aria-hidden="true">
                        <i class="fas fa-table-columns"></i>
                    </div>
                    <div class="arm-columns-modal__header-text">
                        <h5 class="modal-title" id="armColumnsModalLabel">Настройка столбцов</h5>
                        <p class="arm-columns-modal__subtitle" id="armColumnsModalSubtitle">Выберите параметры для отображения в таблице</p>
                    </div>
                </div>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-columns-modal__body">
                <div class="arm-columns-modal__toolbar">
                    <label class="arm-columns-modal__search" for="armColumnsSearch">
                        <i class="fas fa-search" aria-hidden="true"></i>
                        <input type="search" id="armColumnsSearch" class="form-control" placeholder="Поиск столбца…" autocomplete="off">
                    </label>
                    <div class="arm-columns-modal__bulk" role="group" aria-label="Массовый выбор">
                        <button type="button" class="btn btn-sm btn-outline-primary" id="armColumnsSelectAll">Выбрать все</button>
                        <button type="button" class="btn btn-sm btn-outline-secondary" id="armColumnsSelectNone">Снять все</button>
                    </div>
                </div>
                <p class="arm-columns-modal__meta">
                    <span class="arm-columns-modal__counter" id="armColumnsCounter">Выбрано: 0 из 0</span>
                </p>
                <div id="armColumnsList" class="arm-columns-modal__groups"></div>
            </div>
            <div class="modal-footer arm-columns-modal__footer">
                <button type="button" class="btn btn-outline-secondary" id="armColumnsReset">По умолчанию</button>
                <button type="button" class="btn btn-primary" id="armColumnsApply">Применить</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="reassignArmModal" tabindex="-1" aria-labelledby="reassignArmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen arm-reassign-modal__dialog">
        <div class="modal-content arm-reassign-modal arm-op-modal">
            <div class="modal-header arm-reassign-modal__header">
                <h5 class="modal-title" id="reassignArmModalLabel">
                    <i class="fas fa-people-arrows" aria-hidden="true"></i>
                    Перемещение и переназначение техники
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-reassign-modal__body">
                <div class="arm-reassign-layout">
                    <aside class="arm-reassign-layout__aside" id="reassignEquipmentInfo" aria-label="Превью операции">
                        <div class="arm-op-aside">
                            <section class="arm-op-aside__block arm-op-aside__block--primary" aria-labelledby="reassignStepSelectedTitle">
                                <div class="arm-op-aside__head">
                                    <h6 class="arm-op-aside__title" id="reassignStepSelectedTitle">
                                        <i class="fas fa-list-check" aria-hidden="true"></i>
                                        Выбранная техника
                                    </h6>
                                    <span class="arm-op-aside__badge" id="reassignEquipmentCount">0</span>
                                </div>
                                <div id="reassignEquipmentList" class="arm-op-aside__scroll">
                                    <div class="arm-reassign-equipment-list__loading">
                                        <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                                        Загрузка данных…
                                    </div>
                                </div>
                            </section>

                            <section class="arm-op-aside__block arm-op-aside__block--changes" aria-labelledby="reassignPreviewTitle">
                                <div class="arm-op-aside__head">
                                    <h6 class="arm-op-aside__title" id="reassignPreviewTitle">
                                        <i class="fas fa-arrow-right-arrow-left" aria-hidden="true"></i>
                                        Что изменится
                                    </h6>
                                </div>
                                <div id="reassignPreview" class="arm-op-changes" role="status" aria-live="polite">
                                    <ul id="reassignPreviewList" class="arm-op-changes__list">
                                        <li class="arm-op-change arm-op-change--muted">
                                            <span class="arm-op-change__label">Ожидание</span>
                                            <span class="arm-op-change__body">
                                                <span class="arm-op-change__to">Укажите параметры справа</span>
                                            </span>
                                        </li>
                                    </ul>
                                </div>
                            </section>
                        </div>
                    </aside>

                    <div class="arm-reassign-layout__main">
                <section class="arm-reassign-section arm-reassign-section--action" aria-labelledby="reassignStepModeTitle">
                    <h6 class="arm-reassign-section__title arm-reassign-section__title--plain" id="reassignStepModeTitle">
                        <i class="fas fa-sliders arm-reassign-section__title-icon" aria-hidden="true"></i>
                        Тип операции
                    </h6>
                    <input type="hidden" id="reassignOperationMode" value="reassign">
                    <div class="arm-reassign-mode-switch" role="radiogroup" aria-labelledby="reassignStepModeTitle">
                        <button type="button"
                                class="arm-reassign-mode-btn is-active"
                                data-mode="reassign"
                                role="radio"
                                aria-checked="true">
                            <i class="fas fa-user-pen" aria-hidden="true"></i>
                            <span>Обычное переназначение</span>
                        </button>
                        <button type="button"
                                class="arm-reassign-mode-btn"
                                data-mode="move_component"
                                id="reassignModeBtnMoveComponent"
                                role="radio"
                                aria-checked="false">
                            <i class="fas fa-link" aria-hidden="true"></i>
                            <span>Привязка к системному блоку</span>
                        </button>
                        <button type="button"
                                class="arm-reassign-mode-btn"
                                data-mode="move_to_warehouse"
                                role="radio"
                                aria-checked="false">
                            <i class="fas fa-warehouse" aria-hidden="true"></i>
                            <span>Перемещение на склад</span>
                        </button>
                        <button type="button"
                                class="arm-reassign-mode-btn"
                                data-mode="replace_from_warehouse"
                                id="reassignModeBtnReplace"
                                role="radio"
                                aria-checked="false">
                            <i class="fas fa-right-left" aria-hidden="true"></i>
                            <span>Замена со склада</span>
                        </button>
                    </div>
                    <p class="arm-reassign-mode-hint" id="reassignModeHint" role="note"></p>
                </section>

                <section class="arm-reassign-section arm-reassign-section--action" aria-labelledby="reassignStepParamsTitle">
                    <h6 class="arm-reassign-section__title arm-reassign-section__title--plain" id="reassignStepParamsTitle">
                        <i class="fas fa-pen-to-square arm-reassign-section__title-icon" aria-hidden="true"></i>
                        Параметры
                    </h6>

                    <div class="arm-reassign-params" id="moveComponentWrap" style="display:none;">
                        <div class="arm-reassign-move-component">
                            <div class="arm-reassign-params-bulk__head">
                                <span class="arm-reassign-params-bulk__icon" aria-hidden="true">
                                    <i class="fas fa-link"></i>
                                </span>
                                <div class="arm-reassign-params-bulk__head-text">
                                    <div class="arm-reassign-params-bulk__title">Привязка к системному блоку</div>
                                    <div class="arm-reassign-params-bulk__hint" id="moveComponentHint">
                                        Выберите компонент и укажите, к какому ПК его привязать
                                    </div>
                                </div>
                            </div>

                            <div class="arm-reassign-move-step" id="moveComponentSourceStep">
                                <div class="arm-reassign-move-step__label">
                                    <span class="arm-reassign-move-step__num">1</span>
                                    Что привязать
                                </div>
                                <div id="moveComponentSourceCard" class="arm-reassign-move-source"></div>
                                <div id="componentLinkTypeWrap" class="arm-reassign-move-type">
                                    <span class="arm-reassign-params-bulk__label">Тип компонента</span>
                                    <div class="arm-reassign-move-type__switch" role="radiogroup" aria-label="Тип компонента">
                                        <button type="button" class="arm-reassign-move-type__btn is-active" data-link-type="monitor" role="radio" aria-checked="true">
                                            <i class="fas fa-desktop" aria-hidden="true"></i>
                                            Монитор
                                        </button>
                                        <button type="button" class="arm-reassign-move-type__btn" data-link-type="ups" role="radio" aria-checked="false">
                                            <i class="fas fa-bolt" aria-hidden="true"></i>
                                            ИБП
                                        </button>
                                    </div>
                                    <select id="componentLinkType" class="d-none" aria-hidden="true" tabindex="-1">
                                        <option value="monitor" selected>Монитор</option>
                                        <option value="ups">ИБП</option>
                                    </select>
                                </div>
                                <div id="moveComponentChildWrap" class="arm-reassign-move-child" style="display:none;">
                                    <span class="arm-reassign-params-bulk__label" id="moveComponentChildLabel">Какие мониторы перенести</span>
                                    <div id="moveComponentChildList" class="arm-reassign-move-child__list" role="group" aria-labelledby="moveComponentChildLabel"></div>
                                    <select id="moveComponentChildId" class="d-none" multiple aria-hidden="true" tabindex="-1"></select>
                                    <small class="arm-reassign-params-bulk__hint" id="moveComponentChildHint">
                                        У выбранного ПК несколько мониторов — отметьте один или несколько для переноса.
                                    </small>
                                    <div class="arm-reassign-params-alert" id="moveComponentChildEmpty" style="display:none;">
                                        Нет привязанных мониторов у выбранного ПК. Выберите строку монитора в таблице или другой тип компонента.
                                    </div>
                                </div>
                            </div>

                            <div class="arm-reassign-move-step" id="moveComponentAttachWrap">
                                <div class="arm-reassign-move-step__label">
                                    <span class="arm-reassign-move-step__num">2</span>
                                    Куда привязать
                                </div>
                                <div class="arm-reassign-params-bulk__fields">
                                    <div class="arm-reassign-params-bulk__field js-user-select-field">
                                        <label class="arm-reassign-params-bulk__label" for="targetSystemBlockUserId">Владелец целевого ПК</label>
                                        <select id="targetSystemBlockUserId" class="form-select form-select-sm js-user-select-search" data-placeholder="Выберите пользователя">
                                            <option value="">— выберите пользователя —</option>
                                            <?php foreach ($users ?? [] as $uid => $uname): ?>
                                            <option value="<?= (int)$uid ?>"><?= Html::encode($uname) ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    <div class="arm-reassign-params-bulk__field">
                                        <label class="arm-reassign-params-bulk__label" for="targetSystemBlockId">Целевой системный блок</label>
                                        <select id="targetSystemBlockId" class="form-select form-select-sm">
                                            <option value="">— сначала выберите пользователя —</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="arm-reassign-params" id="warehouseMoveWrap" style="display:none;">
                        <div class="arm-reassign-params-bulk arm-reassign-warehouse-head">
                            <div class="arm-reassign-params-bulk__head">
                                <span class="arm-reassign-params-bulk__icon" aria-hidden="true">
                                    <i class="fas fa-warehouse"></i>
                                </span>
                                <div class="arm-reassign-params-bulk__head-text">
                                    <div class="arm-reassign-params-bulk__title">Складское помещение</div>
                                    <div class="arm-reassign-params-bulk__hint">Ответственный будет снят. Статус техники не меняется.</div>
                                </div>
                            </div>
                            <div class="arm-reassign-params-bulk__fields arm-reassign-params-bulk__fields--single">
                                <div class="arm-reassign-params-bulk__field js-user-select-field">
                                    <label class="arm-reassign-params-bulk__label" for="warehouseLocationId">Куда переместить <span class="text-danger">*</span></label>
                                    <select id="warehouseLocationId" class="form-select form-select-sm js-user-select-search" data-placeholder="Выберите склад">
                                        <option value="">— выберите склад —</option>
                                        <?php foreach ($warehouseLocations ?? [] as $wlid => $wlname): ?>
                                        <option value="<?= (int) $wlid ?>"><?= Html::encode($wlname) ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                    <?php if (empty($warehouseLocations)): ?>
                                    <p class="form-text text-warning mb-0">В справочнике нет помещений с типом «склад». Добавьте склад в разделе справочников.</p>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                        <div id="warehouseKitWrap" class="arm-reassign-warehouse-kit" style="display:none;">
                            <div class="arm-reassign-warehouse-kit__head">
                                <div class="arm-reassign-warehouse-kit__title">Что переместить на склад</div>
                                <div class="arm-reassign-warehouse-kit__hint">Отметьте системный блок, мониторы и ИБП комплекта</div>
                            </div>
                            <div id="warehouseKitList" class="arm-warehouse-kit-list"></div>
                        </div>
                    </div>

                    <div class="arm-reassign-params" id="replaceFromWarehouseWrap" style="display:none;">
                        <div class="arm-reassign-move-component">
                            <div class="arm-reassign-params-bulk__head">
                                <span class="arm-reassign-params-bulk__icon" aria-hidden="true">
                                    <i class="fas fa-right-left"></i>
                                </span>
                                <div class="arm-reassign-params-bulk__head-text">
                                    <div class="arm-reassign-params-bulk__title">Замена со склада</div>
                                    <div class="arm-reassign-params-bulk__hint">
                                        Новая единица встаёт на место старой. Старая уходит на склад с выбранным статусом.
                                    </div>
                                </div>
                            </div>

                            <div class="arm-reassign-move-step">
                                <div class="arm-reassign-move-step__label">
                                    <span class="arm-reassign-move-step__num">1</span>
                                    Что заменяем
                                </div>
                                <div id="replaceSourceCard" class="arm-reassign-move-source"></div>
                                <div id="replaceTargetList" class="arm-reassign-move-child__list" role="radiogroup" aria-label="Выберите заменяемую единицу"></div>
                                <input type="hidden" id="replaceTargetEquipmentId" value="">
                                <small class="arm-reassign-params-bulk__hint" id="replaceTargetHint" style="display:none;">
                                    В комплекте несколько единиц — выберите, что именно заменить со склада.
                                </small>
                            </div>

                            <div class="arm-reassign-move-step">
                                <div class="arm-reassign-move-step__label">
                                    <span class="arm-reassign-move-step__num">2</span>
                                    Статус заменяемой техники
                                </div>
                                <div class="arm-reassign-params-bulk__fields arm-reassign-params-bulk__fields--single">
                                    <div class="arm-reassign-params-bulk__field">
                                        <label class="arm-reassign-params-bulk__label" for="replacedStatusId">Новый статус</label>
                                        <select id="replacedStatusId" class="form-select form-select-sm">
                                            <option value="">— не менять —</option>
                                            <?php foreach ($statuses ?? [] as $sid => $sname): ?>
                                            <option value="<?= (int) $sid ?>"><?= Html::encode($sname) ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                        <small class="arm-reassign-params-bulk__hint">Укажите, только если нужно сменить статус (например, если техника вышла из строя).</small>
                                    </div>
                                    <div class="arm-reassign-params-bulk__field">
                                        <label class="arm-reassign-params-bulk__label" for="replacedDescription">Комментарий</label>
                                        <textarea id="replacedDescription" class="form-control form-control-sm" rows="5" placeholder="Текст комментария"></textarea>
                                        <small class="arm-reassign-params-bulk__hint">Текущий комментарий подставляется автоматически. Измените текст, если нужно обновить примечание.</small>
                                    </div>
                                </div>
                                <div id="replaceNetworkWrap" class="arm-reassign-params-bulk__fields" style="display:none;">
                                    <div class="arm-reassign-params-bulk__field">
                                        <label class="arm-reassign-params-bulk__label" for="replaceHostname">Имя компьютера</label>
                                        <input type="text" id="replaceHostname" class="form-control form-control-sm" maxlength="200" placeholder="Имя ПК" autocomplete="off">
                                    </div>
                                    <div class="arm-reassign-params-bulk__field">
                                        <label class="arm-reassign-params-bulk__label" for="replaceIpAddress">IP-адрес</label>
                                        <input type="text" id="replaceIpAddress" class="form-control form-control-sm" maxlength="100" placeholder="IP-адрес" autocomplete="off">
                                    </div>
                                    <small class="arm-reassign-params-bulk__hint">Подставляются с заменяемого системного блока и будут записаны на новую технику со склада.</small>
                                </div>
                            </div>

                            <div class="arm-reassign-move-step">
                                <div class="arm-reassign-move-step__label">
                                    <span class="arm-reassign-move-step__num">3</span>
                                    Чем заменить
                                </div>
                                <div class="arm-reassign-params-bulk__fields">
                                    <div class="arm-reassign-params-bulk__field js-user-select-field">
                                        <label class="arm-reassign-params-bulk__label" for="replaceWarehouseLocationId">Склад</label>
                                        <select id="replaceWarehouseLocationId" class="form-select form-select-sm js-user-select-search" data-placeholder="Все склады">
                                            <option value="">— все склады —</option>
                                            <?php foreach ($warehouseLocations ?? [] as $wlid => $wlname): ?>
                                            <option value="<?= (int) $wlid ?>"><?= Html::encode($wlname) ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    <div class="arm-reassign-params-bulk__field js-user-select-field">
                                        <label class="arm-reassign-params-bulk__label" for="replacementEquipmentId">Техника со склада <span class="text-danger">*</span></label>
                                        <select id="replacementEquipmentId" class="form-select form-select-sm js-user-select-search" data-placeholder="Выберите замену">
                                            <option value="">— выберите замену —</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="arm-reassign-panel arm-reassign-fields-stack" id="reassignCommonFieldsWrap">
                        <div id="reassignMultiEquipmentWrap" class="arm-reassign-params" style="display:none;">
                            <div class="arm-reassign-params-scroll" id="reassignParamsScroll">
                                <div class="arm-reassign-params-bulk" id="reassignParamsBulkBar">
                                    <div class="arm-reassign-params-bulk__head">
                                        <span class="arm-reassign-params-bulk__icon" aria-hidden="true">
                                            <i class="fas fa-layer-group"></i>
                                        </span>
                                        <div class="arm-reassign-params-bulk__head-text">
                                            <div class="arm-reassign-params-bulk__title">Применить к всей технике</div>
                                            <div class="arm-reassign-params-bulk__hint">Выберите значение и нажмите ✓ — оно проставится во все строки</div>
                                        </div>
                                    </div>
                                    <div class="arm-reassign-params-bulk__fields">
                                        <div class="arm-reassign-params-bulk__field js-user-select-field">
                                            <label class="arm-reassign-params-bulk__label" for="reassignBulkUserId">Ответственный</label>
                                            <div class="arm-reassign-params-bulk__control">
                                                <select id="reassignBulkUserId" class="form-select form-select-sm js-user-select-search" data-placeholder="Выберите значение">
                                                    <option value="">— не менять —</option>
                                                    <option value="0">— снять назначение —</option>
                                                    <?php foreach ($users ?? [] as $uid => $uname): ?>
                                                    <option value="<?= (int)$uid ?>"><?= Html::encode($uname) ?></option>
                                                    <?php endforeach; ?>
                                                </select>
                                                <button type="button" class="btn btn-sm arm-reassign-params-bulk__btn" id="reassignBulkUserApply" disabled title="Применить ко всей технике">
                                                    <i class="fas fa-check" aria-hidden="true"></i>
                                                </button>
                                            </div>
                                        </div>
                                        <div class="arm-reassign-params-bulk__field js-user-select-field">
                                            <label class="arm-reassign-params-bulk__label" for="reassignBulkLocationId">Помещение</label>
                                            <div class="arm-reassign-params-bulk__control">
                                                <select id="reassignBulkLocationId" class="form-select form-select-sm js-user-select-search" data-placeholder="Выберите значение">
                                                    <option value="">— не менять —</option>
                                                    <?php foreach ($locations ?? [] as $lid => $lname): ?>
                                                    <option value="<?= (int)$lid ?>"><?= Html::encode($lname) ?></option>
                                                    <?php endforeach; ?>
                                                </select>
                                                <button type="button" class="btn btn-sm arm-reassign-params-bulk__btn" id="reassignBulkLocationApply" disabled title="Применить ко всей технике">
                                                    <i class="fas fa-check" aria-hidden="true"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <table class="arm-reassign-params-table" id="reassignEquipmentParamsTable">
                                    <colgroup>
                                        <col class="arm-reassign-params-col arm-reassign-params-col--equip">
                                        <col class="arm-reassign-params-col arm-reassign-params-col--user">
                                        <col class="arm-reassign-params-col arm-reassign-params-col--loc">
                                        <col class="arm-reassign-params-col arm-reassign-params-col--net arm-reassign-params-table__net-col">
                                        <col class="arm-reassign-params-col arm-reassign-params-col--net arm-reassign-params-table__net-col">
                                    </colgroup>
                                    <thead>
                                        <tr>
                                            <th class="arm-reassign-params-table__th arm-reassign-params-table__th--equip">Техника</th>
                                            <th class="arm-reassign-params-table__th arm-reassign-params-table__th--user">Ответственный</th>
                                            <th class="arm-reassign-params-table__th arm-reassign-params-table__th--loc">Помещение</th>
                                            <th class="arm-reassign-params-table__th arm-reassign-params-table__th--net arm-reassign-params-table__net-col">Имя ПК</th>
                                            <th class="arm-reassign-params-table__th arm-reassign-params-table__th--net arm-reassign-params-table__net-col">IP-адрес</th>
                                        </tr>
                                    </thead>
                                    <tbody id="reassignEquipmentParamsList"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </section>

                    </div>
                </div>
            </div>
            <div class="modal-footer arm-reassign-modal__footer arm-op-modal__footer">
                <button type="button" class="btn arm-op-modal__btn arm-op-modal__btn--cancel" data-bs-dismiss="modal">Отмена</button>
                <button type="button" class="btn arm-op-modal__btn arm-op-modal__btn--primary arm-reassign-submit" id="reassignSubmit" disabled>
                    <span class="reassign-submit-text"><i class="fas fa-check" aria-hidden="true"></i> Применить</span>
                    <span class="reassign-submit-spinner" style="display: none;">
                        <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i> Сохранение…
                    </span>
                </button>
            </div>
        </div>
    </div>
</div>
<?php
$this->registerJs(
    "window.agGridArmDataUrl = " . json_encode(Url::to($gridDataRoute)) . ";" .
    "window.agGridArmExportUrl = " . json_encode(Url::to($exportRoute)) . ";" .
    "window.agGridArmLocationScope = " . json_encode($locationScope) . ";" .
    "window.agGridArmViewModalUrlTemplate = " . json_encode(Url::to(['/arm/view-modal', 'id' => '__ID__'])) . ";" .
    "window.agGridArmUpdateModalUrlTemplate = " . json_encode(Url::to(['/arm/update-modal', 'id' => '__ID__'])) . ";",
    \yii\web\View::POS_HEAD
);
$this->registerJs(
    "window.agGridArmCurrentTypeId = " . json_encode($defaultEquipmentTypeId) . ";" .
    "window.agGridArmHideAllEquipmentTab = " . ($hideAllEquipmentTab ? 'true' : 'false') . ";" .
    "window.agGridArmDefaultLimit = 20;" .
    "window.agGridArmReassignUrl = " . json_encode(Url::to(['arm/reassign'])) . ";" .
    "window.agGridArmReplaceOptionsUrl = " . json_encode(Url::to(['arm/replace-options'])) . ";" .
    "window.agGridArmSystemBlocksUrl = " . json_encode(Url::to(['arm/system-blocks'])) . ";" .
    "window.agGridArmUserPrimaryLocationUrl = " . json_encode(Url::to(['arm/user-primary-location'])) . ";" .
    "window.agGridArmImportPreviewUrl = " . json_encode(Url::to(['arm/import-preview'])) . ";" .
    "window.agGridArmImportApplyUrl = " . json_encode(Url::to(['arm/import-apply'])) . ";" .
    "window.agGridArmGetSelectedInfoUrl = " . json_encode(Url::to(['arm/get-selected-info'])) . ";" .
    "window.agGridArmColumnCatalog = " . json_encode(EquipmentCharCatalog::getArmGridColumnCatalog(), JSON_UNESCAPED_UNICODE) . ";" .
    "window.armReassignCsrf = {param: " . json_encode(Yii::$app->request->csrfParam) . ", token: " . json_encode(Yii::$app->request->csrfToken) . "};" .
    "window.armUsers = " . json_encode($users ?? []) . ";" .
    "window.armLocations = " . json_encode($locations ?? []) . ";" .
    "window.armStatuses = " . json_encode($statuses ?? []) . ";" .
    "window.armWarehouseLocations = " . json_encode($warehouseLocations ?? []) . ";" .
    ($locationScope === 'warehouse_only'
        ? "window.armIssueKitOptionsUrl = " . json_encode(Url::to(['warehouse/issue-kit-options'])) . ";" .
          "window.armIssueKitUrl = " . json_encode(Url::to(['warehouse/issue-kit'])) . ";"
        : ""),
    \yii\web\View::POS_HEAD
);
$this->registerJs("
(function(){
    var reassignModal, pendingIds = [], originalSelectionIds = [], equipmentData = [], equipmentSummary = {}, armSystemBlocksCache = {};
    var REASSIGN_MODE_HINTS = {
        move_to_warehouse: 'Выберите складское помещение. Ответственный будет снят, статус не меняется. Для комплекта ПК отметьте, что уходит на склад; связи между единицами будут сняты, каждая позиция станет независимой.',
        reassign: 'Измените ответственного, помещение или сетевые параметры ПК. При множественном выборе можно назначить разных ответственных и помещения. При переназначении системного блока связанные монитор и ИБП переназначаются вместе с ним.',
        move_component: 'Выберите компонент (шаг 1) и укажите владельца с целевым ПК (шаг 2).',
        replace_from_warehouse: 'Выберите единицу комплекта для замены, статус старой техники и замену со склада того же типа. Новая встанет на её место; старая уйдёт на склад.',
    };
    var warehouseSelectionIds = [];

    function getReassignHostItems() {
        if (!equipmentData || !equipmentData.length) {
            return [];
        }
        return equipmentData.filter(function(item) {
            return !!item.is_host;
        });
    }

    function formatEquipmentAssignTitle(item) {
        var title = (item && item.name) ? String(item.name) : ('ТС #' + ((item && item.id) || ''));
        if (item && item.inventory_number) {
            title += ' · № ' + item.inventory_number;
        }
        return title;
    }

    /**
     * Короткая метка типа для чипов в модалке.
     * is_host объединяет СБ/ноутбук/моноблок — для подписи нужен реальный тип.
     */
    function getEquipmentTypeChip(item) {
        if (!item) {
            return 'ТС';
        }
        var type = String(item.equipment_type || '').toLowerCase();
        var name = String(item.name || '').toLowerCase();
        var hay = type + ' ' + name;
        if (hay.indexOf('ноутбук') >= 0 || hay.indexOf('ноут') >= 0 || hay.indexOf('laptop') >= 0) {
            return 'НОУТ';
        }
        if (hay.indexOf('моноблок') >= 0 || hay.indexOf('monoblock') >= 0) {
            return 'МОНО';
        }
        if (hay.indexOf('сервер') >= 0 || hay.indexOf('server') >= 0) {
            return 'СЕРВ';
        }
        if (item.is_host) {
            if (type === 'пк' || type.indexOf('пк') === 0 || hay.indexOf('computer') >= 0) {
                return 'ПК';
            }
            return 'СБ';
        }
        if (hay.indexOf('ибп') >= 0 || hay.indexOf('ups') >= 0) {
            return 'ИБП';
        }
        if (hay.indexOf('монитор') >= 0 || hay.indexOf('monitor') >= 0) {
            return 'МОН';
        }
        if (item.equipment_type) {
            var raw = String(item.equipment_type).trim();
            return raw.length > 5 ? raw.substring(0, 4) : raw;
        }
        return 'ТС';
    }

    function isMultiEquipmentReassign() {
        return !!(equipmentData && equipmentData.length > 1);
    }

    /** Таблица параметров — для любой выборки в режиме обычного переназначения. */
    function usesReassignParamsTable() {
        return !!(equipmentData && equipmentData.length > 0);
    }

    function resolveReassignUserLabel(userId) {
        if (userId === '0') {
            return 'снять назначение';
        }
        if (userId === '' || userId == null) {
            return '';
        }
        return window.armUsers && window.armUsers[userId] ? window.armUsers[userId] : String(userId);
    }

    function buildUserSelectOptionsHtml(selectedValue) {
        var html = '<option value=\"\">— не менять —</option><option value=\"0\">— снять назначение —</option>';
        if (window.armUsers) {
            Object.keys(window.armUsers).forEach(function(uid) {
                var selected = String(selectedValue) === String(uid) ? ' selected' : '';
                html += '<option value=\"' + escapeHtml(uid) + '\"' + selected + '>' + escapeHtml(window.armUsers[uid]) + '</option>';
            });
        }
        return html;
    }

    function buildLocationSelectOptionsHtml(selectedValue) {
        var html = '<option value=\"\">— не менять —</option>';
        if (window.armLocations) {
            Object.keys(window.armLocations).forEach(function(lid) {
                var selected = String(selectedValue) === String(lid) ? ' selected' : '';
                html += '<option value=\"' + escapeHtml(lid) + '\"' + selected + '>' + escapeHtml(window.armLocations[lid]) + '</option>';
            });
        }
        return html;
    }

    function resolveReassignLocationLabel(locationId) {
        if (locationId === '' || locationId == null) {
            return '';
        }
        return window.armLocations && window.armLocations[locationId]
            ? window.armLocations[locationId]
            : String(locationId);
    }

    function formatEquipmentMetaLine(item) {
        var parts = [];
        if (item.responsible_user_name) {
            parts.push(item.responsible_user_name);
        }
        if (item.location_name) {
            parts.push(item.location_name);
        }
        if (item.status_name) {
            parts.push(item.status_name);
        }
        return parts.join(' · ');
    }

    function collectReassignUserRows() {
        var list = document.getElementById('reassignEquipmentParamsList');
        if (!list || !usesReassignParamsTable()) {
            return [];
        }
        var rows = [];
        list.querySelectorAll('[data-assign-equipment-id]').forEach(function(row) {
            var equipmentId = parseInt(row.getAttribute('data-assign-equipment-id'), 10);
            if (!(equipmentId > 0)) {
                return;
            }
            var selectEl = row.querySelector('.js-reassign-user');
            if (!selectEl) {
                return;
            }
            rows.push({
                id: equipmentId,
                title: row.getAttribute('data-assign-equipment-title') || ('ТС #' + equipmentId),
                userId: getSelectFieldValue(selectEl),
                originalUserId: selectEl.getAttribute('data-original-value') || ''
            });
        });
        return rows;
    }

    function getReassignUserChanges() {
        return collectReassignUserRows().filter(function(row) {
            return row.userId !== '' && row.userId !== row.originalUserId;
        });
    }

    function hasReassignUserChanges() {
        return getReassignUserChanges().length > 0;
    }

    function collectReassignLocationRows() {
        var list = document.getElementById('reassignEquipmentParamsList');
        if (!list || !usesReassignParamsTable()) {
            return [];
        }
        var rows = [];
        list.querySelectorAll('[data-assign-equipment-id]').forEach(function(row) {
            var equipmentId = parseInt(row.getAttribute('data-assign-equipment-id'), 10);
            if (!(equipmentId > 0)) {
                return;
            }
            var selectEl = row.querySelector('.js-reassign-location');
            if (!selectEl) {
                return;
            }
            rows.push({
                id: equipmentId,
                title: row.getAttribute('data-assign-equipment-title') || ('ТС #' + equipmentId),
                locationId: getSelectFieldValue(selectEl),
                originalLocationId: selectEl.getAttribute('data-original-value') || ''
            });
        });
        return rows;
    }

    function getReassignLocationChanges() {
        return collectReassignLocationRows().filter(function(row) {
            return row.locationId !== '' && row.locationId !== row.originalLocationId;
        });
    }

    function hasReassignLocationChanges() {
        return getReassignLocationChanges().length > 0;
    }

    function collectReassignNetworkRows() {
        var list = document.getElementById('reassignEquipmentParamsList');
        if (!list || !usesReassignParamsTable()) {
            return [];
        }
        var rows = [];
        list.querySelectorAll('[data-assign-equipment-id][data-is-host=\"1\"]').forEach(function(row) {
            var hostId = parseInt(row.getAttribute('data-assign-equipment-id'), 10);
            if (!(hostId > 0)) {
                return;
            }
            var hostnameEl = row.querySelector('.js-reassign-hostname');
            var ipEl = row.querySelector('.js-reassign-ip');
            if (!hostnameEl || !ipEl) {
                return;
            }
            rows.push({
                id: hostId,
                title: row.getAttribute('data-assign-equipment-title') || ('ПК #' + hostId),
                hostname: (hostnameEl.value || '').trim(),
                ip: (ipEl.value || '').trim(),
                originalHostname: (hostnameEl.getAttribute('data-original-value') || '').trim(),
                originalIp: (ipEl.getAttribute('data-original-value') || '').trim()
            });
        });
        return rows;
    }

    function getReassignNetworkChanges() {
        return collectReassignNetworkRows().filter(function(row) {
            return row.hostname !== row.originalHostname || row.ip !== row.originalIp;
        });
    }

    function hasReassignNetworkChanges() {
        return getReassignNetworkChanges().length > 0;
    }

    function hasReassignHostInSelection() {
        return !!(equipmentData && equipmentData.some(function(item) { return !!item.is_host; }));
    }

    function syncReassignNetworkColumnsVisibility() {
        var paramsWrap = document.getElementById('reassignMultiEquipmentWrap');
        var table = document.getElementById('reassignEquipmentParamsTable');
        var hasNetwork = hasReassignHostInSelection();
        if (paramsWrap) {
            paramsWrap.classList.toggle('arm-reassign-params--has-network', hasNetwork);
        }
        if (table) {
            table.classList.toggle('arm-reassign-params-table--has-network', hasNetwork);
        }
    }

    function syncReassignBulkApplyButtons() {
        var userBtn = document.getElementById('reassignBulkUserApply');
        var locBtn = document.getElementById('reassignBulkLocationApply');
        var bulkUser = document.getElementById('reassignBulkUserId');
        var bulkLoc = document.getElementById('reassignBulkLocationId');
        if (userBtn && bulkUser) {
            userBtn.disabled = getSelectFieldValue(bulkUser) === '';
        }
        if (locBtn && bulkLoc) {
            locBtn.disabled = getSelectFieldValue(bulkLoc) === '';
        }
    }

    function resetReassignBulkFields() {
        var bulkUser = document.getElementById('reassignBulkUserId');
        var bulkLoc = document.getElementById('reassignBulkLocationId');
        if (bulkUser) {
            setUserSelectValue(bulkUser, '');
        }
        if (bulkLoc) {
            setUserSelectValue(bulkLoc, '');
        }
        syncReassignBulkApplyButtons();
    }

    function applyBulkReassignUser() {
        var bulkSelect = document.getElementById('reassignBulkUserId');
        var list = document.getElementById('reassignEquipmentParamsList');
        if (!bulkSelect || !list) {
            return;
        }
        var value = getSelectFieldValue(bulkSelect);
        if (value === '') {
            return;
        }
        list.querySelectorAll('[data-assign-equipment-id]').forEach(function(row) {
            var userSelect = row.querySelector('.js-reassign-user');
            var locSelect = row.querySelector('.js-reassign-location');
            if (userSelect) {
                setUserSelectValue(userSelect, value);
            }
            if (value && value !== '0' && locSelect) {
                applyDefaultLocationForReassign(value, locSelect);
            }
        });
        scheduleUpdatePreview();
    }

    function applyBulkReassignLocation() {
        var bulkSelect = document.getElementById('reassignBulkLocationId');
        var list = document.getElementById('reassignEquipmentParamsList');
        if (!bulkSelect || !list) {
            return;
        }
        var value = getSelectFieldValue(bulkSelect);
        if (value === '') {
            return;
        }
        list.querySelectorAll('.js-reassign-location').forEach(function(selectEl) {
            setUserSelectValue(selectEl, value);
        });
        scheduleUpdatePreview();
    }

    function syncReassignMultiEquipmentCards(force) {
        var list = document.getElementById('reassignEquipmentParamsList');
        if (!list) {
            return;
        }

        var existingUsers = {};
        var existingLocations = {};
        var existingNetwork = {};
        if (!force) {
            collectReassignUserRows().forEach(function(row) {
                existingUsers[row.id] = row.userId;
            });
            collectReassignLocationRows().forEach(function(row) {
                existingLocations[row.id] = row.locationId;
            });
            collectReassignNetworkRows().forEach(function(row) {
                existingNetwork[row.id] = { hostname: row.hostname, ip: row.ip };
            });
        }
        if (window.IasUserSelect) {
            window.IasUserSelect.destroy(list);
        }

        var html = '';
        equipmentData.forEach(function(item) {
            var equipmentId = parseInt(item.id, 10);
            if (!(equipmentId > 0)) {
                return;
            }
            var title = formatEquipmentAssignTitle(item);
            var meta = formatEquipmentMetaLine(item);
            var chip = getEquipmentTypeChip(item);
            var originalUserId = item.responsible_user_id != null && item.responsible_user_id !== ''
                ? String(item.responsible_user_id)
                : '';
            var originalLocationId = item.location_id != null && item.location_id !== ''
                ? String(item.location_id)
                : '';
            var currentUserId = existingUsers[equipmentId] !== undefined ? existingUsers[equipmentId] : '';
            var currentLocationId = existingLocations[equipmentId] !== undefined ? existingLocations[equipmentId] : '';
            var rowClass = 'arm-reassign-params-table__row' + (item.is_host ? ' arm-reassign-params-table__row--host' : '');
            html += '<tr class=\"' + rowClass + '\" data-assign-equipment-id=\"' + equipmentId + '\"';
            html += ' data-assign-equipment-title=\"' + escapeHtml(title) + '\" data-is-host=\"' + (item.is_host ? '1' : '0') + '\">';
            html += '<td class=\"arm-reassign-params-table__cell arm-reassign-params-table__cell--equip\">';
            html += '<div class=\"arm-reassign-params-table__equip\">';
            html += '<span class=\"arm-reassign-params-table__chip\">' + escapeHtml(chip) + '</span>';
            html += '<div class=\"arm-reassign-params-table__equip-text\">';
            html += '<div class=\"arm-reassign-params-table__title\">' + escapeHtml(title) + '</div>';
            if (meta) {
                html += '<div class=\"arm-reassign-params-table__meta\">' + escapeHtml(meta) + '</div>';
            }
            html += '</div></div></td>';
            html += '<td class=\"arm-reassign-params-table__cell arm-reassign-params-table__cell--user js-user-select-field\">';
            html += '<select id=\"reassignUserId_' + equipmentId + '\" class=\"form-select form-select-sm js-user-select-search js-reassign-user\"';
            html += ' data-placeholder=\"— не менять —\" data-original-value=\"' + escapeHtml(originalUserId) + '\"';
            html += ' aria-label=\"Ответственный: ' + escapeHtml(title) + '\">';
            html += buildUserSelectOptionsHtml(currentUserId);
            html += '</select></td>';
            html += '<td class=\"arm-reassign-params-table__cell arm-reassign-params-table__cell--loc js-user-select-field\">';
            html += '<select id=\"reassignLocationId_' + equipmentId + '\" class=\"form-select form-select-sm js-user-select-search js-reassign-location\"';
            html += ' data-placeholder=\"— не менять —\" data-original-value=\"' + escapeHtml(originalLocationId) + '\"';
            html += ' aria-label=\"Помещение: ' + escapeHtml(title) + '\">';
            html += buildLocationSelectOptionsHtml(currentLocationId);
            html += '</select></td>';
            if (item.is_host) {
                var originalHostname = item.hostname || '';
                var originalIp = item.ip || '';
                var currentNetwork = existingNetwork[equipmentId];
                var hostnameVal = currentNetwork ? currentNetwork.hostname : originalHostname;
                var ipVal = currentNetwork ? currentNetwork.ip : originalIp;
                html += '<td class=\"arm-reassign-params-table__cell arm-reassign-params-table__cell--net arm-reassign-params-table__net-col\">';
                html += '<input type=\"text\" id=\"reassignHostname_' + equipmentId + '\" class=\"form-control form-control-sm js-reassign-hostname\" maxlength=\"200\"';
                html += ' placeholder=\"pc-ivanov\" autocomplete=\"off\"';
                html += ' data-original-value=\"' + escapeHtml(originalHostname) + '\" value=\"' + escapeHtml(hostnameVal) + '\"';
                html += ' aria-label=\"Имя ПК: ' + escapeHtml(title) + '\">';
                html += '</td><td class=\"arm-reassign-params-table__cell arm-reassign-params-table__cell--net arm-reassign-params-table__net-col\">';
                html += '<input type=\"text\" id=\"reassignIp_' + equipmentId + '\" class=\"form-control form-control-sm js-reassign-ip\" maxlength=\"100\"';
                html += ' placeholder=\"192.168.1.10\" autocomplete=\"off\"';
                html += ' data-original-value=\"' + escapeHtml(originalIp) + '\" value=\"' + escapeHtml(ipVal) + '\"';
                html += ' aria-label=\"IP-адрес: ' + escapeHtml(title) + '\">';
                html += '</td>';
            } else {
                html += '<td class=\"arm-reassign-params-table__cell arm-reassign-params-table__cell--net arm-reassign-params-table__net-col\">';
                html += '<span class=\"arm-reassign-params-table__na\">—</span></td>';
                html += '<td class=\"arm-reassign-params-table__cell arm-reassign-params-table__cell--net arm-reassign-params-table__net-col\">';
                html += '<span class=\"arm-reassign-params-table__na\">—</span></td>';
            }
            html += '</tr>';
        });
        list.innerHTML = html;
        syncReassignNetworkColumnsVisibility();
        syncReassignBulkApplyButtons();
    }

    function syncReassignHostNetworkFields(force) {
        // Сетевые поля теперь только в общей таблице параметров.
        return;
    }

    function syncReassignEquipmentParams(force) {
        var multiWrap = document.getElementById('reassignMultiEquipmentWrap');
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var useTable = mode === 'reassign' && usesReassignParamsTable();
        if (multiWrap) {
            multiWrap.style.display = useTable ? 'block' : 'none';
        }
        if (useTable) {
            syncReassignMultiEquipmentCards(force);
        } else {
            var multiList = document.getElementById('reassignEquipmentParamsList');
            if (multiList) {
                if (window.IasUserSelect) {
                    window.IasUserSelect.destroy(multiList);
                }
                if (force) {
                    multiList.innerHTML = '';
                }
            }
            syncReassignNetworkColumnsVisibility();
        }
    }

    function updateModeHint() {
        var el = document.getElementById('reassignModeHint');
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (el) {
            el.textContent = REASSIGN_MODE_HINTS[mode] || '';
        }
    }

    /** Перенос компонента: один ПК (с выбором монитора/ИБП) или одна строка монитора/ИБП. */
    function isMoveComponentModeAllowed() {
        if (pendingIds.length !== 1 || !equipmentData || equipmentData.length !== 1) {
            return false;
        }
        var item = equipmentData[0];
        if (item.is_host) {
            return true;
        }
        return !!(item.is_component || isMoveComponentEquipment(item));
    }

    /** Замена со склада: одна полевая единица — хост / монитор / ИБП (в т.ч. из комплекта). */
    function isReplaceFromWarehouseModeAllowed() {
        return getReplaceCandidates().length > 0;
    }

    function detectReplaceKindForItem(item) {
        if (!item) {
            return '';
        }
        if (item.replace_kind) {
            return item.replace_kind;
        }
        if (item.is_host) {
            return 'host';
        }
        if (isMoveComponentEquipment(item) || item.is_component) {
            return detectComponentLinkType(item) === 'ups' ? 'ups' : 'monitor';
        }
        return '';
    }

    /** Кандидаты на замену: выбранная единица + компоненты комплекта у хоста. */
    function getReplaceCandidates() {
        if (!equipmentData || equipmentData.length !== 1) {
            return [];
        }
        var item = equipmentData[0];
        if (item.is_on_warehouse) {
            return [];
        }
        var candidates = [];
        var seen = {};
        function pushCandidate(row) {
            if (!row || !row.id || !row.kind || seen[row.id]) {
                return;
            }
            seen[row.id] = true;
            candidates.push(row);
        }

        var kind = detectReplaceKindForItem(item);
        if (kind) {
            pushCandidate({
                id: parseInt(item.id, 10),
                kind: kind,
                equipment_type: item.equipment_type || '',
                name: item.name || '',
                inventory_number: item.inventory_number || '',
                description: item.description || '',
                hostname: item.hostname || '',
                ip: item.ip || '',
                chip: kind === 'host' ? getEquipmentTypeChip(item) : (kind === 'ups' ? 'ИБП' : 'МОН'),
                meta: formatEquipmentMetaLine(item),
            });
        }

        if (item.is_host && item.linked_components) {
            (item.linked_components.monitor || []).forEach(function(c) {
                pushCandidate({
                    id: parseInt(c.id, 10),
                    kind: 'monitor',
                    equipment_type: c.equipment_type || 'Монитор',
                    name: c.name || '',
                    inventory_number: c.inventory_number || '',
                    description: c.description || '',
                    hostname: '',
                    ip: '',
                    chip: 'МОН',
                    meta: '',
                });
            });
            (item.linked_components.ups || []).forEach(function(c) {
                pushCandidate({
                    id: parseInt(c.id, 10),
                    kind: 'ups',
                    equipment_type: c.equipment_type || 'ИБП',
                    name: c.name || '',
                    inventory_number: c.inventory_number || '',
                    description: c.description || '',
                    hostname: '',
                    ip: '',
                    chip: 'ИБП',
                    meta: '',
                });
            });
        }

        return candidates.filter(function(c) { return c.id > 0; });
    }

    function getSelectedReplaceTargetId() {
        var hidden = document.getElementById('replaceTargetEquipmentId');
        var fromHidden = hidden ? parseInt(hidden.value, 10) : 0;
        if (fromHidden > 0) {
            return fromHidden;
        }
        var list = document.getElementById('replaceTargetList');
        if (!list) {
            return 0;
        }
        var selected = list.querySelector('.arm-reassign-move-child__card.is-selected');
        return selected ? (parseInt(selected.getAttribute('data-replace-id'), 10) || 0) : 0;
    }

    function getSelectedReplaceTarget() {
        var id = getSelectedReplaceTargetId();
        if (!id) {
            return null;
        }
        var found = null;
        getReplaceCandidates().some(function(c) {
            if (c.id === id) {
                found = c;
                return true;
            }
            return false;
        });
        return found;
    }

    function getReplaceKindFromSelection() {
        var target = getSelectedReplaceTarget();
        return target ? target.kind : '';
    }

    function syncReplacePendingIds() {
        var target = getSelectedReplaceTarget();
        pendingIds = target ? [target.id] : [];
    }

    function syncReplacedDescriptionField() {
        var el = document.getElementById('replacedDescription');
        if (!el) {
            return;
        }
        var target = getSelectedReplaceTarget();
        var desc = target ? String(target.description || '') : '';
        el.value = desc;
        el.setAttribute('data-original', desc);
    }

    function isReplacedDescriptionChanged() {
        var el = document.getElementById('replacedDescription');
        if (!el) {
            return false;
        }
        return String(el.value || '') !== String(el.getAttribute('data-original') || '');
    }

    function syncReplaceNetworkFields() {
        var wrap = document.getElementById('replaceNetworkWrap');
        var hostnameEl = document.getElementById('replaceHostname');
        var ipEl = document.getElementById('replaceIpAddress');
        var target = getSelectedReplaceTarget();
        var isHost = !!(target && target.kind === 'host');
        if (wrap) {
            wrap.style.display = isHost ? '' : 'none';
        }
        if (!hostnameEl || !ipEl) {
            return;
        }
        if (!isHost) {
            hostnameEl.value = '';
            ipEl.value = '';
            hostnameEl.setAttribute('data-original', '');
            ipEl.setAttribute('data-original', '');
            return;
        }
        var hostname = String(target.hostname || '');
        var ip = String(target.ip || '');
        hostnameEl.value = hostname;
        ipEl.value = ip;
        hostnameEl.setAttribute('data-original', hostname);
        ipEl.setAttribute('data-original', ip);
    }

    function isReplaceNetworkChanged() {
        var hostnameEl = document.getElementById('replaceHostname');
        var ipEl = document.getElementById('replaceIpAddress');
        if (!hostnameEl || !ipEl) {
            return false;
        }
        var target = getSelectedReplaceTarget();
        if (!target || target.kind !== 'host') {
            return false;
        }
        return String(hostnameEl.value || '') !== String(hostnameEl.getAttribute('data-original') || '')
            || String(ipEl.value || '') !== String(ipEl.getAttribute('data-original') || '');
    }

    function setSelectedReplaceTarget(id, refreshOptions) {
        var hidden = document.getElementById('replaceTargetEquipmentId');
        var nextId = parseInt(id, 10) || 0;
        if (hidden) {
            hidden.value = nextId > 0 ? String(nextId) : '';
        }
        var list = document.getElementById('replaceTargetList');
        if (list) {
            list.querySelectorAll('.arm-reassign-move-child__card').forEach(function(card) {
                var isSelected = (parseInt(card.getAttribute('data-replace-id'), 10) || 0) === nextId;
                card.classList.toggle('is-selected', isSelected);
                card.setAttribute('aria-checked', isSelected ? 'true' : 'false');
            });
        }
        syncReplacePendingIds();
        syncReplacedDescriptionField();
        syncReplaceNetworkFields();
        if (refreshOptions) {
            fetchReplaceWarehouseOptions();
        } else {
            scheduleUpdatePreview();
        }
    }

    function formatReplaceCandidateTitle(candidate) {
        var title = (candidate.name || '').trim() || ('ТС #' + candidate.id);
        if (candidate.inventory_number) {
            title += ' · № ' + candidate.inventory_number;
        }
        return title;
    }

    function syncReplaceSourceCard() {
        var card = document.getElementById('replaceSourceCard');
        var list = document.getElementById('replaceTargetList');
        var hint = document.getElementById('replaceTargetHint');
        var hidden = document.getElementById('replaceTargetEquipmentId');
        if (!card) {
            return;
        }
        var candidates = getReplaceCandidates();
        if (candidates.length === 0) {
            card.innerHTML = '<div class=\"arm-reassign-move-source__empty\">Выберите полевую технику: СБ, ноутбук, моноблок, монитор или ИБП</div>';
            if (list) list.innerHTML = '';
            if (hint) hint.style.display = 'none';
            if (hidden) hidden.value = '';
            pendingIds = [];
            syncReplacedDescriptionField();
            syncReplaceNetworkFields();
            return;
        }

        var prevId = getSelectedReplaceTargetId();
        var prevStillValid = candidates.some(function(c) { return c.id === prevId; });
        var selectedId = prevStillValid ? prevId : (candidates.length === 1 ? candidates[0].id : 0);

        if (candidates.length === 1) {
            var only = candidates[0];
            card.style.display = '';
            card.innerHTML = '';
            var html = '<div class=\"arm-reassign-move-source__row\">';
            html += '<span class=\"arm-reassign-move-source__chip\">' + escapeHtml(only.chip) + '</span>';
            html += '<div class=\"arm-reassign-move-source__text\">';
            html += '<div class=\"arm-reassign-move-source__title\">' + escapeHtml(formatReplaceCandidateTitle(only)) + '</div>';
            if (only.meta) {
                html += '<div class=\"arm-reassign-move-source__meta\">' + escapeHtml(only.meta) + '</div>';
            }
            html += '<div class=\"arm-reassign-move-source__note\">Будет заменена техникой со склада того же типа</div>';
            html += '</div></div>';
            card.innerHTML = html;
            if (list) {
                list.innerHTML = '';
                list.style.display = 'none';
            }
            if (hint) hint.style.display = 'none';
        } else {
            card.style.display = 'none';
            card.innerHTML = '';
            if (list) {
                list.style.display = '';
                var listHtml = '';
                candidates.forEach(function(c) {
                    var isSelected = c.id === selectedId;
                    listHtml += '<button type=\"button\" class=\"arm-reassign-move-child__card' + (isSelected ? ' is-selected' : '') + '\"';
                    listHtml += ' data-replace-id=\"' + c.id + '\" data-replace-kind=\"' + escapeHtml(c.kind) + '\"';
                    listHtml += ' role=\"radio\" aria-checked=\"' + (isSelected ? 'true' : 'false') + '\">';
                    listHtml += '<span class=\"arm-reassign-move-child__check\" aria-hidden=\"true\"><i class=\"fas fa-check\"></i></span>';
                    listHtml += '<span class=\"arm-reassign-move-source__chip\">' + escapeHtml(c.chip) + '</span>';
                    listHtml += '<span class=\"arm-reassign-move-child__text\">';
                    listHtml += '<span class=\"arm-reassign-move-child__title\">' + escapeHtml(formatReplaceCandidateTitle(c)) + '</span>';
                    listHtml += '</span></button>';
                });
                list.innerHTML = listHtml;
            }
            if (hint) hint.style.display = 'block';
        }

        if (hidden) {
            hidden.value = selectedId > 0 ? String(selectedId) : '';
        }
        syncReplacePendingIds();
        syncReplacedDescriptionField();
        syncReplaceNetworkFields();
    }

    function reinitReplacementEquipmentSelect() {
        var select = document.getElementById('replacementEquipmentId');
        if (!select || !window.IasUserSelect) {
            return;
        }
        var field = select.closest('.js-user-select-field') || select.parentElement || select;
        window.IasUserSelect.destroy(field);
        window.IasUserSelect.init(field, { force: true });
    }

    function getReplacementEquipmentId() {
        return getSelectFieldValue(document.getElementById('replacementEquipmentId'));
    }

    function fetchReplaceWarehouseOptions() {
        var select = document.getElementById('replacementEquipmentId');
        var target = getSelectedReplaceTarget();
        if (!select || !window.agGridArmReplaceOptionsUrl) {
            return;
        }
        if (!target) {
            select.innerHTML = '<option value=\"\">— сначала выберите, что заменить —</option>';
            reinitReplacementEquipmentSelect();
            scheduleUpdatePreview();
            return;
        }
        var warehouseId = getSelectFieldValue(document.getElementById('replaceWarehouseLocationId'));
        if (!warehouseId) {
            var whEl = document.getElementById('replaceWarehouseLocationId');
            warehouseId = whEl ? (whEl.value || '') : '';
        }
        var prev = getReplacementEquipmentId() || select.value || '';
        select.innerHTML = '<option value=\"\">Загрузка…</option>';
        reinitReplacementEquipmentSelect();
        var base = window.agGridArmReplaceOptionsUrl;
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        var url = base + sep + 'kind=' + encodeURIComponent(target.kind)
            + '&match_equipment_id=' + encodeURIComponent(String(target.id));
        if (warehouseId) {
            url += '&warehouse_location_id=' + encodeURIComponent(warehouseId);
        }
        fetch(url)
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(res) {
                if (!res || !res.success) {
                    throw new Error((res && res.message) || 'Ошибка загрузки');
                }
                var items = res.items || [];
                var html = '<option value=\"\">— выберите замену —</option>';
                if (items.length === 0) {
                    html = '<option value=\"\">— на складе нет техники этого типа —</option>';
                }
                items.forEach(function(row) {
                    var id = String(row.id || '');
                    var label = row.label || ((row.name || '') + (row.inventory_number ? ' · ' + row.inventory_number : ''));
                    html += '<option value=\"' + escapeHtml(id) + '\">'
                        + escapeHtml(label) + '</option>';
                });
                select.innerHTML = html;
                var keepPrev = prev && items.some(function(row) { return String(row.id) === prev; });
                reinitReplacementEquipmentSelect();
                if (keepPrev) {
                    setUserSelectValue(select, prev, true);
                } else {
                    setUserSelectValue(select, '', true);
                }
                scheduleUpdatePreview();
            })
            .catch(function() {
                select.innerHTML = '<option value=\"\">— не удалось загрузить —</option>';
                reinitReplacementEquipmentSelect();
            });
    }

    function syncReplaceFromWarehouseUi(forceOptions) {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (mode !== 'replace_from_warehouse') {
            return;
        }
        syncReplaceSourceCard();
        if (forceOptions) {
            fetchReplaceWarehouseOptions();
        }
    }

    function syncModeButtonsUi(activeMode) {
        var mode = activeMode || ((document.getElementById('reassignOperationMode') || {}).value || 'reassign');
        document.querySelectorAll('#reassignArmModal .arm-reassign-mode-btn').forEach(function(btn) {
            var isActive = btn.getAttribute('data-mode') === mode;
            btn.classList.toggle('is-active', isActive);
            btn.setAttribute('aria-checked', isActive ? 'true' : 'false');
        });
    }

    function setOperationMode(mode, fireChanged) {
        var modeEl = document.getElementById('reassignOperationMode');
        if (!modeEl) {
            return;
        }
        var next = mode || 'reassign';
        var prev = modeEl.value || 'reassign';
        modeEl.value = next;
        syncModeButtonsUi(next);
        updateModeHint();
        if (fireChanged && prev !== next) {
            onModeChanged();
        } else if (fireChanged && prev === next) {
            // Даже при том же режиме обновляем UI/превью при сбросе недоступной опции
            applyOperationModeUi();
            updatePreview();
        }
    }

    function syncOperationModeOptions() {
        var modeEl = document.getElementById('reassignOperationMode');
        var linkBtn = document.getElementById('reassignModeBtnMoveComponent');
        var replaceBtn = document.getElementById('reassignModeBtnReplace');
        if (!modeEl) {
            return;
        }
        var linkAllowed = isMoveComponentModeAllowed();
        var replaceAllowed = isReplaceFromWarehouseModeAllowed();
        if (linkBtn) {
            linkBtn.disabled = !linkAllowed;
            linkBtn.classList.toggle('is-disabled', !linkAllowed);
            linkBtn.setAttribute('aria-disabled', linkAllowed ? 'false' : 'true');
            linkBtn.title = linkAllowed
                ? 'Привязка монитора или ИБП к системному блоку'
                : 'Доступно для одной единицы: ПК, монитор или ИБП';
        }
        if (replaceBtn) {
            replaceBtn.disabled = !replaceAllowed;
            replaceBtn.classList.toggle('is-disabled', !replaceAllowed);
            replaceBtn.setAttribute('aria-disabled', replaceAllowed ? 'false' : 'true');
            replaceBtn.title = replaceAllowed
                ? 'Замена выбранной техники (или компонента комплекта) единицей со склада'
                : 'Доступно для одной полевой единицы: СБ/ноутбук/моноблок, монитор или ИБП';
        }
        if (!linkAllowed && modeEl.value === 'move_component') {
            setOperationMode('reassign', true);
            return;
        }
        if (!replaceAllowed && modeEl.value === 'replace_from_warehouse') {
            setOperationMode('reassign', true);
            return;
        }
        syncModeButtonsUi(modeEl.value || 'reassign');
    }

    function syncComponentLinkTypeButtons() {
        var select = document.getElementById('componentLinkType');
        var type = select ? (select.value || 'monitor') : 'monitor';
        document.querySelectorAll('#moveComponentWrap .arm-reassign-move-type__btn').forEach(function(btn) {
            var isActive = btn.getAttribute('data-link-type') === type;
            btn.classList.toggle('is-active', isActive);
            btn.setAttribute('aria-checked', isActive ? 'true' : 'false');
        });
    }

    function setComponentLinkType(type, fireChanged) {
        var select = document.getElementById('componentLinkType');
        if (!select) {
            return;
        }
        var next = type === 'ups' ? 'ups' : 'monitor';
        var prev = select.value || 'monitor';
        select.value = next;
        syncComponentLinkTypeButtons();
        if (fireChanged && prev !== next) {
            select.dispatchEvent(new Event('change', { bubbles: true }));
        }
    }

    function syncMoveComponentSourceCard() {
        var card = document.getElementById('moveComponentSourceCard');
        var hint = document.getElementById('moveComponentHint');
        if (!card) {
            return;
        }
        if (!equipmentData || !equipmentData.length) {
            card.style.display = 'block';
            card.innerHTML = '<div class=\"arm-reassign-move-source__empty\">Выберите технику в таблице</div>';
            return;
        }
        var item = equipmentData[0];
        var isHost = !!item.is_host;
        if (hint) {
            hint.textContent = isHost
                ? 'Выберите тип компонента у этого ПК и укажите целевой системный блок'
                : 'Укажите владельца и целевой ПК для привязки выбранного компонента';
        }
        // Для выбранного СБ карточку не показываем — техника уже видна слева, достаточно выбора типа.
        if (isHost) {
            card.style.display = 'none';
            card.innerHTML = '';
            return;
        }
        card.style.display = 'block';
        var chip = detectComponentLinkType(item) === 'ups' ? 'ИБП' : 'МОН';
        var title = formatEquipmentAssignTitle(item);
        var meta = formatEquipmentMetaLine(item);
        var html = '<div class=\"arm-reassign-move-source__row\">';
        html += '<span class=\"arm-reassign-move-source__chip\">' + escapeHtml(chip) + '</span>';
        html += '<div class=\"arm-reassign-move-source__text\">';
        html += '<div class=\"arm-reassign-move-source__title\">' + escapeHtml(title) + '</div>';
        if (meta) {
            html += '<div class=\"arm-reassign-move-source__meta\">' + escapeHtml(meta) + '</div>';
        }
        html += '<div class=\"arm-reassign-move-source__note\">Компонент будет привязан к другому системному блоку</div>';
        html += '</div></div>';
        card.innerHTML = html;
    }

    function syncComponentLinkTypeField() {
        var wrap = document.getElementById('componentLinkTypeWrap');
        var select = document.getElementById('componentLinkType');
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (!wrap || !select) {
            return;
        }
        if (mode !== 'move_component') {
            wrap.style.display = 'none';
            return;
        }
        if (equipmentData && equipmentData.length === 1) {
            var item = equipmentData[0];
            if (item.is_component || isMoveComponentEquipment(item)) {
                setComponentLinkType(detectComponentLinkType(item), false);
                wrap.style.display = 'none';
                syncMoveComponentSourceCard();
                return;
            }
        }
        wrap.style.display = 'block';
        syncComponentLinkTypeButtons();
        syncMoveComponentSourceCard();
    }

    function formatSystemBlockOptionLabel(row) {
        if (!row) {
            return '—';
        }
        var name = String(row.name || '').trim();
        var inv = String(row.inventory_number || '').trim();
        var serial = String(row.serial_number || '').trim();
        var meta = [];
        if (inv) {
            meta.push('инв. № ' + inv);
        }
        if (serial) {
            meta.push('сер. № ' + serial);
        }
        if (name && meta.length) {
            return name + ' (' + meta.join(', ') + ')';
        }
        if (name) {
            return name;
        }
        if (meta.length) {
            return meta.join(', ');
        }
        return '—';
    }

    function renderSystemBlocks(rows) {
        var sbSelect = document.getElementById('targetSystemBlockId');
        if (!sbSelect) return;
        var html = '<option value=\"\">— выберите системный блок —</option>';
        rows.forEach(function(row) {
            var label = formatSystemBlockOptionLabel(row);
            var locId = row.location_id != null && row.location_id !== '' ? String(row.location_id) : '';
            html += '<option value=\"' + escapeHtml(String(row.id)) + '\"' + (locId ? ' data-location-id=\"' + escapeHtml(locId) + '\"' : '') + '>' + escapeHtml(label) + '</option>';
        });
        sbSelect.innerHTML = html;
        if (rows.length === 1) {
            sbSelect.value = String(rows[0].id);
            applyDefaultLocationFromTargetSystemBlock();
            scheduleUpdatePreview();
        }
    }

    /** В режиме move_component: ответственный = владелец целевого ПК. */
    function setUserSelectValue(selectEl, value, silent) {
        if (!selectEl) return;
        if (window.IasUserSelect && window.IasUserSelect.setValue) {
            window.IasUserSelect.setValue(selectEl, value, !!silent);
        } else {
            selectEl.value = value == null ? '' : String(value);
            if (!silent) {
                selectEl.dispatchEvent(new Event('change', { bubbles: true }));
            }
        }
    }

    function getSelectFieldValue(selectEl) {
        if (!selectEl) {
            return '';
        }
        if (window.IasUserSelect && window.IasUserSelect.getValue) {
            return window.IasUserSelect.getValue(selectEl) || '';
        }
        return selectEl.value || '';
    }

    function updateReassignModalSelectState() {
        // Поля ответственного находятся в таблице параметров.
    }

    function applyDefaultResponsibleForMoveComponent(targetUserId) {
        // Ответственный при переносе компонента берётся из владельца целевого СБ.
        return;
    }

    /** Помещение по наиболее частому location_id техники пользователя. */
    function applyPrimaryLocationForUser(userId, locationSelectEl) {
        if (!userId || userId === '0') return;
        var loc = locationSelectEl || null;
        if (!loc || !window.agGridArmUserPrimaryLocationUrl) return;
        var base = window.agGridArmUserPrimaryLocationUrl;
        var sep = base.indexOf('?') >= 0 ? '&' : '?';
        return fetch(base + sep + 'user_id=' + encodeURIComponent(userId))
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(res) {
                if (res && res.success && res.location_id != null && String(res.location_id) !== '') {
                    setUserSelectValue(loc, String(res.location_id), true);
                }
                scheduleUpdatePreview();
            })
            .catch(function() {});
    }

    /** Помещение = location_id целевого ПК; если у ПК нет помещения — по пользователю-владельцу. */
    function applyDefaultLocationFromTargetSystemBlock() {
        scheduleUpdatePreview();
    }

    function applyMoveComponentUserDefaults(userId) {
        if (!userId) return;
        applyDefaultResponsibleForMoveComponent(userId);
        scheduleUpdatePreview();
    }

    /** Обычное переназначение: помещение по «основному» для выбранного ответственного (по учёту ТС). */
    function applyDefaultLocationForReassign(userId, locationSelectEl) {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (mode !== 'reassign') return;
        applyPrimaryLocationForUser(userId, locationSelectEl);
    }

    function normalizeEquipmentTypeLabel(item) {
        return String((item && (item.equipment_type || item.name)) || '').toLowerCase();
    }

    function isMoveComponentEquipment(item) {
        var t = normalizeEquipmentTypeLabel(item);
        return t.indexOf('монитор') !== -1 || t.indexOf('monitor') !== -1
            || t.indexOf('ибп') !== -1 || t.indexOf('ups') !== -1;
    }

    function detectComponentLinkType(item) {
        var t = normalizeEquipmentTypeLabel(item);
        if (t.indexOf('ибп') !== -1 || t.indexOf('ups') !== -1) {
            return 'ups';
        }
        return 'monitor';
    }

    function formatMoveComponentOptionLabel(component) {
        var name = (component.name || '').trim() || 'без названия';
        var inv = (component.inventory_number || '').trim();
        return name + (inv ? ' · № ' + inv : '');
    }

    function getMoveComponentCandidates() {
        var linkType = (document.getElementById('componentLinkType') || {}).value || 'monitor';
        var candidates = [];
        var seen = {};
        equipmentData.forEach(function(item) {
            if (item.is_host && item.linked_components) {
                var list = item.linked_components[linkType] || [];
                var hostLabel = (item.name || item.inventory_number || '').trim();
                list.forEach(function(c) {
                    var cid = c && c.id != null ? parseInt(c.id, 10) : 0;
                    if (cid > 0 && !seen[cid]) {
                        seen[cid] = true;
                        candidates.push({
                            id: cid,
                            name: c.name || '',
                            inventory_number: c.inventory_number || '',
                            host_label: hostLabel,
                        });
                    }
                });
            } else if (item.is_component || isMoveComponentEquipment(item)) {
                if (detectComponentLinkType(item) !== linkType) {
                    return;
                }
                var id = parseInt(item.id, 10);
                if (id > 0 && !seen[id]) {
                    seen[id] = true;
                    candidates.push({
                        id: id,
                        name: item.name || '',
                        inventory_number: item.inventory_number || '',
                        host_label: '',
                    });
                }
            }
        });
        return candidates;
    }

    function updateMoveComponentChildLabels() {
        var linkType = (document.getElementById('componentLinkType') || {}).value || 'monitor';
        var label = document.getElementById('moveComponentChildLabel');
        var hint = document.getElementById('moveComponentChildHint');
        var isUps = linkType === 'ups';
        if (label) {
            label.textContent = isUps ? 'Какие ИБП перенести' : 'Какие мониторы перенести';
        }
        if (hint) {
            hint.textContent = isUps
                ? 'У выбранного ПК несколько ИБП — отметьте один или несколько для переноса.'
                : 'У выбранного ПК несколько мониторов — отметьте один или несколько для переноса.';
        }
        var emptyMsg = document.getElementById('moveComponentChildEmpty');
        if (emptyMsg) {
            emptyMsg.textContent = isUps
                ? 'Нет привязанных ИБП у выбранного ПК. Выберите строку ИБП в таблице или другой тип компонента.'
                : 'Нет привязанных мониторов у выбранного ПК. Выберите строку монитора в таблице или другой тип компонента.';
        }
    }

    function getSelectedMoveComponentIdsFromUi() {
        var list = document.getElementById('moveComponentChildList');
        var select = document.getElementById('moveComponentChildId');
        var ids = [];
        if (list) {
            list.querySelectorAll('.arm-reassign-move-child__card.is-selected').forEach(function(card) {
                var id = parseInt(card.getAttribute('data-child-id'), 10);
                if (id > 0) {
                    ids.push(id);
                }
            });
        }
        if (ids.length === 0 && select) {
            Array.prototype.forEach.call(select.options || [], function(opt) {
                if (opt.selected) {
                    var id = parseInt(opt.value, 10);
                    if (id > 0) {
                        ids.push(id);
                    }
                }
            });
        }
        return ids;
    }

    function syncMoveComponentChildSelect(selectedIds) {
        var select = document.getElementById('moveComponentChildId');
        if (!select) {
            return;
        }
        var selectedMap = {};
        (selectedIds || []).forEach(function(id) {
            selectedMap[String(id)] = true;
        });
        Array.prototype.forEach.call(select.options || [], function(opt) {
            opt.selected = !!selectedMap[String(opt.value)];
        });
    }

    /** Список переносимых компонентов: при нескольких мониторах/ИБП — множественный выбор. */
    function syncMoveComponentChildPicker() {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var wrap = document.getElementById('moveComponentChildWrap');
        var select = document.getElementById('moveComponentChildId');
        var list = document.getElementById('moveComponentChildList');
        var emptyMsg = document.getElementById('moveComponentChildEmpty');
        var hint = document.getElementById('moveComponentChildHint');
        if (mode !== 'move_component' || !wrap || !select) {
            if (wrap) wrap.style.display = 'none';
            return;
        }
        updateMoveComponentChildLabels();
        syncMoveComponentSourceCard();
        var candidates = getMoveComponentCandidates();
        if (emptyMsg) {
            emptyMsg.style.display = candidates.length === 0 ? 'block' : 'none';
        }
        if (hint) {
            hint.style.display = candidates.length > 1 ? 'block' : 'none';
        }
        if (candidates.length === 0) {
            wrap.style.display = 'block';
            select.innerHTML = '';
            if (list) {
                list.innerHTML = '';
            }
            pendingIds = [];
            return;
        }
        if (candidates.length === 1) {
            wrap.style.display = 'none';
            select.innerHTML = '';
            var onlyOpt = document.createElement('option');
            onlyOpt.value = String(candidates[0].id);
            onlyOpt.selected = true;
            select.appendChild(onlyOpt);
            if (list) {
                list.innerHTML = '';
            }
            pendingIds = [candidates[0].id];
            return;
        }
        wrap.style.display = 'block';
        var prevSelected = {};
        getSelectedMoveComponentIdsFromUi().forEach(function(id) {
            prevSelected[id] = true;
        });
        var hadPrev = Object.keys(prevSelected).length > 0;
        var hasOverlap = hadPrev && candidates.some(function(c) {
            return !!prevSelected[parseInt(c.id, 10)];
        });
        select.innerHTML = '';
        var selectedIds = [];
        var cardsHtml = '';
        var chip = ((document.getElementById('componentLinkType') || {}).value || 'monitor') === 'ups' ? 'ИБП' : 'МОН';
        candidates.forEach(function(c) {
            var id = String(c.id);
            var isSelected = hasOverlap ? !!prevSelected[parseInt(id, 10)] : false;
            var opt = document.createElement('option');
            opt.value = id;
            opt.textContent = formatMoveComponentOptionLabel(c);
            opt.selected = isSelected;
            select.appendChild(opt);
            if (isSelected) {
                selectedIds.push(parseInt(id, 10));
            }
            cardsHtml += '<button type=\"button\" class=\"arm-reassign-move-child__card' + (isSelected ? ' is-selected' : '') + '\"';
            cardsHtml += ' data-child-id=\"' + escapeHtml(id) + '\" role=\"checkbox\" aria-checked=\"' + (isSelected ? 'true' : 'false') + '\">';
            cardsHtml += '<span class=\"arm-reassign-move-child__check\" aria-hidden=\"true\"><i class=\"fas fa-check\"></i></span>';
            cardsHtml += '<span class=\"arm-reassign-move-source__chip\">' + chip + '</span>';
            cardsHtml += '<span class=\"arm-reassign-move-child__text\">';
            cardsHtml += '<span class=\"arm-reassign-move-child__title\">' + escapeHtml(formatMoveComponentOptionLabel(c)) + '</span>';
            cardsHtml += '</span></button>';
        });
        if (list) {
            list.innerHTML = cardsHtml;
        }
        pendingIds = selectedIds.slice();
    }

    function formatWarehouseComponentLabel(component, typeLabel) {
        var name = (component.name || '').trim() || 'без названия';
        var inv = (component.inventory_number || '').trim();
        return typeLabel + ' — ' + name + (inv ? ' (№ ' + inv + ')' : '');
    }

    function hasWarehouseKitHosts() {
        return equipmentData.some(function(item) {
            return item.is_host && item.linked_components && (
                (item.linked_components.monitor && item.linked_components.monitor.length > 0)
                || (item.linked_components.ups && item.linked_components.ups.length > 0)
            );
        }) || equipmentData.some(function(item) {
            return item.is_host;
        });
    }

    function renderWarehouseKitPicker() {
        var wrap = document.getElementById('warehouseKitWrap');
        var list = document.getElementById('warehouseKitList');
        if (!wrap || !list) {
            return;
        }
        var hosts = equipmentData.filter(function(item) { return item.is_host; });
        if (hosts.length === 0) {
            wrap.style.display = 'none';
            list.innerHTML = '';
            warehouseSelectionIds = originalSelectionIds.slice();
            pendingIds = warehouseSelectionIds.slice();
            return;
        }
        wrap.style.display = 'block';
        var html = '';
        hosts.forEach(function(host) {
            var hostId = parseInt(host.id, 10);
            var hostLabel = (host.name || host.inventory_number || ('ПК #' + hostId)).trim();
            var hostMeta = formatEquipmentMetaLine(host);
            html += '<article class=\"arm-warehouse-kit-card arm-warehouse-kit-card--host\">';
            html += '<label class=\"arm-warehouse-kit-row\" for=\"warehouse-kit-host-' + hostId + '\">';
            html += '<input type=\"checkbox\" class=\"form-check-input\" id=\"warehouse-kit-host-' + hostId + '\"';
            html += ' data-warehouse-id=\"' + hostId + '\" checked>';
            html += '<span class=\"arm-warehouse-kit-row__chip\">' + escapeHtml(getEquipmentTypeChip(host)) + '</span>';
            html += '<span class=\"arm-warehouse-kit-row__body\">';
            html += '<span class=\"arm-warehouse-kit-row__title\">' + escapeHtml(hostLabel) + '</span>';
            if (hostMeta) {
                html += '<span class=\"arm-warehouse-kit-row__meta\">' + escapeHtml(hostMeta) + '</span>';
            }
            html += '</span></label>';
            var lc = host.linked_components || {};
            (lc.monitor || []).forEach(function(c) {
                var cid = parseInt(c.id, 10);
                var childName = (c.name || '').trim() || 'без названия';
                var childInv = (c.inventory_number || '').trim();
                var childTitle = childName + (childInv ? ' · № ' + childInv : '');
                html += '<label class=\"arm-warehouse-kit-row arm-warehouse-kit-row--child\">';
                html += '<input type=\"checkbox\" class=\"form-check-input\" data-warehouse-id=\"' + cid + '\" checked>';
                html += '<span class=\"arm-warehouse-kit-row__chip arm-warehouse-kit-row__chip--mon\">МОН</span>';
                html += '<span class=\"arm-warehouse-kit-row__body\">';
                html += '<span class=\"arm-warehouse-kit-row__title\">' + escapeHtml(childTitle) + '</span>';
                html += '</span></label>';
            });
            (lc.ups || []).forEach(function(c) {
                var cid = parseInt(c.id, 10);
                var childName = (c.name || '').trim() || 'без названия';
                var childInv = (c.inventory_number || '').trim();
                var childTitle = childName + (childInv ? ' · № ' + childInv : '');
                html += '<label class=\"arm-warehouse-kit-row arm-warehouse-kit-row--child\">';
                html += '<input type=\"checkbox\" class=\"form-check-input\" data-warehouse-id=\"' + cid + '\" checked>';
                html += '<span class=\"arm-warehouse-kit-row__chip arm-warehouse-kit-row__chip--ups\">ИБП</span>';
                html += '<span class=\"arm-warehouse-kit-row__body\">';
                html += '<span class=\"arm-warehouse-kit-row__title\">' + escapeHtml(childTitle) + '</span>';
                html += '</span></label>';
            });
            html += '</article>';
        });
        list.innerHTML = html;
        syncWarehouseSelectionIds();
    }

    function syncWarehouseSelectionIds() {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (mode !== 'move_to_warehouse') {
            return;
        }
        if (!equipmentData || equipmentData.length === 0) {
            pendingIds = originalSelectionIds.slice();
            return;
        }
        var ids = [];
        var seen = {};
        equipmentData.forEach(function(item) {
            if (item.is_host) {
                return;
            }
            var id = parseInt(item.id, 10);
            if (id > 0 && !seen[id]) {
                seen[id] = true;
                ids.push(id);
            }
        });
        var kitList = document.getElementById('warehouseKitList');
        if (kitList) {
            kitList.querySelectorAll('input[data-warehouse-id]:checked').forEach(function(input) {
                var id = parseInt(input.getAttribute('data-warehouse-id'), 10);
                if (id > 0 && !seen[id]) {
                    seen[id] = true;
                    ids.push(id);
                }
            });
        } else {
            equipmentData.forEach(function(item) {
                if (!item.is_host) {
                    return;
                }
                var id = parseInt(item.id, 10);
                if (id > 0 && !seen[id]) {
                    seen[id] = true;
                    ids.push(id);
                }
            });
        }
        warehouseSelectionIds = ids;
        pendingIds = ids.slice();
    }

    function initReassignModalSelect2(scope) {
        if (!window.IasUserSelect) {
            return;
        }
        var root = scope || document.getElementById('reassignArmModal');
        if (!root) {
            return;
        }
        window.IasUserSelect.init(root, { force: true });
    }

    /** Показ/скрытие блоков формы без сброса выбранных id до загрузки данных. */
    function applyOperationModeUi() {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var moveWrap = document.getElementById('moveComponentWrap');
        var warehouseWrap = document.getElementById('warehouseMoveWrap');
        var replaceWrap = document.getElementById('replaceFromWarehouseWrap');
        var commonWrap = document.getElementById('reassignCommonFieldsWrap');
        updateModeHint();
        syncComponentLinkTypeField();
        if (moveWrap) {
            moveWrap.style.display = mode === 'move_component' ? 'block' : 'none';
        }
        if (warehouseWrap) {
            warehouseWrap.style.display = mode === 'move_to_warehouse' ? 'block' : 'none';
        }
        if (replaceWrap) {
            replaceWrap.style.display = mode === 'replace_from_warehouse' ? 'block' : 'none';
        }
        if (commonWrap) {
            commonWrap.style.display = (mode === 'move_component' || mode === 'move_to_warehouse' || mode === 'replace_from_warehouse')
                ? 'none'
                : 'block';
        }
        if (mode === 'replace_from_warehouse') {
            syncReplaceFromWarehouseUi(false);
        }
        syncReassignEquipmentParams(false);
        updateReassignModalSelectState();
    }

    function configureModalFromSelectedEquipment() {
        if (!equipmentData || !equipmentData.length) return;
        var modeEl = document.getElementById('reassignOperationMode');
        if (!modeEl) return;
        syncOperationModeOptions();
        if (modeEl.value === 'move_component' && !isMoveComponentModeAllowed()) {
            setOperationMode('reassign', false);
        }
        if (modeEl.value === 'replace_from_warehouse' && !isReplaceFromWarehouseModeAllowed()) {
            setOperationMode('reassign', false);
        }
        applyOperationModeUi();
        syncMoveComponentChildPicker();
        renderWarehouseKitPicker();
        syncWarehouseSelectionIds();
        syncReassignEquipmentParams(true);
        var modalEl = document.getElementById('reassignArmModal');
        if (modalEl && modalEl.classList.contains('show')) {
            if (modeEl.value === 'move_to_warehouse') {
                initReassignModalSelect2(document.getElementById('warehouseMoveWrap'));
            } else if (modeEl.value === 'move_component') {
                initReassignModalSelect2(document.getElementById('moveComponentWrap'));
            } else if (modeEl.value === 'replace_from_warehouse') {
                initReassignModalSelect2(document.getElementById('replaceFromWarehouseWrap'));
                syncReplaceFromWarehouseUi(true);
            } else {
                initReassignModalSelect2(document.getElementById('reassignCommonFieldsWrap'));
            }
            bindReassignModalSelectHandlers();
            syncMoveComponentBlocksIfNeeded();
        }
    }

    function fetchSystemBlocksForUser(userId) {
        var sbSelect = document.getElementById('targetSystemBlockId');
        if (!sbSelect) return;
        if (!userId) {
            sbSelect.innerHTML = '<option value=\"\">— сначала выберите пользователя —</option>';
            return;
        }
        if (armSystemBlocksCache[userId]) {
            renderSystemBlocks(armSystemBlocksCache[userId]);
            applyMoveComponentUserDefaults(userId);
            return;
        }
        sbSelect.innerHTML = '<option value=\"\">Загрузка...</option>';
        var baseUrl = window.agGridArmSystemBlocksUrl || '';
        var sep = baseUrl.indexOf('?') >= 0 ? '&' : '?';
        var url = baseUrl + sep + 'user_id=' + encodeURIComponent(userId);
        fetch(url)
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (!result || !result.success) {
                    throw new Error((result && result.message) || 'Ошибка загрузки списка');
                }
                var rows = Array.isArray(result.data) ? result.data : [];
                armSystemBlocksCache[userId] = rows;
                renderSystemBlocks(rows);
                applyMoveComponentUserDefaults(userId);
            })
            .catch(function(err) {
                console.error('Ошибка загрузки системных блоков:', err);
                sbSelect.innerHTML = '<option value=\"\">Ошибка загрузки списка</option>';
            });
    }
    
    // Загрузка информации о выбранных единицах техники
    function loadSelectedEquipmentInfo(ids) {
        var infoContainer = document.getElementById('reassignEquipmentList');
        var countSpan = document.getElementById('reassignEquipmentCount');
        
        if (!infoContainer || !countSpan) return;
        
        infoContainer.innerHTML = '<div class=\"arm-reassign-equipment-list__loading text-center text-muted py-3\"><i class=\"fas fa-circle-notch fa-spin\" aria-hidden=\"true\"></i> Загрузка данных…</div>';
        countSpan.textContent = String(ids.length);
        
        var fd = new FormData();
        fd.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
        ids.forEach(function(id) { fd.append('ids[]', id); });
        
        fetch(window.agGridArmGetSelectedInfoUrl, { method: 'POST', body: fd })
            .then(function(r) { return r.ok ? r.json() : Promise.reject(new Error('HTTP ' + r.status)); })
            .then(function(result) {
                if (result.success && result.data) {
                    equipmentData = result.data;
                    equipmentSummary = result.summary || {};
                    pendingIds = originalSelectionIds.slice();
                    console.log('Данные о выбранных единицах загружены:', equipmentData.length, 'единиц');
                    renderEquipmentInfo();
                    syncMoveComponentChildPicker();
                    configureModalFromSelectedEquipment();
                    // Обновляем предпросмотр после загрузки данных - с небольшой задержкой для надежности
                    setTimeout(function() {
                        // Проверяем, что модальное окно все еще открыто
                        var modal = document.getElementById('reassignArmModal');
                        if (modal && modal.classList.contains('show')) {
                            updatePreview();
                        }
                    }, 50);
                } else {
                    console.error('Ошибка загрузки данных:', result.message || 'Неизвестная ошибка');
                    infoContainer.innerHTML = '<div class=\"alert alert-danger mb-0\">Не удалось загрузить данные: ' + escapeHtml(result.message || 'Неизвестная ошибка') + '</div>';
                    // Все равно пытаемся обновить предпросмотр, если модальное окно открыто
                    setTimeout(function() {
                        var modal = document.getElementById('reassignArmModal');
                        if (modal && modal.classList.contains('show')) {
                            updatePreview();
                        }
                    }, 50);
                }
            })
            .catch(function(err) {
                console.error('Ошибка загрузки информации о технике:', err);
                infoContainer.innerHTML = '<div class=\"alert alert-danger mb-0\">Не удалось загрузить данные: ' + escapeHtml(err.message) + '</div>';
                // Все равно пытаемся обновить предпросмотр
                setTimeout(function() {
                    updatePreview();
                }, 50);
            });
    }
    
    function getLinkedComponentsForDisplay(item) {
        if (!item || !item.is_host || !item.linked_components) {
            return [];
        }
        var out = [];
        var lc = item.linked_components;
        (lc.monitor || []).forEach(function(c) {
            out.push({ type: 'Монитор', component: c });
        });
        (lc.ups || []).forEach(function(c) {
            out.push({ type: 'ИБП', component: c });
        });
        return out;
    }

    function countDisplayEquipmentUnits() {
        var total = 0;
        equipmentData.forEach(function(item) {
            total += 1 + getLinkedComponentsForDisplay(item).length;
        });
        return total;
    }

    function updateEquipmentCountBadge() {
        var countSpan = document.getElementById('reassignEquipmentCount');
        if (countSpan) {
            countSpan.textContent = String(countDisplayEquipmentUnits());
        }
    }

    function formatMetaLine(item, emptyMuted) {
        var parts = [
            item.responsible_user_name ? escapeHtml(item.responsible_user_name) : emptyMuted,
            item.location_name ? escapeHtml(item.location_name) : emptyMuted,
            item.status_name ? escapeHtml(item.status_name) : emptyMuted,
        ];
        return parts.join(' · ');
    }

    function renderLinkedLines(item) {
        var linked = getLinkedComponentsForDisplay(item);
        if (!linked.length) {
            return '';
        }
        var lines = linked.map(function(row) {
            var c = row.component || {};
            return '<li class=\"arm-op-card__linked-item\">' + escapeHtml(row.type) + ' — ' + escapeHtml(c.name || '—') + '</li>';
        });
        return '<ul class=\"arm-op-card__linked\">' + lines.join('') + '</ul>';
    }

    function renderEquipmentItemCard(item, emptyMuted) {
        var chip = escapeHtml(getEquipmentTypeChip(item));
        var cardClass = 'arm-op-card' + (item.is_host ? ' arm-op-card--host' : '');
        var metaParts = [
            item.responsible_user_name ? escapeHtml(item.responsible_user_name) : emptyMuted,
            item.location_name ? escapeHtml(item.location_name) : emptyMuted,
            item.status_name ? escapeHtml(item.status_name) : emptyMuted,
        ];
        var inv = item.inventory_number ? ' · № ' + escapeHtml(item.inventory_number) : '';
        var html = '<article class=\"' + cardClass + '\">';
        html += '<span class=\"arm-op-card__chip\">' + chip + '</span>';
        html += '<div class=\"arm-op-card__body\">';
        html += '<div class=\"arm-op-card__title\">' + escapeHtml(item.name || '—') + inv + '</div>';
        html += '<div class=\"arm-op-card__meta\">' + metaParts.join(' · ') + '</div>';
        html += renderLinkedLines(item);
        html += '</div></article>';
        return html;
    }

    // Отображение информации о выбранных единицах техники
    function renderEquipmentInfo() {
        var container = document.getElementById('reassignEquipmentList');
        if (!container) return;
        
        if (equipmentData.length === 0) {
            container.innerHTML = '<div class=\"arm-op-aside__empty\">'
                + '<i class=\"fas fa-desktop\" aria-hidden=\"true\"></i>'
                + '<span class=\"arm-op-aside__empty-text\">Выберите технику в таблице</span>'
                + '</div>';
            updateEquipmentCountBadge();
            return;
        }
        
        var html = '<div class=\"arm-op-card-list\">';
        var emptyMuted = '<span class=\"arm-eq-item__empty\">не указано</span>';
        updateEquipmentCountBadge();

        equipmentData.forEach(function(item) {
            html += renderEquipmentItemCard(item, emptyMuted);
        });

        html += '</div>';
        container.innerHTML = html;
    }
    
    function renderOpChangeRow(change) {
        if (!change) {
            return '';
        }
        if (typeof change === 'string') {
            return '<li class=\"arm-op-change\"><span class=\"arm-op-change__body\"><span class=\"arm-op-change__to\">'
                + escapeHtml(change) + '</span></span></li>';
        }
        var mutedClass = change.muted ? ' arm-op-change--muted' : '';
        var html = '<li class=\"arm-op-change' + mutedClass + '\">';
        if (change.label) {
            html += '<span class=\"arm-op-change__label\">' + escapeHtml(change.label) + '</span>';
        }
        html += '<span class=\"arm-op-change__body\">';
        if (change.from) {
            html += '<span class=\"arm-op-change__from\">' + escapeHtml(change.from) + '</span>';
            html += '<i class=\"fas fa-arrow-right arm-op-change__arrow\" aria-hidden=\"true\"></i>';
        }
        html += '<span class=\"arm-op-change__to\">' + escapeHtml(change.to || '') + '</span>';
        if (change.hint) {
            html += '<span class=\"arm-op-change__hint\">' + escapeHtml(change.hint) + '</span>';
        }
        html += '</span></li>';
        return html;
    }

    function renderOpChangesEmpty(message) {
        return '<li class=\"arm-op-change arm-op-change--muted\">'
            + '<span class=\"arm-op-change__label\">Ожидание</span>'
            + '<span class=\"arm-op-change__body\"><span class=\"arm-op-change__to\">' + escapeHtml(message) + '</span></span>'
            + '</li>';
    }

    // Обновление предпросмотра изменений
    function updatePreview() {
        // Проверяем, что модальное окно открыто и видимо
        var modal = document.getElementById('reassignArmModal');
        if (!modal) {
            console.warn('updatePreview: модальное окно не найдено');
            return;
        }
        
        // Проверяем, что модальное окно видимо (Bootstrap modal)
        // Используем проверку класса 'show' вместо внутреннего состояния Bootstrap
        // НО: не завершаем выполнение, если модальное окно не видимо - просто не обновляем предпросмотр
        // Это позволяет обновить состояние кнопки даже если модальное окно закрывается
        var isModalVisible = modal.classList.contains('show');
        
        var submitBtn = document.getElementById('reassignSubmit');
        if (!submitBtn) {
            console.warn('updatePreview: кнопка сохранения не найдена');
            return;
        }
        
        // Предпросмотр - ищем элементы внутри модального окна
        // Сначала пытаемся найти через getElementById
        var previewDiv = document.getElementById('reassignPreview');
        var previewList = document.getElementById('reassignPreviewList');
        
        // Если не найдены, пытаемся найти внутри модального окна
        if (!previewDiv || !previewList) {
            if (modal) {
                previewDiv = modal.querySelector('#reassignPreview');
                previewList = modal.querySelector('#reassignPreviewList');
            }
        }
        
        // Если все еще не найдены, пытаемся найти через querySelector в document
        if (!previewDiv || !previewList) {
            previewDiv = document.querySelector('#reassignPreview');
            previewList = document.querySelector('#reassignPreviewList');
        }
        
        // Если элементы предпросмотра не найдены, пытаемся найти их снова (на случай, если DOM еще не обновлен)
        // Делаем несколько попыток с небольшой задержкой, если элементы не найдены
        if ((!previewDiv || !previewList) && isModalVisible) {
            // Если модальное окно видимо, но элементы не найдены, пытаемся еще раз через небольшую задержку
            setTimeout(function() {
                var retryModal = document.getElementById('reassignArmModal');
                if (!retryModal || !retryModal.classList.contains('show')) {
                    return; // Модальное окно закрыто
                }
                
                var retryPreviewDiv = retryModal.querySelector('#reassignPreview') || document.getElementById('reassignPreview');
                var retryPreviewList = retryModal.querySelector('#reassignPreviewList') || document.getElementById('reassignPreviewList');
                
                if (retryPreviewDiv && retryPreviewList) {
                    // Элементы найдены, обновляем предпросмотр
                    // Рекурсивно вызываем updatePreview, но только один раз
                    if (!window.updatePreviewRetryInProgress) {
                        window.updatePreviewRetryInProgress = true;
                        updatePreview();
                        window.updatePreviewRetryInProgress = false;
                    }
                } else {
                    console.warn('updatePreview: элементы предпросмотра не найдены после повторной попытки', {
                        previewDiv: !!retryPreviewDiv,
                        previewList: !!retryPreviewList,
                        modalExists: !!retryModal,
                        modalVisible: retryModal && retryModal.classList.contains('show')
                    });
                }
            }, 100);
        }
        
        if (!previewDiv || !previewList) {
            console.warn('updatePreview: элементы предпросмотра не найдены, пропускаем обновление предпросмотра', {
                previewDiv: !!previewDiv,
                previewList: !!previewList,
                isModalVisible: isModalVisible,
                modalExists: !!modal
            });
            // Продолжаем выполнение, чтобы обновить состояние кнопки
        }
        
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        
        console.log('updatePreview called: mode=', mode, 'equipmentData.length=', equipmentData.length);
        
        var changes = [];
        var hasAnyChange = false;

        // Обычное переназначение: ответственный / помещение / сеть
        if (mode === 'reassign') {
            getReassignUserChanges().forEach(function(row) {
                hasAnyChange = true;
                changes.push({
                    label: isMultiEquipmentReassign() ? ('Ответственный · ' + row.title) : 'Ответственный',
                    from: row.originalUserId ? resolveReassignUserLabel(row.originalUserId) : null,
                    to: resolveReassignUserLabel(row.userId)
                });
            });

            getReassignLocationChanges().forEach(function(row) {
                hasAnyChange = true;
                changes.push({
                    label: isMultiEquipmentReassign() ? ('Помещение · ' + row.title) : 'Помещение',
                    from: row.originalLocationId ? resolveReassignLocationLabel(row.originalLocationId) : null,
                    to: resolveReassignLocationLabel(row.locationId)
                });
            });

            if (hasReassignNetworkChanges()) {
                hasAnyChange = true;
                getReassignNetworkChanges().forEach(function(row) {
                    var multiHosts = getReassignHostItems().length > 1;
                    if (row.hostname !== row.originalHostname) {
                        changes.push({
                            label: multiHosts ? ('Имя ПК · ' + row.title) : 'Имя компьютера',
                            from: row.originalHostname || null,
                            to: row.hostname || '—'
                        });
                    }
                    if (row.ip !== row.originalIp) {
                        changes.push({
                            label: multiHosts ? ('IP · ' + row.title) : 'IP-адрес',
                            from: row.originalIp || null,
                            to: row.ip || '—'
                        });
                    }
                });
            }
        } else if (mode === 'move_component') {
            syncMoveComponentChildPicker();
            var moveCandidates = getMoveComponentCandidates();
            var targetSystemBlockId = (document.getElementById('targetSystemBlockId') || {}).value || '';
            var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
            if (moveCandidates.length > 0 && pendingIds.length > 0) {
                hasAnyChange = targetSystemBlockUserId !== '' && targetSystemBlockId !== '';
                if (hasAnyChange) {
                    var targetSbLabel = '';
                    var sbEl = document.getElementById('targetSystemBlockId');
                    if (sbEl && sbEl.selectedIndex >= 0) {
                        targetSbLabel = (sbEl.options[sbEl.selectedIndex].text || '').trim();
                    }
                    changes.push({
                        label: 'Привязка',
                        to: targetSbLabel || 'выбранный системный блок',
                        hint: pendingIds.length + ' ед.'
                    });
                }
            }
        } else if (mode === 'move_to_warehouse') {
            syncWarehouseSelectionIds();
            var warehouseLocId = getSelectFieldValue(document.getElementById('warehouseLocationId'));
            hasAnyChange = warehouseLocId !== '' && pendingIds.length > 0;
            if (hasAnyChange) {
                var whName = window.armWarehouseLocations && window.armWarehouseLocations[warehouseLocId]
                    ? window.armWarehouseLocations[warehouseLocId]
                    : 'склад';
                var oldWhLocations = [];
                equipmentData.forEach(function(item) {
                    if (item.location_name && oldWhLocations.indexOf(item.location_name) === -1) {
                        oldWhLocations.push(item.location_name);
                    }
                });
                changes.push({
                    label: 'Помещение',
                    from: oldWhLocations.length > 0 ? oldWhLocations.join(', ') : null,
                    to: whName,
                    hint: pendingIds.length + ' ед.'
                });
                changes.push({
                    label: 'Ответственный',
                    to: 'снят',
                    hint: pendingIds.length + ' ед.'
                });
            }
        } else if (mode === 'replace_from_warehouse') {
            syncReplacePendingIds();
            var replaceTarget = getSelectedReplaceTarget();
            var replacedStatusId = (document.getElementById('replacedStatusId') || {}).value || '';
            var replacementId = getReplacementEquipmentId();
            hasAnyChange = !!replaceTarget && replacementId !== '';
            if (hasAnyChange) {
                var statusLabel = '';
                var statusEl = document.getElementById('replacedStatusId');
                if (statusEl && statusEl.selectedIndex >= 0) {
                    statusLabel = (statusEl.options[statusEl.selectedIndex].text || '').trim();
                }
                var replacementLabel = '';
                var replEl = document.getElementById('replacementEquipmentId');
                if (replEl) {
                    if (typeof jQuery !== 'undefined' && jQuery(replEl).hasClass('select2-hidden-accessible')) {
                        var selectedData = jQuery(replEl).select2('data');
                        if (selectedData && selectedData[0] && selectedData[0].text) {
                            replacementLabel = String(selectedData[0].text || '').trim();
                        }
                    }
                    if (!replacementLabel && replEl.selectedIndex >= 0) {
                        replacementLabel = (replEl.options[replEl.selectedIndex].text || '').trim();
                    }
                }
                changes.push({
                    label: 'Замена',
                    from: formatReplaceCandidateTitle(replaceTarget),
                    to: replacementLabel || ('ТС #' + replacementId)
                });
                if (replacedStatusId !== '') {
                    changes.push({
                        label: 'Статус старой',
                        from: (equipmentData[0] && equipmentData[0].status_name) || null,
                        to: statusLabel || replacedStatusId
                    });
                }
                if (isReplacedDescriptionChanged()) {
                    var descEl = document.getElementById('replacedDescription');
                    var newDesc = descEl ? String(descEl.value || '').trim() : '';
                    var oldDesc = descEl ? String(descEl.getAttribute('data-original') || '').trim() : '';
                    changes.push({
                        label: 'Комментарий',
                        from: oldDesc || null,
                        to: newDesc || 'очищен'
                    });
                }
                if (replaceTarget.kind === 'host') {
                    var hostnameEl = document.getElementById('replaceHostname');
                    var ipEl = document.getElementById('replaceIpAddress');
                    var nextHostname = hostnameEl ? String(hostnameEl.value || '').trim() : '';
                    var nextIp = ipEl ? String(ipEl.value || '').trim() : '';
                    var prevHostname = hostnameEl ? String(hostnameEl.getAttribute('data-original') || '').trim() : '';
                    var prevIp = ipEl ? String(ipEl.getAttribute('data-original') || '').trim() : '';
                    if (nextHostname !== prevHostname || nextHostname !== '') {
                        changes.push({
                            label: 'Имя ПК (новая)',
                            from: prevHostname || null,
                            to: nextHostname || '—'
                        });
                    }
                    if (nextIp !== prevIp || nextIp !== '') {
                        changes.push({
                            label: 'IP (новая)',
                            from: prevIp || null,
                            to: nextIp || '—'
                        });
                    }
                }
                changes.push({
                    label: 'Старая техника',
                    to: 'на склад'
                });
            }
        }
        
        console.log('updatePreview: hasAnyChange=', hasAnyChange, 'changes.length=', changes.length, 'equipmentData.length=', equipmentData.length);
        
        if (hasAnyChange) {
            // Если есть хотя бы одно изменение, активируем кнопку
            submitBtn.disabled = false;
            console.log('Кнопка активирована, так как есть изменения');
            
            // Обновляем предпросмотр только если элементы найдены И модальное окно видимо
            if (previewDiv && previewList && isModalVisible) {
                previewDiv.classList.remove('arm-reassign-preview--hidden');

                if (changes.length > 0) {
                    previewList.innerHTML = changes.map(renderOpChangeRow).join('');
                } else if (equipmentData.length > 0) {
                    previewList.innerHTML = renderOpChangesEmpty('Изменения будут применены ко всей выбранной технике');
                } else {
                    previewList.innerHTML = renderOpChangesEmpty('Загрузка данных…');
                }
            } else {
                console.warn('Предпросмотр не обновлен:', {
                    previewDiv: !!previewDiv,
                    previewList: !!previewList,
                    isModalVisible: isModalVisible
                });
            }
        } else {
            // Нет изменений - блокируем кнопку
            submitBtn.disabled = true;
            console.log('Кнопка деактивирована, так как нет изменений');
            
            // Показываем пустое состояние превью слева
            if (previewDiv && previewList && isModalVisible) {
                previewDiv.classList.remove('arm-reassign-preview--hidden');
                previewList.innerHTML = renderOpChangesEmpty('Укажите параметры справа');
            }
        }
        
        console.log('updatePreview: hasAnyChange=', hasAnyChange, 'changes.length=', changes.length, 'equipmentData.length=', equipmentData.length, 'submitBtn.disabled=', submitBtn.disabled);
    }
    
    // Валидация формы
    function validateForm() {
        var modeEl = document.getElementById('reassignOperationMode');
        var mode = modeEl ? modeEl.value : 'reassign';
        var targetSystemBlockId = (document.getElementById('targetSystemBlockId') || {}).value || '';
        var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
        if (mode === 'move_component') {
            syncMoveComponentChildPicker();
            if (getMoveComponentCandidates().length === 0 || pendingIds.length === 0) {
                return false;
            }
            return targetSystemBlockUserId !== '' && targetSystemBlockId !== '';
        }
        if (mode === 'move_to_warehouse') {
            syncWarehouseSelectionIds();
            var warehouseLoc = getSelectFieldValue(document.getElementById('warehouseLocationId'));
            return warehouseLoc !== '' && pendingIds.length > 0;
        }
        if (mode === 'replace_from_warehouse') {
            var replacementId = getReplacementEquipmentId();
            syncReplacePendingIds();
            return isReplaceFromWarehouseModeAllowed()
                && !!getSelectedReplaceTarget()
                && replacementId !== '';
        }
        return hasReassignUserChanges()
            || hasReassignLocationChanges()
            || hasReassignNetworkChanges();
    }

    function onModeChanged() {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var moveWrap = document.getElementById('moveComponentWrap');
        var warehouseWrap = document.getElementById('warehouseMoveWrap');
        var replaceWrap = document.getElementById('replaceFromWarehouseWrap');
        var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
        if (window.IasUserSelect) {
            if (mode !== 'move_component' && moveWrap) {
                window.IasUserSelect.destroy(moveWrap);
            }
            if (mode !== 'move_to_warehouse' && warehouseWrap) {
                window.IasUserSelect.destroy(warehouseWrap);
            }
            if (mode !== 'replace_from_warehouse' && replaceWrap) {
                window.IasUserSelect.destroy(replaceWrap);
            }
        }
        applyOperationModeUi();
        if (mode === 'move_to_warehouse' && equipmentData.length > 0) {
            renderWarehouseKitPicker();
            syncWarehouseSelectionIds();
        } else if (mode === 'move_to_warehouse') {
            pendingIds = originalSelectionIds.slice();
        }
        if (mode === 'replace_from_warehouse') {
            syncReplaceFromWarehouseUi(true);
        }
        if (mode === 'move_component' && targetSystemBlockUserId !== '') {
            applyMoveComponentUserDefaults(targetSystemBlockUserId);
            fetchSystemBlocksForUser(targetSystemBlockUserId);
        } else if (mode === 'move_component') {
            var sb = document.getElementById('targetSystemBlockId');
            if (sb) {
                sb.innerHTML = '<option value=\"\">— сначала выберите пользователя —</option>';
            }
        }
        if (mode === 'move_component') {
            applyDefaultLocationFromTargetSystemBlock();
        }
        if (mode === 'reassign') {
            syncReassignEquipmentParams(true);
        }
        var modalEl = document.getElementById('reassignArmModal');
        if (modalEl && modalEl.classList.contains('show')) {
            if (mode === 'move_to_warehouse') {
                initReassignModalSelect2(warehouseWrap);
            } else if (mode === 'move_component') {
                initReassignModalSelect2(moveWrap);
            } else if (mode === 'replace_from_warehouse') {
                initReassignModalSelect2(replaceWrap);
            } else {
                initReassignModalSelect2(document.getElementById('reassignCommonFieldsWrap'));
            }
            bindReassignModalSelectHandlers();
            syncMoveComponentBlocksIfNeeded();
        }
        syncMoveComponentChildPicker();
        updatePreview();
    }
    
    // Показ уведомления
    function showNotification(message, type) {
        type = type || 'success';
        var alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        var alertHtml = '<div class=\"alert ' + alertClass + ' alert-dismissible fade show\" role=\"alert\" style=\"position: fixed; top: 20px; right: 20px; z-index: 9999; min-width: 300px;\">' +
            escapeHtml(message) +
            '<button type=\"button\" class=\"btn-close\" data-bs-dismiss=\"alert\" aria-label=\"Закрыть\"></button>' +
            '</div>';
        var alertDiv = document.createElement('div');
        alertDiv.innerHTML = alertHtml;
        document.body.appendChild(alertDiv.firstElementChild);
        setTimeout(function() {
            var alert = document.querySelector('.alert');
            if (alert) {
                var bsAlert = new bootstrap.Alert(alert);
                bsAlert.close();
            }
        }, 5000);
    }
    
    // Отправка данных
    // Функция для восстановления состояния кнопки
    function resetSubmitButton() {
        var submitBtn = document.getElementById('reassignSubmit');
        if (!submitBtn) return;
        var submitText = submitBtn.querySelector('.reassign-submit-text');
        var submitSpinner = submitBtn.querySelector('.reassign-submit-spinner');
        if (submitText) submitText.style.display = 'inline';
        if (submitSpinner) submitSpinner.style.display = 'none';
        submitBtn.disabled = false;
    }
    
    function submitReassign() {
        var submitBtn = document.getElementById('reassignSubmit');
        if (!submitBtn) {
            console.error('Кнопка submitReassign не найдена');
            return;
        }
        
        var submitText = submitBtn.querySelector('.reassign-submit-text');
        var submitSpinner = submitBtn.querySelector('.reassign-submit-spinner');
        
        // Проверяем наличие изменений
        var operationMode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var hasFormChanges = validateForm();
        var targetSystemBlockId = (document.getElementById('targetSystemBlockId') || {}).value || '';
        var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
        var componentLinkType = (document.getElementById('componentLinkType') || {}).value || '';
        console.log('submitReassign: pendingIds.length=', pendingIds.length);
        
        if (!hasFormChanges) {
            console.warn('Нет изменений для сохранения');
            showNotification('Выберите хотя бы одно поле для изменения.', 'error');
            return;
        }
        
        if (pendingIds.length === 0) {
            console.error('Нет выбранных единиц техники для сохранения');
            showNotification('Ошибка: не выбраны единицы техники для сохранения', 'error');
            return;
        }
        
        // Проверяем, не заблокирована ли кнопка (но не останавливаем выполнение, если есть изменения)
        if (submitBtn.disabled && !hasFormChanges) {
            console.warn('Кнопка заблокирована и нет изменений');
            showNotification('Выберите хотя бы одно поле для изменения.', 'error');
            return;
        }
        if (operationMode === 'move_component') {
            syncMoveComponentChildPicker();
            if (getMoveComponentCandidates().length === 0) {
                showNotification('У выбранного ПК нет привязанных мониторов или ИБП для переноса.', 'error');
                return;
            }
            if (pendingIds.length === 0) {
                showNotification('Отметьте один или несколько мониторов/ИБП для переноса.', 'error');
                return;
            }
            if (!targetSystemBlockUserId || !targetSystemBlockId) {
                showNotification('Для привязки выберите владельца и целевой системный блок.', 'error');
                return;
            }
        }
        if (operationMode === 'move_to_warehouse') {
            syncWarehouseSelectionIds();
            var warehouseLocSubmit = getSelectFieldValue(document.getElementById('warehouseLocationId'));
            if (!warehouseLocSubmit) {
                showNotification('Выберите складское помещение.', 'error');
                return;
            }
            if (pendingIds.length === 0) {
                showNotification('Отметьте оборудование для перемещения на склад.', 'error');
                return;
            }
        }
        if (operationMode === 'replace_from_warehouse') {
            syncReplacePendingIds();
            var replaceTargetSubmit = getSelectedReplaceTarget();
            var replacementSubmit = getReplacementEquipmentId();
            if (!isReplaceFromWarehouseModeAllowed()) {
                showNotification('Замена со склада доступна для одной полевой единицы: СБ, монитор или ИБП.', 'error');
                return;
            }
            if (!replaceTargetSubmit) {
                showNotification('Выберите, какую единицу комплекта заменить.', 'error');
                return;
            }
            if (!replacementSubmit) {
                showNotification('Выберите технику со склада для замены.', 'error');
                return;
            }
            pendingIds = [replaceTargetSubmit.id];
        }
        
        // Сохраняем состояние кнопки перед отправкой
        submitBtn.disabled = true;
        if (submitText) submitText.style.display = 'none';
        if (submitSpinner) submitSpinner.style.display = 'inline';
        
        var fd = new FormData();
        fd.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
        pendingIds.forEach(function(id) { fd.append('ids[]', id); });
        fd.append('operation_mode', operationMode);
        
        if (operationMode === 'move_to_warehouse') {
            var warehouseLocId = getSelectFieldValue(document.getElementById('warehouseLocationId'));
            fd.append('location_id', warehouseLocId);
        } else if (operationMode === 'replace_from_warehouse') {
            fd.append('replacement_equipment_id', getReplacementEquipmentId());
            fd.append('replaced_status_id', (document.getElementById('replacedStatusId') || {}).value || '');
            if (isReplacedDescriptionChanged()) {
                fd.append('replaced_description_changed', '1');
                fd.append('replaced_description', (document.getElementById('replacedDescription') || {}).value || '');
            }
            var replaceTargetForNet = getSelectedReplaceTarget();
            if (replaceTargetForNet && replaceTargetForNet.kind === 'host') {
                fd.append('network_profile_changed', '1');
                fd.append('hostname', (document.getElementById('replaceHostname') || {}).value || '');
                fd.append('ip', (document.getElementById('replaceIpAddress') || {}).value || '');
            }
            var replaceWhLoc = getSelectFieldValue(document.getElementById('replaceWarehouseLocationId'));
            if (replaceWhLoc) {
                fd.append('location_id', replaceWhLoc);
            }
        } else if (operationMode === 'move_component') {
            fd.append('link_action', 'attach');
            fd.append('link_type', componentLinkType);
            if (targetSystemBlockUserId !== '') {
                fd.append('responsible_user_id', targetSystemBlockUserId === '0' ? '' : targetSystemBlockUserId);
            }
            fd.append('target_system_block_id', targetSystemBlockId);
        } else if (operationMode === 'reassign' && hasReassignUserChanges()) {
            fd.append('responsible_users_changed', '1');
            getReassignUserChanges().forEach(function(row) {
                fd.append('responsible_users[' + row.id + ']', row.userId);
            });
        }
        if (operationMode === 'reassign' && hasReassignLocationChanges()) {
            fd.append('locations_changed', '1');
            getReassignLocationChanges().forEach(function(row) {
                fd.append('locations[' + row.id + ']', row.locationId);
            });
        }
        if (operationMode === 'reassign' && hasReassignNetworkChanges()) {
            fd.append('network_profile_changed', '1');
            getReassignNetworkChanges().forEach(function(row) {
                fd.append('network_profiles[' + row.id + '][hostname]', row.hostname);
                fd.append('network_profiles[' + row.id + '][ip]', row.ip);
            });
        }
        console.log('Отправка запроса на перезакрепление...');
        
        fetch(window.agGridArmReassignUrl, { method: 'POST', body: fd })
            .then(function(r) { 
                console.log('Ответ получен, статус:', r.status);
                if (!r.ok) {
                    return r.text().then(function(text) {
                        console.error('Ошибка HTTP:', r.status, text);
                        return Promise.reject(new Error('HTTP ' + r.status + ': ' + text.substring(0, 100)));
                    });
                }
                return r.json();
            })
            .then(function(res) {
                console.log('Ответ от сервера:', res);
                if (res.success) {
                    var message = res.message;
                    if (res.details) {
                        var details = [];
                        if (res.details.responsible_user_changed > 0) {
                            details.push('Ответственный изменен: ' + res.details.responsible_user_changed);
                        }
                        if (res.details.location_changed > 0) {
                            details.push('Помещение изменено: ' + res.details.location_changed);
                        }
                        if (res.details.network_profile_changed > 0) {
                            details.push('Сетевые параметры ПК обновлены');
                        }
                        if (details.length > 0) {
                            message += '\\n• ' + details.join('\\n• ');
                        }
                    }
                    // Восстанавливаем состояние кнопки перед закрытием модального окна
                    resetSubmitButton();
                    // Очищаем данные после успешного сохранения
                    pendingIds = [];
                    originalSelectionIds = [];
                    equipmentData = [];
                    equipmentSummary = {};
                    // Закрываем модальное окно
                    if (reassignModal) {
                        reassignModal.hide();
                    }
                    // Обновляем таблицу
                    if (typeof refreshArmGrid === 'function') {
                        console.log('Обновление таблицы после успешного сохранения');
                        refreshArmGrid();
                    }
                    showNotification('✓ ' + message, 'success');
                } else {
                    console.error('Ошибка сохранения:', res.message);
                    showNotification(res.message || 'Ошибка при сохранении', 'error');
                    resetSubmitButton();
                }
            })
            .catch(function(err) {
                console.error('Ошибка при сохранении:', err);
                showNotification('Ошибка сети: ' + (err.message || 'Неизвестная ошибка'), 'error');
                resetSubmitButton();
            });
    }
    
    // Функция escapeHtml
    function escapeHtml(str) {
        if (str == null) return '';
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }
    
    // Открытие модального окна
    window.openReassignModal = function(ids) {
        originalSelectionIds = (ids || []).map(function(id) { return parseInt(id, 10); }).filter(function(id) { return id > 0; });
        pendingIds = originalSelectionIds.slice();
        equipmentData = [];
        equipmentSummary = {};
        syncOperationModeOptions();

        var infoContainer = document.getElementById('reassignEquipmentList');
        var countSpan = document.getElementById('reassignEquipmentCount');
        if (infoContainer) {
            infoContainer.innerHTML = '<div class=\"arm-reassign-equipment-list__loading text-center text-muted py-3\">'
                + '<i class=\"fas fa-circle-notch fa-spin\" aria-hidden=\"true\"></i> Загрузка данных…</div>';
        }
        if (countSpan) {
            countSpan.textContent = String(originalSelectionIds.length);
        }

        // Сброс полей
        var targetSb = document.getElementById('targetSystemBlockId');
        var targetSbUser = document.getElementById('targetSystemBlockUserId');
        setOperationMode('reassign', false);
        if (targetSbUser) setUserSelectValue(targetSbUser, '');
        if (targetSb) targetSb.innerHTML = '<option value=\"\">— сначала выберите пользователя —</option>';
        var whLoc = document.getElementById('warehouseLocationId');
        if (whLoc) setUserSelectValue(whLoc, '');
        var replaceWhLocReset = document.getElementById('replaceWarehouseLocationId');
        if (replaceWhLocReset) setUserSelectValue(replaceWhLocReset, '');
        var replacedStatusReset = document.getElementById('replacedStatusId');
        if (replacedStatusReset) replacedStatusReset.value = '';
        var replacedDescriptionReset = document.getElementById('replacedDescription');
        if (replacedDescriptionReset) {
            replacedDescriptionReset.value = '';
            replacedDescriptionReset.setAttribute('data-original', '');
        }
        var replaceHostnameReset = document.getElementById('replaceHostname');
        if (replaceHostnameReset) {
            replaceHostnameReset.value = '';
            replaceHostnameReset.setAttribute('data-original', '');
        }
        var replaceIpReset = document.getElementById('replaceIpAddress');
        if (replaceIpReset) {
            replaceIpReset.value = '';
            replaceIpReset.setAttribute('data-original', '');
        }
        var replaceNetworkWrapReset = document.getElementById('replaceNetworkWrap');
        if (replaceNetworkWrapReset) {
            replaceNetworkWrapReset.style.display = 'none';
        }
        var replacementReset = document.getElementById('replacementEquipmentId');
        if (replacementReset) {
            replacementReset.innerHTML = '<option value=\"\">— выберите замену —</option>';
            reinitReplacementEquipmentSelect();
        }
        var replaceTargetIdReset = document.getElementById('replaceTargetEquipmentId');
        if (replaceTargetIdReset) replaceTargetIdReset.value = '';
        var replaceTargetListReset = document.getElementById('replaceTargetList');
        if (replaceTargetListReset) replaceTargetListReset.innerHTML = '';
        var replaceSourceCard = document.getElementById('replaceSourceCard');
        if (replaceSourceCard) {
            replaceSourceCard.innerHTML = '';
            replaceSourceCard.style.display = '';
        }
        resetReassignBulkFields();
        var equipmentParamsList = document.getElementById('reassignEquipmentParamsList');
        if (equipmentParamsList) {
            if (window.IasUserSelect) {
                window.IasUserSelect.destroy(equipmentParamsList);
            }
            equipmentParamsList.innerHTML = '';
        }
        warehouseSelectionIds = [];
        syncReassignEquipmentParams(true);
        applyOperationModeUi();
        
        // Скрыть предпросмотр и очистить его содержимое
        var preview = document.getElementById('reassignPreview');
        var previewList = document.getElementById('reassignPreviewList');
        if (preview) {
            preview.classList.remove('arm-reassign-preview--hidden');
        }
        if (previewList) {
            previewList.innerHTML = '<li class=\"arm-op-change arm-op-change--muted\">'
                + '<span class=\"arm-op-change__label\">Ожидание</span>'
                + '<span class=\"arm-op-change__body\"><span class=\"arm-op-change__to\">Укажите параметры справа</span></span>'
                + '</li>';
        }
        
        // Восстановить состояние кнопки (на случай, если она была в состоянии загрузки)
        resetSubmitButton();
        
        // Деактивировать кнопку (так как нет изменений)
        var submitBtn = document.getElementById('reassignSubmit');
        if (submitBtn) submitBtn.disabled = true;
        
        if (!reassignModal) {
            reassignModal = new bootstrap.Modal(document.getElementById('reassignArmModal'));
        }
        
        // Используем событие Bootstrap modal для инициализации после полного открытия
        var modalElement = document.getElementById('reassignArmModal');
        if (modalElement) {
            if (!modalElement.hasAttribute('data-user-select-bound')) {
                modalElement.setAttribute('data-user-select-bound', '1');
                modalElement.addEventListener('hidden.bs.modal', function() {
                    if (window.IasUserSelect) {
                        window.IasUserSelect.closeAll(modalElement);
                        window.IasUserSelect.destroy(modalElement);
                    }
                });
            }

            // Удаляем предыдущие обработчики, если они есть
            if (window.reassignModalShownHandler) {
                modalElement.removeEventListener('shown.bs.modal', window.reassignModalShownHandler);
            }
            
            // Создаем новый обработчик для события показа модального окна
            window.reassignModalShownHandler = function() {
                console.log('Модальное окно полностью открыто, инициализируем обработчики');
                if (window.IasUserSelect) {
                    window.IasUserSelect.destroy(modalElement);
                    window.IasUserSelect.init(modalElement, { force: true });
                }
                updateReassignModalSelectState();
                initEventHandlers();
                bindReassignModalSelectHandlers();
                syncMoveComponentBlocksIfNeeded();
                
                // Ищем элементы предпросмотра внутри модального окна
                var modal = document.getElementById('reassignArmModal');
                var previewDiv = modal ? modal.querySelector('#reassignPreview') : document.getElementById('reassignPreview');
                var previewList = modal ? modal.querySelector('#reassignPreviewList') : document.getElementById('reassignPreviewList');
                
                console.log('При открытии модального окна: previewDiv=', !!previewDiv, 'previewList=', !!previewList, 'modal=', !!modal);
                
                // Принудительно обновляем предпросмотр после привязки обработчиков
                updatePreview();
            };
            
            // Привязываем обработчик события показа модального окна
            modalElement.addEventListener('shown.bs.modal', window.reassignModalShownHandler);
        }
        
        reassignModal.show();
        
        // Загрузить информацию о выбранных единицах
        if (originalSelectionIds.length > 0) {
            loadSelectedEquipmentInfo(originalSelectionIds);
        } else {
            // Если нет ID, все равно обновляем предпросмотр после задержки
            setTimeout(function() {
                var modal = document.getElementById('reassignArmModal');
                if (modal && modal.classList.contains('show')) {
                    updatePreview();
                }
            }, 200);
        }
    };
    
    function scheduleUpdatePreview() {
        setTimeout(function() {
            var m = document.getElementById('reassignArmModal');
            if (m && m.classList.contains('show')) {
                updatePreview();
            }
        }, 10);
    }

    /** Select2 не всегда доставляет change до document.addEventListener — привязка через jQuery. */
    function bindReassignModalSelectHandlers() {
        if (typeof jQuery === 'undefined') {
            return;
        }
        var modalRoot = jQuery('#reassignArmModal');
        if (!modalRoot.length) {
            return;
        }

        modalRoot.find('#targetSystemBlockUserId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                var userId = jQuery(this).val() || '';
                if (!userId) {
                    fetchSystemBlocksForUser('');
                    scheduleUpdatePreview();
                    return;
                }
                applyMoveComponentUserDefaults(userId);
                fetchSystemBlocksForUser(userId);
            });

        modalRoot.find('#reassignEquipmentParamsList .js-reassign-user, #reassignEquipmentParamsList .js-reassign-location')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                var fieldEl = jQuery(this);
                if (fieldEl.hasClass('js-reassign-user')) {
                    var userId = fieldEl.val() || '';
                    var row = this.closest('[data-assign-equipment-id]');
                    var locSelect = row ? row.querySelector('.js-reassign-location') : null;
                    if (userId && userId !== '0' && locSelect) {
                        applyDefaultLocationForReassign(userId, locSelect);
                    }
                }
                scheduleUpdatePreview();
            });

        modalRoot.find('#reassignBulkUserId, #reassignBulkLocationId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                syncReassignBulkApplyButtons();
            });

        modalRoot.find('#reassignBulkUserApply')
            .off('.reassignArmField')
            .on('click.reassignArmField', function() {
                applyBulkReassignUser();
            });

        modalRoot.find('#reassignBulkLocationApply')
            .off('.reassignArmField')
            .on('click.reassignArmField', function() {
                applyBulkReassignLocation();
            });

        modalRoot.find('#warehouseLocationId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                scheduleUpdatePreview();
            });

        modalRoot.find('#replaceWarehouseLocationId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                fetchReplaceWarehouseOptions();
            });

        modalRoot.find('#replaceTargetList')
            .off('.reassignArmField')
            .on('click.reassignArmField', '.arm-reassign-move-child__card', function() {
                var id = parseInt(this.getAttribute('data-replace-id'), 10) || 0;
                setSelectedReplaceTarget(id, true);
            });

        modalRoot.find('#replacedStatusId, #replacementEquipmentId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                scheduleUpdatePreview();
            });

        modalRoot.find('#replacedDescription, #replaceHostname, #replaceIpAddress')
            .off('.reassignArmField')
            .on('input.reassignArmField change.reassignArmField', function() {
                scheduleUpdatePreview();
            });

        modalRoot.find('#warehouseKitList')
            .off('.reassignArmField')
            .on('change.reassignArmField', 'input[data-warehouse-id]', function() {
                syncWarehouseSelectionIds();
                scheduleUpdatePreview();
            });

        modalRoot.find('#targetSystemBlockId, #componentLinkType, #moveComponentChildId')
            .off('.reassignArmField')
            .on('change.reassignArmField', function() {
                if (this.id === 'targetSystemBlockId') {
                    applyDefaultLocationFromTargetSystemBlock();
                }
                if (this.id === 'componentLinkType' || this.id === 'moveComponentChildId') {
                    syncComponentLinkTypeField();
                    syncMoveComponentChildPicker();
                }
                scheduleUpdatePreview();
            });

        modalRoot.find('.arm-reassign-move-type__switch')
            .off('.reassignArmField')
            .on('click.reassignArmField', '.arm-reassign-move-type__btn', function() {
                var type = this.getAttribute('data-link-type') || 'monitor';
                setComponentLinkType(type, true);
            });

        modalRoot.find('#moveComponentChildList')
            .off('.reassignArmField')
            .on('click.reassignArmField', '.arm-reassign-move-child__card', function() {
                this.classList.toggle('is-selected');
                this.setAttribute('aria-checked', this.classList.contains('is-selected') ? 'true' : 'false');
                pendingIds = getSelectedMoveComponentIdsFromUi();
                syncMoveComponentChildSelect(pendingIds);
                scheduleUpdatePreview();
            });
    }

    function syncMoveComponentBlocksIfNeeded() {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (mode !== 'move_component') {
            return;
        }
        var userEl = document.getElementById('targetSystemBlockUserId');
        var userId = userEl ? (window.IasUserSelect ? window.IasUserSelect.getValue(userEl) : userEl.value) : '';
        if (userId) {
            applyMoveComponentUserDefaults(userId);
            fetchSystemBlocksForUser(userId);
        }
        syncComponentLinkTypeField();
        syncMoveComponentChildPicker();
    }

    // Инициализация обработчиков
    function initEventHandlers() {
        // Обработчик кнопки сохранения (привязываем один раз)
        var submitBtn = document.getElementById('reassignSubmit');
        if (submitBtn && !submitBtn.hasAttribute('data-handler-attached')) {
            submitBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                console.log('Клик по кнопке сохранения');
                submitReassign();
            });
            submitBtn.setAttribute('data-handler-attached', 'true');
            console.log('Submit button handler attached');
        }

        var modeSwitch = document.querySelector('#reassignArmModal .arm-reassign-mode-switch');
        if (modeSwitch && !modeSwitch.hasAttribute('data-handler-attached')) {
            modeSwitch.addEventListener('click', function(e) {
                var btn = e.target.closest('.arm-reassign-mode-btn');
                if (!btn || !modeSwitch.contains(btn) || btn.disabled || btn.classList.contains('is-disabled')) {
                    return;
                }
                var nextMode = btn.getAttribute('data-mode') || 'reassign';
                setOperationMode(nextMode, true);
            });
            modeSwitch.setAttribute('data-handler-attached', 'true');
        }
        
        // Обработчики изменения полей - используем делегирование на уровне документа
        // Привязываем обработчик один раз, он будет работать всегда
        if (!window.reassignFieldChangeHandlerAttached) {
            window.reassignFieldChangeHandler = function(e) {
                var target = e.target;
                // Проверяем, что событие произошло внутри модального окна перезакрепления
                var modal = document.getElementById('reassignArmModal');
                if (!modal) {
                    return;
                }
                
                // Проверяем, что модальное окно видимо
                if (!modal.classList.contains('show')) {
                    // Модальное окно закрыто, игнорируем событие
                    return;
                }
                
                // Проверяем, что событие произошло внутри модального окна
                if (!modal.contains(target)) {
                    return;
                }
                
                var isWarehouseKitInput = target.matches && target.matches('input[data-warehouse-id]');
                var isNetworkField = target.classList
                    && (target.classList.contains('js-reassign-hostname') || target.classList.contains('js-reassign-ip'));
                var isUserAssignField = target.classList && target.classList.contains('js-reassign-user');
                var isLocationAssignField = target.classList && target.classList.contains('js-reassign-location');
                if (
                    isUserAssignField ||
                    isLocationAssignField ||
                    isNetworkField ||
                    target.id === 'warehouseLocationId' ||
                    target.id === 'replaceWarehouseLocationId' ||
                    target.id === 'replacedStatusId' ||
                    target.id === 'replacedDescription' ||
                    target.id === 'replaceHostname' ||
                    target.id === 'replaceIpAddress' ||
                    target.id === 'replacementEquipmentId' ||
                    target.id === 'targetSystemBlockId' ||
                    target.id === 'targetSystemBlockUserId' ||
                    target.id === 'componentLinkType' ||
                    target.id === 'moveComponentChildId' ||
                    isWarehouseKitInput
                ) {
                    // Получаем equipmentData из замыкания (она объявлена в области видимости функции)
                    var currentEquipmentDataLength = 0;
                    try {
                        // Пытаемся получить длину массива equipmentData из области видимости
                        // Если она недоступна напрямую, используем 0
                        if (typeof equipmentData !== 'undefined' && Array.isArray(equipmentData)) {
                            currentEquipmentDataLength = equipmentData.length;
                        }
                    } catch(e) {
                        // Игнорируем ошибку
                    }
                    console.log('Field changed:', target.id, 'value:', target.value, 'equipmentData.length:', currentEquipmentDataLength);
                    if (target.id === 'targetSystemBlockUserId') {
                        applyDefaultResponsibleForMoveComponent(target.value || '');
                        fetchSystemBlocksForUser(target.value || '');
                    }
                    if (target.id === 'targetSystemBlockId') {
                        applyDefaultLocationFromTargetSystemBlock();
                    }
                    if (target.id === 'replaceWarehouseLocationId') {
                        fetchReplaceWarehouseOptions();
                    }
                    if (isUserAssignField) {
                        var row = target.closest('[data-assign-equipment-id]');
                        var locSelect = row ? row.querySelector('.js-reassign-location') : null;
                        var userVal = target.value || '';
                        if (userVal && userVal !== '0' && locSelect) {
                            applyDefaultLocationForReassign(userVal, locSelect);
                        }
                    }
                    if (target.id === 'componentLinkType' || target.id === 'moveComponentChildId') {
                        syncMoveComponentChildPicker();
                    }
                    if (isWarehouseKitInput) {
                        syncWarehouseSelectionIds();
                    }
                    // Используем небольшую задержку, чтобы значение успело обновиться
                    setTimeout(function() {
                        // Проверяем, что модальное окно все еще открыто перед обновлением предпросмотра
                        var checkModal = document.getElementById('reassignArmModal');
                        if (checkModal && checkModal.classList.contains('show')) {
                            console.log('Вызываем updatePreview после изменения поля');
                            updatePreview();
                        } else {
                            console.log('Модальное окно закрыто, пропускаем обновление предпросмотра');
                        }
                    }, 10);
                }
            };
            
            // Привязываем обработчик к документу с capture фазой
            document.addEventListener('change', window.reassignFieldChangeHandler, true);
            document.addEventListener('input', window.reassignFieldChangeHandler, true);
            window.reassignFieldChangeHandlerAttached = true;
            console.log('Field change handlers attached via document delegation (one time)');
        }
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        // Инициализируем обработчики при загрузке страницы
        setTimeout(function() {
            initEventHandlers();
        }, 500);
    });
})();
", \yii\web\View::POS_END);
