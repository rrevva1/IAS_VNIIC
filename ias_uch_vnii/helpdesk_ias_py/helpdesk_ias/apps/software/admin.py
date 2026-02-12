from django.contrib import admin

from apps.software.models import License, Software, SoftwareInstall


@admin.register(Software)
class SoftwareAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "vendor")
    search_fields = ("name", "vendor")


@admin.register(License)
class LicenseAdmin(admin.ModelAdmin):
    list_display = ("id", "software", "key", "valid_from", "valid_to", "seats")
    search_fields = ("software__name", "key")
    list_filter = ("valid_to",)
    autocomplete_fields = ("software",)


@admin.register(SoftwareInstall)
class SoftwareInstallAdmin(admin.ModelAdmin):
    list_display = ("id", "software", "equipment_id", "installed_by", "installed_at")
    search_fields = ("software__name", "equipment_id")
    list_filter = ("installed_at",)
    autocomplete_fields = ("software", "installed_by", "license")
