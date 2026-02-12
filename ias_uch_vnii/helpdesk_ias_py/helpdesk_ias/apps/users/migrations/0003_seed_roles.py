from django.db import migrations


def seed_roles(apps, schema_editor):
    Role = apps.get_model("users", "Role")
    for name in ["пользователь", "администратор"]:
        Role.objects.get_or_create(name=name)


class Migration(migrations.Migration):
    dependencies = [
        ("users", "0002_alter_user_created_at"),
    ]

    operations = [
        migrations.RunPython(seed_roles, migrations.RunPython.noop),
    ]

