<?php

use yii\helpers\Html;

/** @var yii\web\View $this */
/** @var array<int, string> $users */
/** @var array<int, string> $locations */

$warehouseLocationIds = array_keys($warehouseLocations ?? []);
?>

<div class="modal fade" id="issueKitModal" tabindex="-1" aria-labelledby="issueKitModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-fullscreen arm-reassign-modal__dialog">
        <div class="modal-content arm-reassign-modal arm-op-modal issue-kit-modal">
            <div class="modal-header arm-reassign-modal__header">
                <h5 class="modal-title" id="issueKitModalLabel">
                    <i class="fas fa-box-open" aria-hidden="true"></i>
                    Выдача комплекта со склада
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body arm-reassign-modal__body">
                <div class="arm-reassign-layout issue-kit-layout">
                    <aside class="arm-reassign-layout__aside issue-kit-layout__aside" aria-label="Превью выдачи">
                        <div class="arm-op-aside">
                            <section class="arm-op-aside__block arm-op-aside__block--primary" aria-labelledby="issueKitCompositionPreviewTitle">
                                <div class="arm-op-aside__head">
                                    <h6 class="arm-op-aside__title" id="issueKitCompositionPreviewTitle">
                                        <i class="fas fa-cubes" aria-hidden="true"></i>
                                        Состав комплекта
                                    </h6>
                                    <span class="arm-op-aside__badge" id="issueKitCompositionCount">0</span>
                                </div>
                                <div id="issueKitCompositionList" class="arm-op-aside__scroll">
                                    <div class="arm-op-aside__empty">
                                        <i class="fas fa-box" aria-hidden="true"></i>
                                        <span class="arm-op-aside__empty-text">Выберите технику справа — здесь появится состав комплекта</span>
                                    </div>
                                </div>
                            </section>

                            <section class="arm-op-aside__block arm-op-aside__block--changes" aria-labelledby="issueKitPreviewTitle">
                                <div class="arm-op-aside__head">
                                    <h6 class="arm-op-aside__title" id="issueKitPreviewTitle">
                                        <i class="fas fa-arrow-right-arrow-left" aria-hidden="true"></i>
                                        Что изменится
                                    </h6>
                                </div>
                                <div id="issueKitPreview" class="arm-op-changes" role="status" aria-live="polite">
                                    <ul id="issueKitPreviewList" class="arm-op-changes__list">
                                        <li class="arm-op-change arm-op-change--muted">
                                            <span class="arm-op-change__label">Ожидание</span>
                                            <span class="arm-op-change__body">
                                                <span class="arm-op-change__to">Укажите получателя и состав комплекта</span>
                                            </span>
                                        </li>
                                    </ul>
                                </div>
                            </section>
                        </div>
                    </aside>

                    <div class="arm-reassign-layout__main">
                        <section class="arm-reassign-section" aria-labelledby="issueKitRecipientTitle">
                            <h6 class="arm-reassign-section__title arm-reassign-section__title--plain" id="issueKitRecipientTitle">
                                <i class="fas fa-user arm-reassign-section__title-icon" aria-hidden="true"></i>
                                Получатель
                            </h6>
                            <div class="row g-3">
                                <div class="col-md-6 js-user-select-field">
                                    <label class="form-label" for="issueKitUserId">Пользователь <span class="text-danger">*</span></label>
                                    <select id="issueKitUserId" class="form-select js-user-select-search" data-placeholder="Выберите пользователя">
                                        <option value="">— выберите пользователя —</option>
                                        <?php foreach ($users ?? [] as $uid => $uname): ?>
                                        <option value="<?= (int) $uid ?>"><?= Html::encode($uname) ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                                <div class="col-md-6 js-user-select-field">
                                    <label class="form-label" for="issueKitLocationId">Помещение <span class="text-danger">*</span></label>
                                    <select id="issueKitLocationId" class="form-select js-user-select-search" data-placeholder="Выберите помещение">
                                        <option value="">— выберите помещение —</option>
                                        <?php foreach ($locations ?? [] as $lid => $lname):
                                            if (in_array((int) $lid, $warehouseLocationIds, true)) {
                                                continue;
                                            }
                                        ?>
                                        <option value="<?= (int) $lid ?>"><?= Html::encode($lname) ?></option>
                                        <?php endforeach; ?>
                                    </select>
                                </div>
                            </div>
                        </section>

                        <section class="arm-reassign-section" aria-labelledby="issueKitCompositionTitle">
                            <h6 class="arm-reassign-section__title arm-reassign-section__title--plain" id="issueKitCompositionTitle">
                                <i class="fas fa-server arm-reassign-section__title-icon" aria-hidden="true"></i>
                                Состав комплекта (со склада)
                            </h6>
                            <p class="arm-reassign-section__lead mb-3">
                                Укажите системный блок и при необходимости мониторы и ИБП. Можно выбрать несколько мониторов. В списке — наименование, инвентарный номер и складское помещение.
                            </p>
                            <div class="row g-3">
                                <div class="col-md-12">
                                    <label class="form-label" for="issueKitHostId">Системный блок <span class="text-danger">*</span></label>
                                    <select id="issueKitHostId" class="form-select js-user-select-search" data-placeholder="Выберите системный блок">
                                        <option value="">— загрузка… —</option>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label" for="issueKitHostname">Имя компьютера</label>
                                    <input type="text" id="issueKitHostname" class="form-control" maxlength="200"
                                           placeholder="Например, pc-ivanov" autocomplete="off">
                                    <div class="form-text text-muted small">Необязательно. Можно задать новое имя при выдаче.</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label" for="issueKitIp">IP-адрес</label>
                                    <input type="text" id="issueKitIp" class="form-control" maxlength="100"
                                           placeholder="192.168.1.10" autocomplete="off">
                                    <div class="form-text text-muted small">Необязательно. Сохраняется в карточке ПК.</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label" for="issueKitMonitorIds">Мониторы</label>
                                    <select id="issueKitMonitorIds" class="form-select js-user-select-search" multiple
                                            data-placeholder="Выберите мониторы">
                                    </select>
                                    <div class="form-text text-muted small">Необязательно. Можно выбрать несколько.</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label" for="issueKitUpsId">ИБП</label>
                                    <select id="issueKitUpsId" class="form-select js-user-select-search" data-placeholder="Не выдавать">
                                        <option value="">— не выдавать —</option>
                                    </select>
                                </div>
                            </div>
                            <div id="issueKitOptionsEmpty" class="alert alert-warning py-2 px-3 mt-3 mb-0 small" style="display:none;">
                                На складе нет доступных единиц для выдачи комплекта.
                            </div>
                        </section>
                    </div>
                </div>
            </div>
            <div class="modal-footer arm-reassign-modal__footer arm-op-modal__footer">
                <button type="button" class="btn arm-op-modal__btn arm-op-modal__btn--cancel" data-bs-dismiss="modal">Отмена</button>
                <button type="button" class="btn arm-op-modal__btn arm-op-modal__btn--primary" id="issueKitSubmit">
                    <span class="issue-kit-submit-text"><i class="fas fa-check" aria-hidden="true"></i> Выдать комплект</span>
                    <span class="issue-kit-submit-spinner" style="display:none;">
                        <i class="fas fa-circle-notch fa-spin" aria-hidden="true"></i> Выдача…
                    </span>
                </button>
            </div>
        </div>
    </div>
</div>
