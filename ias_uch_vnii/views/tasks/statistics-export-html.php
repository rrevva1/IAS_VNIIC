<?php
/**
 * Полная HTML-страница отчёта статистики (для экспорта в HTML и как источник для PDF).
 * @var string $reportTitle
 * @var string $column1Label
 * @var string $column2Label
 * @var string $column3Label
 * @var array $rows
 * @var string $totalLabel
 * @var int|string $totalValue
 * @var bool $forPdf
 */
use yii\helpers\Html;

$forPdf = isset($forPdf) && $forPdf;
$this->title = $reportTitle;
?>
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= Html::encode($reportTitle) ?></title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; color: #333; }
        .stats-report { max-width: 900px; margin: 0 auto; }
        .stats-report h1 { font-size: 1.5em; border-bottom: 1px solid #ddd; padding-bottom: 8px; }
        .report-date, .report-total { color: #666; margin: 8px 0; }
        .stats-report-table { width: 100%; border-collapse: collapse; margin-top: 16px; }
        .stats-report-table th, .stats-report-table td { border: 1px solid #ddd; padding: 8px 12px; text-align: left; }
        .stats-report-table th { background: #f5f5f5; font-weight: bold; }
        .stats-report-table td:nth-child(2) { text-align: left; }
        .stats-report-table td:nth-child(3), .stats-report-table td:nth-child(4) { text-align: center; }
        .stats-report-pdf .stats-report-table th { background: #e8e8e8; }
    </style>
</head>
<body>
<?= $this->render('_statistics-export-report', [
    'reportTitle' => $reportTitle,
    'column1Label' => $column1Label,
    'column2Label' => $column2Label,
    'column3Label' => $column3Label,
    'rows' => $rows,
    'totalLabel' => $totalLabel,
    'totalValue' => $totalValue,
    'forPdf' => $forPdf,
]) ?>
</body>
</html>
