from __future__ import annotations

from django.urls import path

from apps.tasks import views

app_name = "tasks"

urlpatterns = [
    path("", views.task_list, name="list"),
    path("ag-grid/", views.task_aggrid, name="aggrid"),
    path("stats/", views.task_stats, name="stats"),
    path("export/csv/", views.export_csv, name="export_csv"),
    path("export/xlsx/", views.export_excel, name="export_excel"),
    path("api/grid/", views.task_grid_data, name="grid_data"),
    path("create/", views.task_create, name="create"),
    path("<int:task_id>/", views.task_detail, name="detail"),
    path("<int:task_id>/edit/", views.task_update, name="update"),
    path("<int:task_id>/delete/", views.task_delete, name="delete"),
    path("<int:task_id>/change-status/", views.change_status, name="change_status"),
    path("<int:task_id>/assign-executor/", views.assign_executor, name="assign_executor"),
    path("<int:task_id>/update-comment/", views.update_comment, name="update_comment"),
    path(
        "<int:task_id>/attachments/<int:attachment_id>/download/",
        views.download_attachment,
        name="attachment_download",
    ),
    path(
        "<int:task_id>/attachments/<int:attachment_id>/preview/",
        views.preview_attachment,
        name="attachment_preview",
    ),
    path(
        "<int:task_id>/attachments/<int:attachment_id>/delete/",
        views.delete_attachment_view,
        name="attachment_delete",
    ),
]

