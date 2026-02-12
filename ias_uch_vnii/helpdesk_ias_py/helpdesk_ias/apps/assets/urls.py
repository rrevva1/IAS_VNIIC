from __future__ import annotations

from django.urls import path

from apps.assets import views

app_name = "assets"

urlpatterns = [
    path("equipment/", views.equipment_list, name="equipment_list"),
    path("equipment/create/", views.equipment_create, name="equipment_create"),
    path("equipment/<int:equipment_id>/edit/", views.equipment_update, name="equipment_update"),
    path("equipment/<int:equipment_id>/delete/", views.equipment_delete, name="equipment_delete"),
    path("locations/", views.locations_list, name="locations_list"),
    path("locations/create/", views.location_create, name="location_create"),
    path("locations/<int:location_id>/edit/", views.location_update, name="location_update"),
    path("locations/<int:location_id>/delete/", views.location_delete, name="location_delete"),
]

