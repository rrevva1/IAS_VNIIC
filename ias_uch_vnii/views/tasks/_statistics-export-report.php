<?php
/**
 * Частичное представление отчёта статистики для экспорта в HTML и PDF.
 * @var string $reportTitle Заголовок отчёта
 * @var string $column1Label Заголовок первого столбца (Пользователь / Исполнитель)
 * @var string $column2Label Заголовок второго столбца
 * @var string $column3Label Заголовок третьего столбца
 * @var array $rows Массив строк: [['name' => ..., 'count' => ..., 'percentage' => ...], ...]
 * @var string $totalLabel Подпись итога (например, "Общее количество заявок")
 * @var int|string $totalValue Значение итога
 * @var bool $forPdf Упрощённые стили для PDF
 */
use yii\helpers\Html;

$forPdf = isset($forPdf) && $forPdf;
?>
<div class="stats-report<?= $forPdf ? ' stats-report-pdf' : '' ?>">
    <h1><?= Html::encode($reportTitle) ?></h1>
    <p class="report-date">Дата формирования: <?= date('d.m.Y H:i') ?></p>
    <p class="report-total"><?= Html::encode($totalLabel) ?>: <strong><?= Html::encode($totalValue) ?></strong></p>
    <table class="stats-report-table">
        <thead>
            <tr>
                <th>№</th>
                <th><?= Html::encode($column1Label) ?></th>
                <th><?= Html::encode($column2Label) ?></th>
                <th><?= Html::encode($column3Label) ?></th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($rows as $index => $row): ?>
            <tr>
                <td><?= $index + 1 ?></td>
                <td><?= Html::encode($row['name']) ?></td>
                <td><?= Html::encode($row['count']) ?></td>
                <td><?= Html::encode($row['percentage']) ?>%</td>
            </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
</div>
