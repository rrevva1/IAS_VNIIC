"""
Модуль assets (учёт техники/активов).

Модели ориентированы на baseline схему `ias_vnii`:
- locations / equipment / equip_history
- spr_parts / spr_chars / part_char_values
"""

from __future__ import annotations

from django.conf import settings
from django.db import models


class Location(models.Model):
    """Локации (кабинет/склад/серверная и т.п.)."""

    LOCATION_TYPES = (
        ("кабинет", "кабинет"),
        ("склад", "склад"),
        ("серверная", "серверная"),
        ("лаборатория", "лаборатория"),
        ("другое", "другое"),
    )

    name = models.CharField("Название", max_length=100, unique=True)
    location_type = models.CharField("Тип", max_length=50, choices=LOCATION_TYPES)
    floor = models.IntegerField("Этаж", null=True, blank=True)
    description = models.TextField("Описание", blank=True)

    class Meta:
        verbose_name = "Локация"
        verbose_name_plural = "Локации"
        db_table = "locations"
        indexes = [
            models.Index(fields=["location_type"]),
            models.Index(fields=["floor"]),
        ]

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class Equipment(models.Model):
    """Оборудование/актив (legacy: arm)."""

    name = models.CharField("Название", max_length=200)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="equipment",
        verbose_name="Закреплено за пользователем",
        null=True,
        blank=True,
    )
    location = models.ForeignKey(
        Location,
        on_delete=models.PROTECT,
        related_name="equipment",
        verbose_name="Локация",
    )
    description = models.TextField("Описание", blank=True)
    created_at = models.DateTimeField("Создано", auto_now_add=True)

    class Meta:
        verbose_name = "Оборудование"
        verbose_name_plural = "Оборудование"
        db_table = "equipment"
        indexes = [
            models.Index(fields=["user"]),
            models.Index(fields=["location"]),
            models.Index(fields=["created_at"]),
        ]

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class EquipHistory(models.Model):
    """История изменений по оборудованию."""

    equipment = models.ForeignKey(
        Equipment,
        on_delete=models.CASCADE,
        related_name="history",
        verbose_name="Оборудование",
    )
    changed_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.SET_NULL,
        related_name="equipment_changes",
        verbose_name="Кто изменил",
        null=True,
        blank=True,
    )
    change_type = models.CharField("Тип изменения", max_length=50)
    old_value = models.TextField("Старое значение", blank=True)
    new_value = models.TextField("Новое значение", blank=True)
    change_date = models.DateTimeField("Дата изменения", auto_now_add=True)
    comment = models.TextField("Комментарий", blank=True)

    class Meta:
        verbose_name = "История оборудования"
        verbose_name_plural = "История оборудования"
        db_table = "equip_history"
        indexes = [
            models.Index(fields=["equipment"]),
            models.Index(fields=["changed_by"]),
            models.Index(fields=["change_date"]),
        ]


class SprPart(models.Model):
    """Справочник комплектующих/частей (spr_parts)."""

    name = models.CharField("Название", max_length=100, unique=True)
    description = models.TextField("Описание", blank=True)

    class Meta:
        verbose_name = "Комплектующая"
        verbose_name_plural = "Комплектующие"
        db_table = "spr_parts"

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class SprChar(models.Model):
    """Справочник характеристик (spr_chars)."""

    name = models.CharField("Характеристика", max_length=100, unique=True)
    description = models.TextField("Описание", blank=True)
    measurement_unit = models.CharField("Ед. изм.", max_length=100, blank=True)

    class Meta:
        verbose_name = "Характеристика"
        verbose_name_plural = "Характеристики"
        db_table = "spr_chars"

    def __str__(self) -> str:  # pragma: no cover
        return self.name


class PartCharValue(models.Model):
    """Значения характеристик частей для конкретного оборудования (part_char_values)."""

    part = models.ForeignKey(
        SprPart,
        on_delete=models.PROTECT,
        related_name="char_values",
        verbose_name="Комплектующая",
    )
    char = models.ForeignKey(
        SprChar,
        on_delete=models.PROTECT,
        related_name="part_values",
        verbose_name="Характеристика",
    )
    equipment = models.ForeignKey(
        Equipment,
        on_delete=models.CASCADE,
        related_name="part_char_values",
        verbose_name="Оборудование",
    )
    value_text = models.TextField("Значение", blank=True)

    class Meta:
        verbose_name = "Значение характеристики"
        verbose_name_plural = "Значения характеристик"
        db_table = "part_char_values"
        indexes = [
            models.Index(fields=["equipment"]),
            models.Index(fields=["part"]),
            models.Index(fields=["char"]),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=["equipment", "part", "char"],
                name="uq_part_char_value",
            )
        ]
