from __future__ import annotations

from django.urls import path

from apps.users import views

app_name = "users"

urlpatterns = [
    path("", views.user_list, name="list"),
    path("create/", views.user_create, name="create"),
    path("<int:user_id>/", views.user_detail, name="detail"),
    path("<int:user_id>/edit/", views.user_update, name="update"),
    path("<int:user_id>/delete/", views.user_delete, name="delete"),
    path("<int:user_id>/reset-password/", views.reset_password, name="reset_password"),
]

