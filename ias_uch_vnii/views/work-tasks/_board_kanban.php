<?php

use app\models\dictionaries\DicWorkTaskStatus;
use yii\helpers\Html;
use yii\helpers\Url;

/** @var yii\web\View $this */
/** @var array $boardColumns */
/** @var array<string, app\models\entities\WorkTask[]> $byStatus */
/** @var array<int, string[]> $allowedByTask */
/** @var string $filter */
/** @var bool $showCancelledColumn */
?>

<div class="work-kanban" id="workKanbanBoard" data-board-filter="<?= Html::encode($filter) ?>">
    <?php foreach ($boardColumns as $step):
        $code = $step['code'];
        $columnTasks = $byStatus[$code] ?? [];
        ?>
    <section class="work-kanban__column work-kanban__column--<?= Html::encode($code) ?>"
             data-status-code="<?= Html::encode($code) ?>"
             aria-label="<?= Html::encode($step['name']) ?>">
        <header class="work-kanban__column-header">
            <span class="work-kanban__column-title"><?= Html::encode($step['name']) ?></span>
            <span class="work-kanban__column-count"><?= count($columnTasks) ?></span>
        </header>
        <div class="work-kanban__cards" data-drop-zone>
            <?php foreach ($columnTasks as $task):
                $allowed = $allowedByTask[$task->id] ?? [];
                $draggable = $allowed !== [];
                ?>
            <article class="work-task-card work-task-card--kanban<?= $draggable ? '' : ' work-task-card--locked' ?>"
                     data-task-id="<?= (int) $task->id ?>"
                     data-status-code="<?= Html::encode($task->getStatusCode()) ?>"
                     data-allowed="<?= Html::encode(implode(',', $allowed)) ?>"
                     data-transition-url="<?= Html::encode(Url::to(['transition', 'id' => $task->id])) ?>"
                     <?= $draggable ? 'draggable="true"' : '' ?>>
                <?= $this->render('_card_header', ['task' => $task]) ?>
                <?= $this->render('_card_description', ['task' => $task]) ?>
                <?= $this->render('_card_meta', ['task' => $task]) ?>
            </article>
            <?php endforeach; ?>
        </div>
    </section>
    <?php endforeach; ?>

    <?php
    $cancelled = $byStatus[DicWorkTaskStatus::CODE_CANCELLED] ?? [];
    if ($showCancelledColumn && $cancelled !== []):
        ?>
    <section class="work-kanban__column work-kanban__column--cancelled"
             data-status-code="<?= Html::encode(DicWorkTaskStatus::CODE_CANCELLED) ?>"
             aria-label="Отменена">
        <header class="work-kanban__column-header">
            <span class="work-kanban__column-title">Отменена</span>
            <span class="work-kanban__column-count"><?= count($cancelled) ?></span>
        </header>
        <div class="work-kanban__cards" data-drop-zone>
            <?php foreach ($cancelled as $task): ?>
            <article class="work-task-card work-task-card--kanban work-task-card--locked"
                     data-task-id="<?= (int) $task->id ?>"
                     data-status-code="cancelled"
                     data-allowed="">
                <?= $this->render('_card_header', ['task' => $task]) ?>
                <?= $this->render('_card_description', ['task' => $task]) ?>
                <?= $this->render('_card_meta', ['task' => $task]) ?>
            </article>
            <?php endforeach; ?>
        </div>
    </section>
    <?php endif; ?>
</div>
