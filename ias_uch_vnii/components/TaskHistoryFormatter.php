<?php

namespace app\components;

use app\models\dictionaries\DicTaskStatus;
use app\models\entities\TaskHistory;
use app\models\entities\Users;
use yii\helpers\Html;
use yii\helpers\StringHelper;

/**
 * Человекочитаемое представление записей task_history.
 */
class TaskHistoryFormatter
{
    private const FIELD_LABELS = [
        'status_id' => 'Смена статуса',
        'executor_id' => 'Исполнитель',
        'comment' => 'Комментарий исполнителя',
    ];

    /** @var array<int, array{name: string, code: string}> */
    private array $statusById = [];

    /** @var array<int, string> */
    private array $userNamesById = [];

    /**
     * @param TaskHistory[] $records
     */
    public function __construct(array $records)
    {
        $this->preloadLookups($records);
    }

    /**
     * @param TaskHistory[] $records
     * @return array<int, array{
     *     changed_at: string,
     *     type: string,
     *     title: string,
     *     detail_html: string,
     *     note: string|null,
     *     user_name: string|null
     * }>
     */
    public function formatAll(array $records): array
    {
        $items = [];
        foreach ($records as $record) {
            $items[] = $this->formatOne($record);
        }

        return $items;
    }

    /**
     * @param TaskHistory[] $records
     */
    private function preloadLookups(array $records): void
    {
        $statusIds = [];
        $userIds = [];

        foreach ($records as $record) {
            if ($record->field_name === 'status_id') {
                foreach ([$record->old_value, $record->new_value] as $raw) {
                    $id = $this->normalizeId($raw);
                    if ($id !== null) {
                        $statusIds[$id] = $id;
                    }
                }
            }
            if ($record->field_name === 'executor_id') {
                foreach ([$record->old_value, $record->new_value] as $raw) {
                    $id = $this->normalizeId($raw);
                    if ($id !== null) {
                        $userIds[$id] = $id;
                    }
                }
            }
            if ($record->changed_by) {
                $userIds[(int) $record->changed_by] = (int) $record->changed_by;
            }
        }

        if ($statusIds !== []) {
            $rows = DicTaskStatus::find()
                ->select(['id', 'status_name', 'status_code'])
                ->where(['id' => array_values($statusIds)])
                ->asArray()
                ->all();
            foreach ($rows as $row) {
                $this->statusById[(int) $row['id']] = [
                    'name' => (string) $row['status_name'],
                    'code' => (string) $row['status_code'],
                ];
            }
        }

        if ($userIds !== []) {
            $this->userNamesById = Users::find()
                ->select(['full_name', 'id'])
                ->where(['id' => array_values($userIds)])
                ->indexBy('id')
                ->column();
        }
    }

    /**
     * @return array{
     *     changed_at: string,
     *     type: string,
     *     title: string,
     *     detail_html: string,
     *     note: string|null,
     *     user_name: string|null
     * }
     */
    private function formatOne(TaskHistory $record): array
    {
        $field = (string) $record->field_name;
        $type = $field === 'status_id' ? 'status' : ($field === 'executor_id' ? 'executor' : ($field === 'comment' ? 'comment' : 'other'));
        $title = self::FIELD_LABELS[$field] ?? $field;
        $detailHtml = match ($field) {
            'status_id' => $this->formatStatusChange($record),
            'executor_id' => $this->formatExecutorChange($record),
            'comment' => $this->formatCommentChange($record),
            default => $this->formatGenericChange($record),
        };
        $note = $this->normalizeNote($record->comment, $field);

        return [
            'changed_at' => (string) $record->changed_at,
            'type' => $type,
            'title' => $title,
            'detail_html' => $detailHtml,
            'note' => $note,
            'user_name' => $this->resolveUserName($record->changed_by),
        ];
    }

    private function formatStatusChange(TaskHistory $record): string
    {
        $oldId = $this->normalizeId($record->old_value);
        $newId = $this->normalizeId($record->new_value);

        if ($oldId === null && $newId !== null) {
            return '<span class="tasks-view-history__text">Установлен статус '
                . $this->renderStatusPill($newId)
                . '</span>';
        }

        if ($oldId !== null && $newId === null) {
            return '<span class="tasks-view-history__text">Статус снят: было '
                . $this->renderStatusPill($oldId)
                . '</span>';
        }

        return '<div class="tasks-view-history__status-change" role="text">'
            . $this->renderStatusPill($oldId)
            . '<span class="tasks-view-history__arrow" aria-hidden="true">→</span>'
            . $this->renderStatusPill($newId)
            . '</div>';
    }

