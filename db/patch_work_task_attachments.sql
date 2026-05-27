-- Связь внутренних задач (work_tasks) с вложениями (desk_attachments).
-- Выполнить один раз, если миграция m260527_120000_work_task_attachments ещё не применялась:
--   psql -U postgres -d ias_vniic -f db/patch_work_task_attachments.sql

SET search_path TO tech_accounting;

CREATE TABLE IF NOT EXISTS work_task_attachments (
    id BIGSERIAL PRIMARY KEY,
    work_task_id BIGINT NOT NULL REFERENCES work_tasks(id) ON DELETE CASCADE,
    attachment_id BIGINT NOT NULL REFERENCES desk_attachments(id) ON DELETE CASCADE,
    linked_by BIGINT REFERENCES users(id) ON DELETE SET NULL,
    linked_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_work_task_attachments_task_attachment UNIQUE (work_task_id, attachment_id)
);

CREATE INDEX IF NOT EXISTS idx_work_task_attachments_task ON work_task_attachments(work_task_id);
CREATE INDEX IF NOT EXISTS idx_work_task_attachments_attachment ON work_task_attachments(attachment_id);

INSERT INTO migration (version, apply_time)
SELECT 'm260527_120000_work_task_attachments', EXTRACT(EPOCH FROM NOW())::INTEGER
WHERE NOT EXISTS (
    SELECT 1 FROM migration WHERE version = 'm260527_120000_work_task_attachments'
);
