from django.db import migrations


def seed_task_statuses(apps, schema_editor):
    TaskStatus = apps.get_model("tasks", "TaskStatus")
    for name in ["Открыта", "В работе", "Отменено", "Завершено"]:
        TaskStatus.objects.get_or_create(name=name)


class Migration(migrations.Migration):
    dependencies = [
        ("tasks", "0003_alter_attachment_created_at_alter_task_created_at_and_more"),
    ]

    operations = [
        migrations.RunPython(seed_task_statuses, migrations.RunPython.noop),
    ]

