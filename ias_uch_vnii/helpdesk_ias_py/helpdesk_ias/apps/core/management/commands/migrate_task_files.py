from __future__ import annotations

import os
import shutil
from pathlib import Path

from django.conf import settings
from django.core.management.base import BaseCommand
from django.db import transaction

from apps.tasks.models import Attachment


class Command(BaseCommand):
    help = "Перенос/линковка файлов вложений в MEDIA_ROOT (идемпотентно)."

    def add_arguments(self, parser):
        parser.add_argument(
            "--src",
            default=str(Path(settings.BASE_DIR).parent.parent / "web" / "uploads" / "tasks"),
            help="Каталог со старыми файлами (обычно: <repo>/web/uploads/tasks/).",
        )
        parser.add_argument(
            "--mode",
            choices=["copy", "hardlink", "symlink"],
            default="copy",
            help="Способ переноса файлов.",
        )

    def handle(self, *args, **options):
        src_dir = Path(options["src"]).resolve()
        mode: str = options["mode"]

        if not src_dir.exists():
            raise SystemExit(f"Каталог src не найден: {src_dir}")

        media_root = Path(settings.MEDIA_ROOT).resolve()
        dest_dir = media_root / "legacy" / "tasks"
        dest_dir.mkdir(parents=True, exist_ok=True)

        moved = 0
        skipped = 0
        missing = 0

        def place_file(src: Path, dst: Path) -> None:
            if mode == "copy":
                shutil.copy2(src, dst)
                return
            if mode == "hardlink":
                os.link(src, dst)
                return
            if mode == "symlink":
                os.symlink(src, dst)
                return

        with transaction.atomic():
            for att in Attachment.objects.all().order_by("id").iterator(chunk_size=1000):
                legacy_path = (att.path or "").strip()
                filename = Path(legacy_path).name
                if not filename:
                    skipped += 1
                    continue

                # Если уже в новом формате — пропускаем
                if legacy_path.startswith("legacy/tasks/"):
                    skipped += 1
                    continue

                src_file = src_dir / filename
                if not src_file.exists():
                    missing += 1
                    continue

                dest_rel = Path("legacy") / "tasks" / filename
                dest_file = media_root / dest_rel

                if dest_file.exists():
                    # Если уже есть и размер совпадает — считаем ок
                    try:
                        if dest_file.stat().st_size == src_file.stat().st_size:
                            att.path = str(dest_rel).replace("\\", "/")
                            att.save(update_fields=["path"])
                            skipped += 1
                            continue
                    except OSError:
                        pass

                # Кладем файл
                place_file(src_file, dest_file)

                # Обновляем путь
                att.path = str(dest_rel).replace("\\", "/")
                att.save(update_fields=["path"])
                moved += 1

        self.stdout.write(
            self.style.SUCCESS(
                f"Готово. moved={moved}, skipped={skipped}, missing_src={missing}, src={src_dir}, dest={dest_dir}, mode={mode}"
            )
        )

