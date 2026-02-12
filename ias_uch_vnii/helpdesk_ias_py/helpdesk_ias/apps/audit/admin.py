from django.contrib import admin

from apps.audit.models import AuditEvent


@admin.register(AuditEvent)
class AuditEventAdmin(admin.ModelAdmin):
    list_display = ("id", "created_at", "actor", "action", "object_type", "object_id", "ip")
    list_filter = ("action", "created_at")
    search_fields = ("action", "object_type", "object_id", "request_id", "user_agent")
    autocomplete_fields = ("actor",)
