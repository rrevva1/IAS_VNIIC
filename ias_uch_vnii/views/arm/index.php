<?php
/**
 * Учет ТС: список оборудования в AG Grid.
 * Колонки — по Основному учёту (см. docs/МАППИНГ_КОЛОНОК_УЧЕТ_ТС.md).
 */

use app\assets\ArmGridAsset;
use yii\helpers\Html;
use yii\helpers\Url;

ArmGridAsset::register($this);

$this->title = 'Учет ТС';
$this->params['breadcrumbs'] = [];

$equipmentTypes = $equipmentTypes ?? [];
$isAdmin = $isAdmin ?? false;
?>
<div class="arm-page">
    <header class="arm-page__header">
        <div class="arm-page__heading">
            <h1 class="arm-page__title"><?= Html::encode($this->title) ?></h1>
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
                <li class="nav-item">
                    <a class="nav-link active arm-type-tab" href="#" data-type-id="" role="tab" aria-selected="true">Вся техника</a>
                </li>
                <?php foreach ($equipmentTypes as $type): ?>
                <li class="nav-item">
                    <a class="nav-link arm-type-tab" href="#" role="tab" aria-selected="false"
                       data-type-id="<?= Html::encode($type['id'] ?? '') ?>"><?= Html::encode($type['name'] ?? '') ?></a>
                </li>
                <?php endforeach; ?>
            </ul>
        </div>

        <div class="arm-command-bar__tools">
            <?php if ($isAdmin): ?>
            <?= Html::button('<i class="fas fa-plus" aria-hidden="true"></i><span class="arm-btn-label">Добавить</span>', [
                'class' => 'btn btn-primary arm-tool-btn',
                'type' => 'button',
                'data-arm-create-open' => '1',
                'title' => 'Добавить технику',
            ]) ?>
            <?php endif; ?>
            <?= Html::button('<i class="fas fa-arrows-rotate" aria-hidden="true"></i><span class="arm-btn-label">Обновить</span>', [
                'class' => 'btn btn-outline-secondary arm-tool-btn',
                'onclick' => 'refreshArmGrid()',
                'title' => 'Перезагрузить данные',
            ]) ?>
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
        <?php if ($isAdmin): ?>
        <div id="armSelectionBar" class="arm-selection-bar" aria-live="polite">
            <p class="arm-selection-bar__text">
                Выбрано: <strong id="armSelectionCount">0</strong>
            </p>
            <div class="arm-selection-bar__actions">
                <?= Html::button('<i class="fas fa-user-pen" aria-hidden="true"></i> Переназначить', [
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
        <div id="agGridArmContainer" class="ag-theme-quartz arm-grid-loading"
             data-create-modal-url="<?= Html::encode(Url::to(['create-modal'])) ?>"
             data-view-modal-url-template="<?= Html::encode(Url::to(['view-modal', 'id' => '__ID__'])) ?>">
            <div class="arm-grid-loading__inner">
                <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                <p>Загрузка таблицы…</p>
            </div>
        </div>
    </div>
</div>

<?= $this->render('_view_modal') ?>
<?php if ($isAdmin): ?>
<?= $this->render('_create_modal') ?>
<?php endif; ?>

<input type="file" id="armImportFileInput" accept=".xlsx,.xls" style="display:none;">

<div class="modal fade" id="armColumnsModal" tabindex="-1" aria-labelledby="armColumnsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="armColumnsModalLabel">Настройка столбцов</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body">
                <p class="text-muted small mb-2">Отметьте столбцы, которые должны отображаться в таблице.</p>
                <div id="armColumnsList"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" id="armColumnsReset">Сбросить</button>
                <button type="button" class="btn btn-primary" id="armColumnsApply">Применить</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="reassignArmModal" tabindex="-1" aria-labelledby="reassignArmModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen arm-reassign-modal__dialog">
        <div class="modal-content arm-reassign-modal">
            <div class="modal-header arm-reassign-modal__header">
                <h5 class="modal-title" id="reassignArmModalLabel">
                    <i class="fas fa-people-arrows" aria-hidden="true"></i>
                    Перемещение и переназначение техники
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-reassign-modal__body">
                <div class="arm-reassign-layout">
                    <aside class="arm-reassign-layout__aside" id="reassignEquipmentInfo" aria-labelledby="reassignStepSelectedTitle">
                        <section class="arm-reassign-section arm-reassign-section--aside">
                            <h6 class="arm-reassign-section__title" id="reassignStepSelectedTitle">
                                <i class="fas fa-list-check arm-reassign-section__icon" aria-hidden="true"></i>
                                Выбранная техника
                                <span class="arm-reassign-section__badge" id="reassignEquipmentCount">0</span>
                            </h6>
                            <div id="reassignEquipmentList" class="arm-reassign-equipment-list">
                                <div class="arm-reassign-equipment-list__loading text-center text-muted py-3">
                                    <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i>
                                    Загрузка данных…
                                </div>
                            </div>
                        </section>
                    </aside>

                    <div class="arm-reassign-layout__main">
                <section class="arm-reassign-section arm-reassign-section--action" aria-labelledby="reassignStepModeTitle">
                    <h6 class="arm-reassign-section__title arm-reassign-section__title--plain" id="reassignStepModeTitle">
                        Тип операции
                    </h6>
                    <label class="form-label visually-hidden" for="reassignOperationMode">Тип операции</label>
                    <select id="reassignOperationMode" class="form-select arm-reassign-mode-select">
                        <option value="reassign">Обычное переназначение</option>
                        <option value="move_component">Перенос компонента (монитор или ИБП)</option>
                        <option value="dismissal">Увольнение сотрудника</option>
                    </select>
                    <p class="arm-reassign-mode-hint" id="reassignModeHint" role="note"></p>
                </section>

                <section class="arm-reassign-section arm-reassign-section--action" aria-labelledby="reassignStepParamsTitle">
                    <h6 class="arm-reassign-section__title arm-reassign-section__title--plain" id="reassignStepParamsTitle">
                        Параметры
                    </h6>

                    <div class="arm-reassign-panel" id="moveComponentWrap" style="display:none;">
                        <p class="arm-reassign-panel__caption">Куда перенести компонент</p>
                        <div class="mb-3">
                            <label class="form-label" for="componentLinkType">Тип компонента</label>
                            <select id="componentLinkType" class="form-select">
                                <option value="monitor">Монитор</option>
                                <option value="ups">ИБП</option>
                            </select>
                        </div>
                        <div class="mb-3" id="moveComponentChildWrap" style="display:none;">
                            <label class="form-label" for="moveComponentChildId" id="moveComponentChildLabel">Какой монитор перенести</label>
                            <select id="moveComponentChildId" class="form-select"></select>
                            <small class="form-text text-muted" id="moveComponentChildHint">
                                У выбранного ПК несколько мониторов — укажите, какой именно переносится.
                            </small>
                            <div class="alert alert-warning py-2 px-3 mt-2 mb-0 small" id="moveComponentChildEmpty" style="display:none;">
                                Нет привязанных мониторов у выбранного ПК. Выберите строку монитора в таблице или другой тип компонента.
                            </div>
                        </div>
                        <div class="mb-3 js-user-select-field">
                            <label class="form-label" for="targetSystemBlockUserId">Владелец целевого ПК</label>
                            <select id="targetSystemBlockUserId" class="form-select js-user-select-search" data-placeholder="Выберите пользователя">
                                <option value="">— выберите пользователя —</option>
                                <?php foreach ($users ?? [] as $uid => $uname): ?>
                                <option value="<?= (int)$uid ?>"><?= Html::encode($uname) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="mb-0">
                            <label class="form-label" for="targetSystemBlockId">Целевой системный блок</label>
                            <select id="targetSystemBlockId" class="form-select">
                                <option value="">— сначала выберите пользователя —</option>
                            </select>
                        </div>
                    </div>

                    <div class="arm-reassign-panel" id="dismissalUserWrap" style="display:none;">
                        <p class="arm-reassign-panel__caption">При увольнении сотрудника</p>
                        <div class="mb-3 js-user-select-field">
                            <label class="form-label" for="dismissalTargetUserId">Передать технику пользователю</label>
                            <select id="dismissalTargetUserId" class="form-select js-user-select-search" data-placeholder="Не выбрано">
                                <option value="">— не выбрано —</option>
                                <?php foreach ($users ?? [] as $uid => $uname): ?>
                                <option value="<?= (int)$uid ?>"><?= Html::encode($uname) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="form-check arm-reassign-check" id="dismissalWarehouseWrap">
                            <input class="form-check-input" type="checkbox" id="dismissalToWarehouse">
                            <label class="form-check-label" for="dismissalToWarehouse">
                                Отправить на склад и снять ответственного
                            </label>
                        </div>
                    </div>

                    <div class="arm-reassign-panel" id="reassignCommonFieldsWrap">
                        <div class="mb-3 js-user-select-field">
                            <label class="form-label" for="reassignUserId">Ответственный</label>
                            <select id="reassignUserId" class="form-select js-user-select-search" data-placeholder="— не менять —">
                                <option value="">— не менять —</option>
                                <option value="0">— снять назначение —</option>
                                <?php foreach ($users ?? [] as $uid => $uname): ?>
                                <option value="<?= (int)$uid ?>"><?= Html::encode($uname) ?></option>
                                <?php endforeach; ?>
                            </select>
                            <small id="reassignUserIdSyncHint" class="reassign-user-sync-hint" style="display:none;">
                                Ответственный будет совпадать с владельцем целевого ПК.
                            </small>
                        </div>

                        <div class="mb-3 js-user-select-field">
                            <label class="form-label" for="reassignLocationId">Помещение</label>
                            <select id="reassignLocationId" class="form-select js-user-select-search" data-placeholder="— не менять —">
                                <option value="">— не менять —</option>
                                <?php foreach ($locations ?? [] as $lid => $lname): ?>
                                <option value="<?= (int)$lid ?>"><?= Html::encode($lname) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>

                        <div class="mb-0 js-user-select-field">
                            <label class="form-label" for="reassignStatusId">Статус</label>
                            <select id="reassignStatusId" class="form-select js-user-select-search" data-placeholder="— не менять —">
                                <option value="">— не менять —</option>
                                <?php foreach ($statuses ?? [] as $sid => $sname): ?>
                                <option value="<?= (int)$sid ?>"><?= Html::encode($sname) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                </section>

                <div class="arm-reassign-preview-slot">
                    <div id="reassignPreview" class="arm-reassign-preview arm-reassign-preview--hidden" role="status" aria-live="polite">
                        <div class="arm-reassign-preview__title">
                            <i class="fas fa-circle-info" aria-hidden="true"></i>
                            Что изменится
                        </div>
                        <ul id="reassignPreviewList" class="arm-reassign-preview__list mb-0"></ul>
                    </div>
                </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer arm-reassign-modal__footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Отмена</button>
                <button type="button" class="btn btn-primary arm-reassign-submit" id="reassignSubmit" disabled>
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
    "window.agGridArmDataUrl = " . json_encode(Url::to(['arm/get-grid-data'])) . ";" .
    "window.agGridArmViewModalUrlTemplate = " . json_encode(Url::to(['view-modal', 'id' => '__ID__'])) . ";",
    \yii\web\View::POS_HEAD
);
$this->registerJs(
    "window.agGridArmCurrentTypeId = '';" .
    "window.agGridArmDefaultLimit = 20;" .
    "window.agGridArmReassignUrl = " . json_encode(Url::to(['arm/reassign'])) . ";" .
    "window.agGridArmSystemBlocksUrl = " . json_encode(Url::to(['arm/system-blocks'])) . ";" .
    "window.agGridArmUserPrimaryLocationUrl = " . json_encode(Url::to(['arm/user-primary-location'])) . ";" .
    "window.agGridArmImportPreviewUrl = " . json_encode(Url::to(['arm/import-preview'])) . ";" .
    "window.agGridArmImportApplyUrl = " . json_encode(Url::to(['arm/import-apply'])) . ";" .
    "window.agGridArmGetSelectedInfoUrl = " . json_encode(Url::to(['arm/get-selected-info'])) . ";" .
    "window.armReassignCsrf = {param: " . json_encode(Yii::$app->request->csrfParam) . ", token: " . json_encode(Yii::$app->request->csrfToken) . "};" .
    "window.armUsers = " . json_encode($users ?? []) . ";" .
    "window.armLocations = " . json_encode($locations ?? []) . ";" .
    "window.armStatuses = " . json_encode($statuses ?? []) . ";",
    \yii\web\View::POS_HEAD
);
$this->registerJs("
(function(){
    var reassignModal, pendingIds = [], equipmentData = [], equipmentSummary = {}, armSystemBlocksCache = {};
    var REASSIGN_MODE_HINTS = {
        reassign: 'Укажите нового ответственного, помещение или статус. При переназначении системного блока связанные монитор и ИБП переназначаются вместе с ним.',
        move_component: 'Выберите владельца целевого ПК и системный блок. Ответственный и помещение компонента подстроятся автоматически.',
        dismissal: 'Передайте технику другому сотруднику или отправьте на склад со снятием ответственного.',
    };

    function updateModeHint() {
        var el = document.getElementById('reassignModeHint');
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (el) {
            el.textContent = REASSIGN_MODE_HINTS[mode] || '';
        }
    }

    /** Перенос компонента — только при выборе одного системного блока (ПК) в таблице. */
    function isMoveComponentModeAllowed() {
        if (pendingIds.length !== 1 || !equipmentData || equipmentData.length !== 1) {
            return false;
        }
        return !!equipmentData[0].is_host;
    }

    function syncMoveComponentOperationOption() {
        var modeEl = document.getElementById('reassignOperationMode');
        if (!modeEl) {
            return;
        }
        var moveOpt = modeEl.querySelector('option[value=\"move_component\"]');
        if (!moveOpt) {
            return;
        }
        var allowed = isMoveComponentModeAllowed();
        moveOpt.disabled = !allowed;
        moveOpt.hidden = !allowed;
        if (!allowed && modeEl.value === 'move_component') {
            modeEl.value = 'reassign';
            updateModeHint();
            onModeChanged();
        }
    }

    function renderSystemBlocks(rows) {
        var sbSelect = document.getElementById('targetSystemBlockId');
        if (!sbSelect) return;
        var html = '<option value=\"\">— выберите системный блок —</option>';
        rows.forEach(function(row) {
            var label = row.name || '—';
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
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var ru = document.getElementById('reassignUserId');
        var hint = document.getElementById('reassignUserIdSyncHint');
        var lockResponsible = mode === 'move_component';
        if (ru) {
            if (window.IasUserSelect && window.IasUserSelect.setDisabled) {
                window.IasUserSelect.setDisabled(ru, lockResponsible);
            } else {
                ru.disabled = lockResponsible;
            }
        }
        if (hint) {
            hint.style.display = lockResponsible ? 'block' : 'none';
        }
    }

    function applyDefaultResponsibleForMoveComponent(targetUserId) {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (mode !== 'move_component') return;
        var ru = document.getElementById('reassignUserId');
        if (!ru || !targetUserId) return;
        var unlock = ru.disabled;
        if (unlock && window.IasUserSelect && window.IasUserSelect.setDisabled) {
            window.IasUserSelect.setDisabled(ru, false);
        } else if (unlock) {
            ru.disabled = false;
        }
        setUserSelectValue(ru, targetUserId, true);
        if (unlock && window.IasUserSelect && window.IasUserSelect.setDisabled) {
            window.IasUserSelect.setDisabled(ru, true);
        } else if (unlock) {
            ru.disabled = true;
        }
    }

    /** Помещение по наиболее частому location_id техники пользователя. */
    function applyPrimaryLocationForUser(userId) {
        if (!userId || userId === '0') return;
        var loc = document.getElementById('reassignLocationId');
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
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (mode !== 'move_component') return;
        var sb = document.getElementById('targetSystemBlockId');
        var loc = document.getElementById('reassignLocationId');
        if (!sb || !loc || !sb.value) return;
        var opt = sb.options[sb.selectedIndex];
        var lid = opt && opt.getAttribute('data-location-id');
        if (lid) {
            setUserSelectValue(loc, lid, true);
            scheduleUpdatePreview();
            return;
        }
        var userEl = document.getElementById('targetSystemBlockUserId');
        var userId = userEl ? (window.IasUserSelect ? window.IasUserSelect.getValue(userEl) : userEl.value) : '';
        if (userId) {
            applyPrimaryLocationForUser(userId);
        }
    }

    function applyMoveComponentUserDefaults(userId) {
        if (!userId) return;
        applyDefaultResponsibleForMoveComponent(userId);
        applyPrimaryLocationForUser(userId);
    }

    /** Обычное переназначение: помещение по «основному» для выбранного ответственного (по учёту ТС). */
    function applyDefaultLocationForReassign(userId) {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        if (mode !== 'reassign') return;
        applyPrimaryLocationForUser(userId);
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

    function formatMoveComponentOptionLabel(component, hostLabel) {
        var name = (component.name || '').trim() || 'без названия';
        var suffix = hostLabel ? ' (ПК: ' + hostLabel + ')' : '';
        return name + suffix;
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
            label.textContent = isUps ? 'Какой ИБП перенести' : 'Какой монитор перенести';
        }
        if (hint) {
            hint.textContent = isUps
                ? 'У выбранного ПК несколько ИБП — укажите, какой именно переносится.'
                : 'У выбранного ПК несколько мониторов — укажите, какой именно переносится.';
        }
        var emptyMsg = document.getElementById('moveComponentChildEmpty');
        if (emptyMsg) {
            emptyMsg.textContent = isUps
                ? 'Нет привязанных ИБП у выбранного ПК. Выберите строку ИБП в таблице или другой тип компонента.'
                : 'Нет привязанных мониторов у выбранного ПК. Выберите строку монитора в таблице или другой тип компонента.';
        }
    }

    /** Список переносимых компонентов: при нескольких мониторах/ИБП — выбор одного. */
    function syncMoveComponentChildPicker() {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var wrap = document.getElementById('moveComponentChildWrap');
        var select = document.getElementById('moveComponentChildId');
        var emptyMsg = document.getElementById('moveComponentChildEmpty');
        if (mode !== 'move_component' || !wrap || !select) {
            if (wrap) wrap.style.display = 'none';
            return;
        }
        updateMoveComponentChildLabels();
        var candidates = getMoveComponentCandidates();
        if (emptyMsg) {
            emptyMsg.style.display = candidates.length === 0 ? 'block' : 'none';
        }
        if (candidates.length === 0) {
            wrap.style.display = 'block';
            select.innerHTML = '<option value=\"\">— нет доступных —</option>';
            return;
        }
        if (candidates.length === 1) {
            wrap.style.display = 'none';
            pendingIds = [candidates[0].id];
            return;
        }
        wrap.style.display = 'block';
        var prev = select.value;
        select.innerHTML = '';
        candidates.forEach(function(c) {
            var opt = document.createElement('option');
            opt.value = String(c.id);
            opt.textContent = formatMoveComponentOptionLabel(c, c.host_label);
            select.appendChild(opt);
        });
        if (prev && candidates.some(function(c) { return String(c.id) === prev; })) {
            select.value = prev;
        }
        pendingIds = [parseInt(select.value, 10) || candidates[0].id];
    }

    function configureModalFromSelectedEquipment() {
        if (!equipmentData || !equipmentData.length) return;
        var modeEl = document.getElementById('reassignOperationMode');
        if (!modeEl) return;
        syncMoveComponentOperationOption();
        if (modeEl.value === 'move_component' && !isMoveComponentModeAllowed()) {
            modeEl.value = 'reassign';
        }
        onModeChanged();
        syncMoveComponentChildPicker();
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
                    syncMoveComponentChildPicker();
                    console.log('Данные о выбранных единицах загружены:', equipmentData.length, 'единиц');
                    renderEquipmentInfo();
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
            return escapeHtml(row.type) + ' — ' + escapeHtml(c.name || '—');
        });
        return '<ul class=\"arm-eq-item__linked\">' + lines.map(function(line) {
            return '<li>' + line + '</li>';
        }).join('') + '</ul>';
    }

    function renderEquipmentItemCard(item, emptyMuted) {
        var typeLabel = item.is_host ? 'ПК' : (item.equipment_type ? escapeHtml(item.equipment_type) : 'Техника');
        var rowClass = 'arm-eq-item' + (item.is_host ? ' arm-eq-item--host' : '');
        var html = '<div class=\"' + rowClass + '\">';
        html += '<div class=\"arm-eq-item__primary\">';
        html += '<span class=\"arm-eq-item__name\">' + typeLabel + ' · ' + escapeHtml(item.name || '—') + '</span>';
        html += '<span class=\"arm-eq-item__inv\">№ ' + escapeHtml(item.inventory_number || '—') + '</span>';
        html += '</div>';
        html += '<div class=\"arm-eq-item__meta\">' + formatMetaLine(item, emptyMuted) + '</div>';
        html += renderLinkedLines(item);
        html += '</div>';
        return html;
    }

    // Отображение информации о выбранных единицах техники
    function renderEquipmentInfo() {
        var container = document.getElementById('reassignEquipmentList');
        if (!container) return;
        
        if (equipmentData.length === 0) {
            container.innerHTML = '<div class=\"arm-eq-list-empty\">Нет данных о выбранной технике</div>';
            updateEquipmentCountBadge();
            return;
        }
        
        var html = '<div class=\"arm-eq-list\">';
        var emptyMuted = '<span class=\"arm-eq-item__empty\">не указано</span>';
        updateEquipmentCountBadge();

        equipmentData.forEach(function(item) {
            html += renderEquipmentItemCard(item, emptyMuted);
        });

        html += '</div>';
        container.innerHTML = html;
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
        
        var userIdEl = document.getElementById('reassignUserId');
        var locationIdEl = document.getElementById('reassignLocationId');
        var statusIdEl = document.getElementById('reassignStatusId');
        
        if (!userIdEl || !locationIdEl || !statusIdEl) {
            console.warn('updatePreview: form fields not found');
            return;
        }
        
        var userId = getSelectFieldValue(userIdEl);
        var locationId = getSelectFieldValue(locationIdEl);
        var statusId = getSelectFieldValue(statusIdEl);
        
        console.log('updatePreview called: userId=', userId, 'locationId=', locationId, 'statusId=', statusId, 'equipmentData.length=', equipmentData.length);
        
        var changes = [];
        var hasChanges = false;
        
        // Проверяем изменения ответственного
        if (userId !== '') {
            hasChanges = true;
            var newUserName = '';
            if (userId === '0') {
                newUserName = 'снять назначение';
            } else if (window.armUsers && window.armUsers[userId]) {
                newUserName = window.armUsers[userId];
            }
            
            var affectedCount = 0;
            var oldUsers = [];
            equipmentData.forEach(function(item) {
                if (userId === '0' && item.responsible_user_id) {
                    affectedCount++;
                    if (item.responsible_user_name && oldUsers.indexOf(item.responsible_user_name) === -1) {
                        oldUsers.push(item.responsible_user_name);
                    }
                } else if (userId !== '0' && item.responsible_user_id != userId) {
                    affectedCount++;
                    if (item.responsible_user_name && oldUsers.indexOf(item.responsible_user_name) === -1) {
                        oldUsers.push(item.responsible_user_name);
                    }
                }
            });
            
            if (affectedCount > 0) {
                var oldUserText = oldUsers.length > 0 ? oldUsers.join(', ') : 'разные';
                changes.push('Ответственный: «' + oldUserText + '» → «' + newUserName + '» (' + affectedCount + ' ед.)');
            }
        }
        
        // Проверяем изменения помещения
        if (locationId !== '') {
            hasChanges = true;
            var newLocationName = window.armLocations && window.armLocations[locationId] ? window.armLocations[locationId] : '';
            
            var affectedCount = 0;
            var oldLocations = [];
            equipmentData.forEach(function(item) {
                if (item.location_id != locationId) {
                    affectedCount++;
                    if (item.location_name && oldLocations.indexOf(item.location_name) === -1) {
                        oldLocations.push(item.location_name);
                    }
                }
            });
            
            if (affectedCount > 0) {
                var oldLocText = oldLocations.length > 0 ? oldLocations.join(', ') : 'разные';
                changes.push('Помещение: «' + oldLocText + '» → «' + newLocationName + '» (' + affectedCount + ' ед.)');
            }
        }
        
        // Проверяем изменения статуса
        if (statusId !== '') {
            hasChanges = true;
            var newStatusName = window.armStatuses && window.armStatuses[statusId] ? window.armStatuses[statusId] : '';
            
            var affectedCount = 0;
            var oldStatuses = [];
            equipmentData.forEach(function(item) {
                if (item.status_id != statusId) {
                    affectedCount++;
                    if (item.status_name && oldStatuses.indexOf(item.status_name) === -1) {
                        oldStatuses.push(item.status_name);
                    }
                }
            });
            
            if (affectedCount > 0) {
                var oldStatusText = oldStatuses.length > 0 ? oldStatuses.join(', ') : 'разные';
                changes.push('Статус: «' + oldStatusText + '» → «' + newStatusName + '» (' + affectedCount + ' ед.)');
            }
        }
        
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var targetSystemBlockId = (document.getElementById('targetSystemBlockId') || {}).value || '';
        var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
        var dismissalTargetUserId = (document.getElementById('dismissalTargetUserId') || {}).value || '';
        var dismissalToWarehouse = (document.getElementById('dismissalToWarehouse') || {}).checked;
        var hasAnyChange = (userId !== '' || locationId !== '' || statusId !== '');
        if (mode === 'move_component') {
            syncMoveComponentChildPicker();
            var moveCandidates = getMoveComponentCandidates();
            hasAnyChange = targetSystemBlockUserId !== '' && targetSystemBlockId !== ''
                && moveCandidates.length > 0 && pendingIds.length === 1;
        } else if (mode === 'dismissal') {
            hasAnyChange = dismissalToWarehouse || dismissalTargetUserId !== '';
        }
        
        console.log('updatePreview: hasAnyChange=', hasAnyChange, 'hasChanges=', hasChanges, 'changes.length=', changes.length, 'equipmentData.length=', equipmentData.length);
        
        if (hasAnyChange) {
            // Если есть хотя бы одно изменение, активируем кнопку
            submitBtn.disabled = false;
            console.log('Кнопка активирована, так как есть изменения');
            
            // Обновляем предпросмотр только если элементы найдены И модальное окно видимо
            if (previewDiv && previewList && isModalVisible) {
                previewDiv.classList.remove('arm-reassign-preview--hidden');

                if (changes.length > 0) {
                    previewList.innerHTML = changes.map(function(change) {
                        return '<li class=\"arm-reassign-preview__item\"><span class=\"arm-reassign-preview__item-text\">' + escapeHtml(change) + '</span></li>';
                    }).join('');
                } else if (equipmentData.length > 0) {
                    previewList.innerHTML = '<li class=\"arm-reassign-preview__item arm-reassign-preview__item--muted\">Изменения будут применены ко всей выбранной технике</li>';
                } else {
                    previewList.innerHTML = '<li class=\"arm-reassign-preview__item arm-reassign-preview__item--muted\">Загрузка данных…</li>';
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
            
            // Скрываем предпросмотр только если элементы найдены И модальное окно видимо
            if (previewDiv && previewList && isModalVisible) {
                previewDiv.classList.add('arm-reassign-preview--hidden');
                previewList.innerHTML = '';
            }
        }
        
        console.log('updatePreview: hasAnyChange=', hasAnyChange, 'userId=', userId, 'locationId=', locationId, 'statusId=', statusId, 'changes.length=', changes.length, 'equipmentData.length=', equipmentData.length, 'submitBtn.disabled=', submitBtn.disabled);
    }
    
    // Валидация формы
    function validateForm() {
        var modeEl = document.getElementById('reassignOperationMode');
        var userId = getSelectFieldValue(document.getElementById('reassignUserId'));
        var locationId = getSelectFieldValue(document.getElementById('reassignLocationId'));
        var statusId = getSelectFieldValue(document.getElementById('reassignStatusId'));
        var mode = modeEl ? modeEl.value : 'reassign';
        var targetSystemBlockId = (document.getElementById('targetSystemBlockId') || {}).value || '';
        var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
        var dismissalTargetUserId = (document.getElementById('dismissalTargetUserId') || {}).value || '';
        var dismissalToWarehouse = (document.getElementById('dismissalToWarehouse') || {}).checked;
        if (mode === 'move_component') {
            syncMoveComponentChildPicker();
            return targetSystemBlockUserId !== '' && targetSystemBlockId !== ''
                && getMoveComponentCandidates().length > 0 && pendingIds.length === 1;
        }
        if (mode === 'dismissal') {
            return dismissalToWarehouse || dismissalTargetUserId !== '';
        }
        return userId !== '' || locationId !== '' || statusId !== '';
    }

    function onModeChanged() {
        var mode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var moveWrap = document.getElementById('moveComponentWrap');
        var dismissalUserWrap = document.getElementById('dismissalUserWrap');
        var commonWrap = document.getElementById('reassignCommonFieldsWrap');
        var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
        updateModeHint();
        if (window.IasUserSelect) {
            if (mode !== 'move_component' && moveWrap) {
                window.IasUserSelect.destroy(moveWrap);
            }
            if (mode !== 'dismissal' && dismissalUserWrap) {
                window.IasUserSelect.destroy(dismissalUserWrap);
            }
        }
        if (moveWrap) moveWrap.style.display = mode === 'move_component' ? 'block' : 'none';
        if (dismissalUserWrap) dismissalUserWrap.style.display = mode === 'dismissal' ? 'block' : 'none';
        if (commonWrap) commonWrap.style.display = mode === 'move_component' ? 'none' : 'block';
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
            var ru = (document.getElementById('reassignUserId') || {}).value || '';
            if (ru && ru !== '0') {
                applyDefaultLocationForReassign(ru);
            }
        }
        updateReassignModalSelectState();
        if (window.IasUserSelect) {
            var modalEl = document.getElementById('reassignArmModal');
            if (modalEl && modalEl.classList.contains('show')) {
                window.IasUserSelect.closeAll(modalEl);
                window.IasUserSelect.init(modalEl, { force: true });
                updateReassignModalSelectState();
                bindReassignModalSelectHandlers();
                syncMoveComponentBlocksIfNeeded();
            }
        }
        syncMoveComponentChildPicker();
        updatePreview();
    }
    
    // Показ уведомления
    function showNotification(message, type) {
        var level = type || 'success';
        if (typeof window.IASNotify === 'function') {
            window.IASNotify(message, level);
            return;
        }
        console.log(level + ': ' + message);
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
        var reassignUserEl = document.getElementById('reassignUserId');
        var userId = reassignUserEl
            ? (window.IasUserSelect && window.IasUserSelect.getValue
                ? window.IasUserSelect.getValue(reassignUserEl)
                : reassignUserEl.value)
            : '';
        var locationId = getSelectFieldValue(document.getElementById('reassignLocationId'));
        var statusId = getSelectFieldValue(document.getElementById('reassignStatusId'));
        var operationMode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
        var hasFormChanges = validateForm();
        var targetSystemBlockId = (document.getElementById('targetSystemBlockId') || {}).value || '';
        var targetSystemBlockUserId = (document.getElementById('targetSystemBlockUserId') || {}).value || '';
        var componentLinkType = (document.getElementById('componentLinkType') || {}).value || '';
        var dismissalTargetUserId = (document.getElementById('dismissalTargetUserId') || {}).value || '';
        var dismissalToWarehouse = (document.getElementById('dismissalToWarehouse') || {}).checked;
        
        console.log('submitReassign: userId=', userId, 'locationId=', locationId, 'statusId=', statusId, 'pendingIds.length=', pendingIds.length);
        
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
            if (pendingIds.length !== 1) {
                showNotification('Для переноса компонента выберите один системный блок (ПК) в таблице.', 'error');
                return;
            }
            if (!targetSystemBlockUserId || !targetSystemBlockId) {
                showNotification('Для переноса компонента выберите пользователя и системный блок.', 'error');
                return;
            }
        }
        
        // Сохраняем состояние кнопки перед отправкой
        submitBtn.disabled = true;
        if (submitText) submitText.style.display = 'none';
        if (submitSpinner) submitSpinner.style.display = 'inline';
        
        var fd = new FormData();
        fd.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
        pendingIds.forEach(function(id) { fd.append('ids[]', id); });
        fd.append('operation_mode', operationMode);
        
        if (operationMode === 'move_component') {
            var responsibleForMove = targetSystemBlockUserId || userId;
            if (responsibleForMove !== '') {
                fd.append('responsible_user_id', responsibleForMove === '0' ? '' : responsibleForMove);
            }
            fd.append('target_system_block_id', targetSystemBlockId);
            fd.append('link_type', componentLinkType);
        } else if (userId !== '') {
            fd.append('responsible_user_id', userId === '0' ? '' : userId);
        }
        if (locationId !== '') {
            fd.append('location_id', locationId);
        }
        if (statusId !== '') {
            fd.append('status_id', statusId);
        }
        if (operationMode === 'dismissal') {
            if (dismissalTargetUserId !== '') {
                fd.append('dismissal_target_user_id', dismissalTargetUserId);
            }
            if (dismissalToWarehouse) {
                fd.append('dismissal_to_warehouse', '1');
            }
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
                        if (res.details.status_changed > 0) {
                            details.push('Статус изменен: ' + res.details.status_changed);
                        }
                        if (details.length > 0) {
                            message += '\\n• ' + details.join('\\n• ');
                        }
                    }
                    // Восстанавливаем состояние кнопки перед закрытием модального окна
                    resetSubmitButton();
                    // Очищаем данные после успешного сохранения
                    pendingIds = [];
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
        pendingIds = ids || [];
        equipmentData = [];
        equipmentSummary = {};
        syncMoveComponentOperationOption();

        // Сброс полей
        var u = document.getElementById('reassignUserId');
        var l = document.getElementById('reassignLocationId');
        var s = document.getElementById('reassignStatusId');
        if (u) setUserSelectValue(u, '');
        if (l) setUserSelectValue(l, '');
        if (s) setUserSelectValue(s, '');
        var mode = document.getElementById('reassignOperationMode');
        var targetSb = document.getElementById('targetSystemBlockId');
        var targetSbUser = document.getElementById('targetSystemBlockUserId');
        var dUser = document.getElementById('dismissalTargetUserId');
        var dWarehouse = document.getElementById('dismissalToWarehouse');
        if (mode) mode.value = 'reassign';
        if (targetSbUser) setUserSelectValue(targetSbUser, '');
        if (targetSb) targetSb.innerHTML = '<option value=\"\">— сначала выберите пользователя —</option>';
        if (dUser) setUserSelectValue(dUser, '');
        if (dWarehouse) dWarehouse.checked = false;
        updateModeHint();
        onModeChanged();
        
        // Скрыть предпросмотр и очистить его содержимое
        var preview = document.getElementById('reassignPreview');
        var previewList = document.getElementById('reassignPreviewList');
        if (preview) {
            preview.classList.add('arm-reassign-preview--hidden');
        }
        if (previewList) {
            previewList.innerHTML = '';
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
        if (pendingIds.length > 0) {
            loadSelectedEquipmentInfo(pendingIds);
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

        modalRoot.find('#reassignUserId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                var opMode = (jQuery('#reassignOperationMode').val() || 'reassign');
                if (opMode === 'reassign' && this.value && this.value !== '0') {
                    applyDefaultLocationForReassign(this.value);
                }
                scheduleUpdatePreview();
            });

        modalRoot.find('#dismissalTargetUserId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                var userId = jQuery(this).val() || '';
                if (userId) {
                    applyPrimaryLocationForUser(userId);
                }
                scheduleUpdatePreview();
            });

        modalRoot.find('#reassignLocationId, #reassignStatusId')
            .off('.reassignArmField')
            .on('change.reassignArmField select2:select.reassignArmField select2:clear.reassignArmField', function() {
                scheduleUpdatePreview();
            });

        modalRoot.find('#targetSystemBlockId, #reassignOperationMode, #dismissalToWarehouse, #componentLinkType, #moveComponentChildId')
            .off('.reassignArmField')
            .on('change.reassignArmField', function() {
                if (this.id === 'targetSystemBlockId') {
                    applyDefaultLocationFromTargetSystemBlock();
                }
                if (this.id === 'componentLinkType' || this.id === 'moveComponentChildId') {
                    syncMoveComponentChildPicker();
                }
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

        var modeEl = document.getElementById('reassignOperationMode');
        if (modeEl && !modeEl.hasAttribute('data-handler-attached')) {
            modeEl.addEventListener('change', onModeChanged);
            modeEl.setAttribute('data-handler-attached', 'true');
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
                
                if (
                    target.id === 'reassignUserId' ||
                    target.id === 'reassignLocationId' ||
                    target.id === 'reassignStatusId' ||
                    target.id === 'targetSystemBlockId' ||
                    target.id === 'targetSystemBlockUserId' ||
                    target.id === 'dismissalTargetUserId' ||
                    target.id === 'dismissalToWarehouse' ||
                    target.id === 'reassignOperationMode' ||
                    target.id === 'componentLinkType' ||
                    target.id === 'moveComponentChildId'
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
                    if (target.id === 'reassignUserId') {
                        var opMode = (document.getElementById('reassignOperationMode') || {}).value || 'reassign';
                        if (opMode === 'reassign' && target.value && target.value !== '0') {
                            applyDefaultLocationForReassign(target.value);
                        }
                    }
                    if (target.id === 'componentLinkType' || target.id === 'moveComponentChildId') {
                        syncMoveComponentChildPicker();
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
