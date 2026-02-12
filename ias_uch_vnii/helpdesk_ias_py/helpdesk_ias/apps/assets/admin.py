from django.contrib import admin

from apps.assets.models import (
    Equipment,
    EquipHistory,
    Location,
    PartCharValue,
    SprChar,
    SprPart,
)


@admin.register(Location)
class LocationAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "location_type", "floor")
    search_fields = ("name",)
    list_filter = ("location_type", "floor")


@admin.register(Equipment)
class EquipmentAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "user", "location", "created_at")
    search_fields = ("name", "user__full_name")
    list_filter = ("location", "created_at")
    autocomplete_fields = ("user", "location")


@admin.register(EquipHistory)
class EquipHistoryAdmin(admin.ModelAdmin):
    list_display = ("id", "equipment", "changed_by", "change_type", "change_date")
    search_fields = ("equipment__name", "changed_by__full_name", "change_type")
    list_filter = ("change_type", "change_date")
    autocomplete_fields = ("equipment", "changed_by")


@admin.register(SprPart)
class SprPartAdmin(admin.ModelAdmin):
    list_display = ("id", "name")
    search_fields = ("name",)


@admin.register(SprChar)
class SprCharAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "measurement_unit")
    search_fields = ("name",)


@admin.register(PartCharValue)
class PartCharValueAdmin(admin.ModelAdmin):
    list_display = ("id", "equipment", "part", "char")
    search_fields = ("equipment__name", "part__name", "char__name")
    autocomplete_fields = ("equipment", "part", "char")
