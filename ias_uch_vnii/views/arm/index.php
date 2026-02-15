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
$this->params['breadcrumbs'][] = $this->title;

$equipmentTypes = $equipmentTypes ?? [];
?>
<div class="arm-index">
    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
        <div class="btn-group">
            <?= Html::a('<i class="glyphicon glyphicon-plus"></i> Добавить технику', ['create'], ['class' => 'btn btn-success']) ?>
            <?= Html::button('<i class="glyphicon glyphicon-refresh"></i> Обновить', [
                'class' => 'btn btn-outline-secondary',
                'onclick' => 'refreshArmGrid()',
            ]) ?>
            <?= Html::button('<i class="glyphicon glyphicon-transfer"></i> Переместить/Переназначить', [
                'class' => 'btn btn-primary',
                'id' => 'btnReassignArm',
                'style' => 'display:none;',
            ]) ?>
        </div>
    </div>

    <ul class="nav nav-tabs arm-type-tabs mb-3" role="tablist">
        <li class="nav-item">
            <a class="nav-link active arm-type-tab" href="#" data-type-id="">Вся техника</a>
        </li>
        <?php foreach ($equipmentTypes as $type): ?>
        <li class="nav-item">
            <a class="nav-link arm-type-tab" href="#" data-type-id="<?= Html::encode($type['id'] ?? '') ?>"><?= Html::encode($type['name'] ?? '') ?></a>
        </li>
        <?php endforeach; ?>
    </ul>

    <div id="agGridArmContainer" class="ag-theme-quartz" style="width: 100%; height: 65vh; min-height: 400px;">
        <div class="text-center p-4 text-muted">
            <span class="glyphicon glyphicon-refresh glyphicon-spin"></span>
            <p>Загрузка таблицы...</p>
        </div>
    </div>
</div>

<div class="modal fade" id="reassignArmModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Переместить/Переназначить</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Закрыть"></button>
            </div>
            <div class="modal-body">
                <p class="text-muted small">Изменяйте только те поля, которые нужно обновить. Пустые поля не изменяются.</p>
                <div class="mb-3">
                    <label class="form-label">Ответственный</label>
                    <select id="reassignUserId" class="form-select">
                        <option value="">— не менять —</option>
                        <?php foreach ($users ?? [] as $uid => $uname): ?>
                        <option value="<?= (int)$uid ?>"><?= Html::encode($uname) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Локация/Кабинет</label>
                    <select id="reassignLocationId" class="form-select">
                        <option value="">— не менять —</option>
                        <?php foreach ($locations ?? [] as $lid => $lname): ?>
                        <option value="<?= (int)$lid ?>"><?= Html::encode($lname) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Статус</label>
                    <select id="reassignStatusId" class="form-select">
                        <option value="">— не менять —</option>
                        <?php foreach ($statuses ?? [] as $sid => $sname): ?>
                        <option value="<?= (int)$sid ?>"><?= Html::encode($sname) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Отмена</button>
                <button type="button" class="btn btn-primary" id="reassignSubmit">Сохранить</button>
            </div>
        </div>
    </div>
</div>
<?php
$this->registerJs(
    "window.agGridArmDataUrl = " . json_encode(Url::to(['arm/get-grid-data'])) . ";",
    \yii\web\View::POS_HEAD
);
$this->registerJs(
    "window.agGridArmCurrentTypeId = '';" .
    "window.agGridArmReassignUrl = " . json_encode(Url::to(['arm/reassign'])) . ";" .
    "window.armReassignCsrf = {param: " . json_encode(Yii::$app->request->csrfParam) . ", token: " . json_encode(Yii::$app->request->csrfToken) . "};",
    \yii\web\View::POS_HEAD
);
$this->registerJs("
(function(){
    var reassignModal, pendingIds = [];
    window.openReassignModal = function(ids) {
        pendingIds = ids || [];
        var u=document.getElementById('reassignUserId'); if(u)u.value='';
        var l=document.getElementById('reassignLocationId'); if(l)l.value='';
        var s=document.getElementById('reassignStatusId'); if(s)s.value='';
        if (!reassignModal) reassignModal = new bootstrap.Modal(document.getElementById('reassignArmModal'));
        reassignModal.show();
    };
    document.addEventListener('DOMContentLoaded', function(){
        var btn = document.getElementById('reassignSubmit');
        if (btn) btn.addEventListener('click', function(){
            var uid = document.getElementById('reassignUserId').value;
            var lid = document.getElementById('reassignLocationId').value;
            var sid = document.getElementById('reassignStatusId').value;
            if (!uid && !lid && !sid) { alert('Выберите хотя бы одно поле для изменения.'); return; }
            var fd = new FormData();
            fd.append(window.armReassignCsrf.param, window.armReassignCsrf.token);
            pendingIds.forEach(function(id){ fd.append('ids[]', id); });
            if (uid) fd.append('responsible_user_id', uid);
            if (lid) fd.append('location_id', lid);
            if (sid) fd.append('status_id', sid);
            fetch(window.agGridArmReassignUrl, { method: 'POST', body: fd })
                .then(function(r){ return r.json(); })
                .then(function(res){
                    if (res.success) {
                        reassignModal.hide();
                        if (typeof refreshArmGrid === 'function') refreshArmGrid();
                        alert(res.message);
                    } else { alert(res.message || 'Ошибка'); }
                })
                .catch(function(){ alert('Ошибка сети'); });
        });
    });
})();
", \yii\web\View::POS_END);
