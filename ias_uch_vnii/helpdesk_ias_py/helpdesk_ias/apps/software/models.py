"""
Модуль software (ПО и лицензии).

Фаза 3: минимальный каркас, чтобы схема была согласованной и готовой к развитию.
"""

from __future__ import annotations

from django.conf import settings
from django.db import models


class Software(models.Model):
    """Каталог ПО."""

    name = models.CharField("Название", max_length=255)
    vendor = models.CharField("Производитель", max_length=255, blank=True)
    description = models.TextField("Описание", blank=True)

    class Meta:
        verbose_name = "ПО"
        verbose_name_plural = "ПО"
        db_table = "software"
        constraints = [
            models.UniqueConstraint(fields=["name", "vendor"], name="uq_sw_name_vendor"),
        ]
        indexes = [
            models.Index(fields=["name"]),
            models.Index(fields=["vendor"]),
        ]

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class License(models.Model):
    """Лицензия на ПО."""

    software = models.ForeignKey(
        Software,
        on_delete=models.CASCADE,
        related_name="licenses",
        verbose_name="ПО",
    )
    key = models.CharField("Лицензионный ключ", max_length=255, blank=True)
    valid_from = models.DateField("Действует с", null=True, blank=True)
    valid_to = models.DateField("Действует до", null=True, blank=True)
    seats = models.PositiveIntegerField("Кол-во мест", default=1)
    comment = models.TextField("Комментарий", blank=True)

    class Meta:
        verbose_name = "Лицензия"
        verbose_name_plural = "Лицензии"
        db_table = "licenses"
        indexes = [
            models.Index(fields=["software"]),
            models.Index(fields=["valid_to"]),
        ]


class SoftwareInstall(models.Model):
    """Установка ПО на оборудование."""

    software = models.ForeignKey(
        Software,
        on_delete=models.PROTECT,
        related_name="installs",
        verbose_name="ПО",
    )
    equipment_id = models.IntegerField(
        "ID оборудования",
        help_text="На Фазе 3 держим как int. На Фазе 5+ переведём на FK к assets.Equipment.",
    )
    installed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="software_installs",
        verbose_name="Кто установил",
        null=True,
        blank=True,
    )
    installed_at = models.DateTimeField("Установлено", auto_now_add=True)
    version = models.CharField("Версия", max_length=100, blank=True)
    license = models.ForeignKey(
        License,
        on_delete=models.SET_NULL,
        related_name="installs",
        verbose_name="Лицензия",
        null=True,
        blank=True,
    )

    class Meta:
        verbose_name = "Установка ПО"
        verbose_name_plural = "Установки ПО"
        db_table = "software_installs"
        indexes = [
            models.Index(fields=["equipment_id"]),
            models.Index(fields=["software"]),
            models.Index(fields=["installed_at"]),
        ]
