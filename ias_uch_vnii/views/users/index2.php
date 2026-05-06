<?php
use kartik\grid\GridView;
 
// Generate a bootstrap responsive striped table with row highlighted on hover
echo GridView::widget([
    'dataProvider'=> $dataProvider,
    'filterModel' => $searchModel,
    'columns' => $gridColumns,
    'responsive'=>true,
    'hover'=>true
]);