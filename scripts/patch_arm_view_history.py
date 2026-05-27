# -*- coding: utf-8 -*-
from pathlib import Path

D, ED = "<" + "motion", "</" + "motion>"
D, ED = "<" + "motion".replace("motion", "v"), "</" + "motion>".replace("motion", "v")
D, ED = "<div", "</motion>".replace("motion", "v")
D, ED = "<" + "div", "</" + "div>"

p = Path(__file__).resolve().parents[1] / "ias_uch_vnii" / "views" / "arm" / "view.php"
t = p.read_text(encoding="utf-8")

old = f"""        <h2 id="arm-view-history-title" class="arm-view-section__title">История изменений</h2>
        <ul class="arm-view-timeline">
            <?php foreach ($history as $h): ?>
            <li class="arm-view-timeline__item">
                {D} class="arm-view-timeline__date"><?= Html::encode($formatDateTime($h->changed_at)) ?>{ED}
                {D} class="arm-view-timeline__event">
                    <?= Html::encode($eventTypeLabels[$h->event_type] ?? $h->event_type) ?>
                {ED}
                <?php if (trim((string) $h->comment) !== ''): ?>
                    {D} class="arm-view-timeline__comment"><?= Html::encode($h->comment) ?>{ED}
                <?php endif; ?>
            </li>
            <?php endforeach; ?>"""

new = f"""        <h2 id="arm-view-history-title" class="arm-view-section__title">История перемещений и изменений</h2>
        <p class="arm-view-section__hint text-muted small mb-3">Когда, куда перемещалась техника и кому назначалась.</p>
        <ul class="arm-view-timeline">
            <?php foreach ($history as $h): ?>
            <?php
                $details = trim($h->getFormattedDetails());
                $commentLabel = $h->getCommentLabel();
                $actorName = $h->changedByUser
                    ? trim((string) ($h->changedByUser->full_name ?: $h->changedByUser->email ?: ''))
                    : '';
            ?>
            <li class="arm-view-timeline__item">
                {D} class="arm-view-timeline__date"><?= Html::encode($formatDateTime($h->changed_at)) ?>{ED}
                {D} class="arm-view-timeline__event">
                    <?= Html::encode($eventTypeLabels[$h->event_type] ?? $h->event_type) ?>
                {ED}
                <?php if ($details !== ''): ?>
                    {D} class="arm-view-timeline__detail"><?= Html::encode($details) ?>{ED}
                <?php endif; ?>
                <?php if ($actorName !== ''): ?>
                    {D} class="arm-view-timeline__actor">Выполнил: <?= Html::encode($actorName) ?>{ED}
                <?php endif; ?>
                <?php if ($commentLabel !== null): ?>
                    {D} class="arm-view-timeline__comment"><?= Html::encode($commentLabel) ?>{ED}
                <?php endif; ?>
            </li>
            <?php endforeach; ?>"""

if old not in t:
    raise SystemExit("block not found")
p.write_text(t.replace(old, new, 1), encoding="utf-8")
print("patched")
