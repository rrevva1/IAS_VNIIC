<?php

use yii\helpers\Html;
use yii\helpers\Url;

$this->title = 'Карточки пользователей';
$this->params['breadcrumbs'][] = $this->title;
?>
<div class="user-equipment-cards-index">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h1 class="mb-0"><?= Html::encode($this->title) ?></h1>
    </div>

    <ul class="nav nav-tabs mb-3">
        <li class="nav-item">
            <a class="nav-link <?= $tab === 'all' ? 'active' : '' ?>" href="<?= Url::to(['user-equipment-cards/index', 'tab' => 'all']) ?>">Все карточки</a>
        </li>
        <li class="nav-item">
            <a class="nav-link <?= $tab === 'unsigned' ? 'active' : '' ?>" href="<?= Url::to(['user-equipment-cards/index', 'tab' => 'unsigned']) ?>">Неподписанные</a>
        </li>
    </ul>

    <div class="table-responsive">
        <table class="table table-bordered table-striped align-middle">
            <thead>
                <tr>
                    <th>#</th>
                    <th>Пользователь</th>
                    <th>Версия</th>
                    <th>Статус подписи</th>
                    <th>Подписано админом</th>
                    <th>Обновлено</th>
                    <th style="width: 260px;">Действия</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($cards)): ?>
                    <tr><td colspan="7" class="text-center text-muted">Карточек нет</td></tr>
                <?php else: ?>
                    <?php foreach ($cards as $card): ?>
                        <tr>
                            <td><?= (int) $card->id ?></td>
                            <td><?= Html::encode($card->user ? $card->user->getDisplayName() : '—') ?></td>
                            <td><?= (int) $card->version_no ?></td>
                            <td>
                                <?php if ($card->is_signed): ?>
                                    <span class="badge bg-success">Подписана</span>
                                <?php else: ?>
                                    <span class="badge bg-warning text-dark">Не подписана</span>
                                <?php endif; ?>
                            </td>
                            <td><?= Html::encode($card->signedByAdmin ? $card->signedByAdmin->getDisplayName() : '—') ?></td>
                            <td><?= Html::encode((string) ($card->updated_at ?: $card->created_at)) ?></td>
                            <td>
                                <div class="d-flex flex-column gap-1" style="min-width: 170px;">
                                    <?= Html::a('Скачать DOCX', ['user-equipment-cards/download', 'userId' => $card->user_id], ['class' => 'btn btn-sm btn-outline-primary']) ?>
                                    <?php if (!$card->is_signed): ?>
                                        <?= Html::beginForm(['user-equipment-cards/mark-signed', 'id' => $card->id], 'post') ?>
                                        <?= Html::submitButton('Подтвердить подпись', ['class' => 'btn btn-sm btn-success']) ?>
                                        <?= Html::endForm() ?>
                                    <?php endif; ?>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

