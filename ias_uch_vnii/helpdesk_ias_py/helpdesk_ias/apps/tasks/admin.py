from django.contrib import admin

from apps.tasks.models import Attachment, Task, TaskAttachment, TaskStatus


@admin.register(TaskStatus)
class TaskStatusAdmin(admin.ModelAdmin):
    list_display = ("id", "name")
    search_fields = ("name",)


@admin.register(Attachment)
class AttachmentAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "extension", "created_at")
    search_fields = ("name", "path")
    list_filter = ("extension", "created_at")


class TaskAttachmentInline(admin.TabularInline):
    model = TaskAttachment
    extra = 0
    autocomplete_fields = ("attachment",)


@admin.register(Task)
class TaskAdmin(admin.ModelAdmin):
    list_display = ("id", "status", "creator", "executor", "created_at", "updated_at")
    list_filter = ("status", "created_at", "updated_at")
    search_fields = ("description", "creator__full_name", "executor__full_name")
    autocomplete_fields = ("creator", "executor")
    inlines = (TaskAttachmentInline,)