    private function formatExecutorChange(TaskHistory $record): string
    {
        $oldName = $this->resolveUserLabel($record->old_value);
        $newName = $this->resolveUserLabel($record->new_value);

        if ($oldName === 'не назначен' && $newName !== 'не назначен') {
            return '<span class="tasks-view-history__text">Назначен исполнитель: <strong>'
                . Html::encode($newName)
                . '</strong></span>';
        }

        if ($oldName !== 'не назначен' && $newName === 'не назначен') {
            return '<span class="tasks-view-history__text">Исполнитель снят: было <strong>'
                . Html::encode($oldName)
                . '</strong></span>';
        }

        return '<span class="tasks-view-history__text">'
            . Html::encode($oldName)
            . ' <span class="tasks-view-history__arrow" aria-hidden="true">→</span> '
            . Html::encode($newName)
            . '</span>';
    }

    private function formatCommentChange(TaskHistory $record): string
    {
        $oldText = trim((string) ($record->old_value ?? ''));
        $newText = trim((string) ($record->new_value ?? ''));

        if ($oldText === '' && $newText !== '') {
            return '<span class="tasks-view-history__text">Добавлен комментарий</span>'
                . $this->renderCommentQuote($newText);
        }

        if ($oldText !== '' && $newText === '') {
            return '<span class="tasks-view-history__text">Комментарий удалён</span>';
        }

        return '<span class="tasks-view-history__text">Комментарий изменён</span>'
            . $this->renderCommentQuote($newText !== '' ? $newText : $oldText);
    }

    private function formatGenericChange(TaskHistory $record): string
    {
        $old = trim((string) ($record->old_value ?? ''));
        $new = trim((string) ($record->new_value ?? ''));

        if ($old === '' && $new === '') {
            return '<span class="tasks-view-history__text text-muted">Изменение без данных</span>';
        }

        if ($old === '') {
            return '<span class="tasks-view-history__text">'
                . Html::encode(StringHelper::truncate($new, 120))
                . '</span>';
        }

        return '<span class="tasks-view-history__text">'
            . Html::encode(StringHelper::truncate($old, 80))
            . ' <span class="tasks-view-history__arrow" aria-hidden="true">→</span> '
            . Html::encode(StringHelper::truncate($new, 80))
            . '</span>';
    }

    private function renderCommentQuote(string $text): string
    {
        if ($text === '') {
            return '';
        }

        return '<blockquote class="tasks-view-history__quote">«'
            . Html::encode(StringHelper::truncate($text, 200))
            . '»</blockquote>';
    }

    private function renderStatusPill(?int $statusId): string
    {
        if ($statusId === null) {
            return '<span class="text-muted">—</span>';
        }

        $meta = $this->statusById[$statusId] ?? null;
        if ($meta === null) {
            return '<span class="text-muted">ID ' . $statusId . '</span>';
        }

        return DicTaskStatus::renderStatusPill($meta['code'], $meta['name']);
    }

    private function resolveUserLabel(?string $raw): string
    {
        $id = $this->normalizeId($raw);
        if ($id === null) {
            return 'не назначен';
        }

        return $this->userNamesById[$id] ?? ('ID ' . $id);
    }

    private function resolveUserName(?int $userId): ?string
    {
        if (!$userId) {
            return null;
        }

        $name = $this->userNamesById[$userId] ?? null;
        if ($name !== null && $name !== '') {
            return $name;
        }

        $user = Users::findOne($userId);
        if ($user === null) {
            return null;
        }

        $resolved = trim((string) ($user->full_name ?: $user->email ?: ''));
        return $resolved !== '' ? $resolved : null;
    }

    private function normalizeNote(?string $comment, string $field): ?string
    {
        $comment = trim((string) $comment);
        if ($comment === '') {
            return null;
        }

        if ($field === 'comment' && mb_strlen($comment) > 200) {
            return StringHelper::truncate($comment, 200);
        }

        return $comment;
    }

    private function normalizeId($raw): ?int
    {
        if ($raw === null || $raw === '') {
            return null;
        }
        $id = (int) $raw;

        return $id > 0 ? $id : null;
    }
}
