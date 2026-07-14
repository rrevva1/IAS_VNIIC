<?php
/**
 * Просмотр пользователя / «Мой профиль» (отдельная страница).
 *
 * @var yii\web\View $this
 * @var app\models\entities\Users $model
 * @var app\models\entities\Equipment[] $equipment
 * @var app\models\entities\AuditEvent[] $recentActions
 * @var bool $isOwnProfile
 * @var bool $isAdminViewer
 * @var array{total: int, open: int} $taskStats
 */

use app\assets\UsersAsset;
use yii\helpers\Url;

UsersAsset::register($this);

$isOwnProfile = $isOwnProfile ?? (Yii::$app->user->identity && (int) Yii::$app->user->identity->id === (int) $model->id);
$isAdminViewer = $isAdminViewer ?? (Yii::$app->user->identity && Yii::$app->user->identity->isAdmin());

if ($isAdminViewer && !$isOwnProfile) {
    $this->title = $model->full_name;
    $this->params['breadcrumbs'][] = ['label' => 'Пользователи', 'url' => ['index']];
    $this->params['breadcrumbs'][] = $model->full_name;
} else {
    $this->title = 'Мой профиль';
    $this->params['breadcrumbs'] = [];
}

echo $this->render('_view_content', [
    'model' => $model,
    'equipment' => $equipment ?? [],
    'recentActions' => $recentActions ?? [],
    'isOwnProfile' => $isOwnProfile,
    'isAdminViewer' => $isAdminViewer,
    'taskStats' => $taskStats ?? ['total' => 0, 'open' => 0],
    'isModal' => false,
]);

if ($isOwnProfile) {
    echo $this->render('_profile_edit_modal');
    $this->registerJs(
        'window.profileEditModalUrl = ' . json_encode(Url::to(['users/profile-modal'])) . ';',
        \yii\web\View::POS_HEAD
    );
}
