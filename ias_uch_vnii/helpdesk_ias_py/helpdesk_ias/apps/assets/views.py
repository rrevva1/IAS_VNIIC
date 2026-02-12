from __future__ import annotations

from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.http import HttpResponseForbidden
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_POST

from apps.assets.forms import EquipmentForm, LocationForm
from apps.assets.models import Equipment, Location
from apps.tasks.policies import is_admin


def _check_admin(request):
    if not is_admin(request.user):
        return False
    return True


@login_required
def equipment_list(request):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    equipment = Equipment.objects.select_related("user", "location").order_by("-created_at")
    return render(request, "assets/equipment_list.html", {"equipment": equipment})


@login_required
def equipment_create(request):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    form = EquipmentForm(request.POST or None)
    user_id = request.GET.get("user_id")
    if user_id and not request.POST:
        form.initial["user"] = user_id
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Техника добавлена.")
        return redirect("assets:equipment_list")
    return render(request, "assets/equipment_form.html", {"form": form, "mode": "create"})


@login_required
def equipment_update(request, equipment_id: int):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    equipment = get_object_or_404(Equipment, pk=equipment_id)
    form = EquipmentForm(request.POST or None, instance=equipment)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Техника обновлена.")
        return redirect("assets:equipment_list")
    return render(
        request,
        "assets/equipment_form.html",
        {"form": form, "mode": "update", "equipment": equipment},
    )


@login_required
@require_POST
def equipment_delete(request, equipment_id: int):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    equipment = get_object_or_404(Equipment, pk=equipment_id)
    equipment.delete()
    messages.success(request, "Техника удалена.")
    return redirect("assets:equipment_list")


@login_required
def locations_list(request):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    locations = Location.objects.order_by("name")
    return render(request, "assets/locations_list.html", {"locations": locations})


@login_required
def location_create(request):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    form = LocationForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Локация создана.")
        return redirect("assets:locations_list")
    return render(request, "assets/location_form.html", {"form": form, "mode": "create"})


@login_required
def location_update(request, location_id: int):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    location = get_object_or_404(Location, pk=location_id)
    form = LocationForm(request.POST or None, instance=location)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Локация обновлена.")
        return redirect("assets:locations_list")
    return render(
        request,
        "assets/location_form.html",
        {"form": form, "mode": "update", "location": location},
    )


@login_required
@require_POST
def location_delete(request, location_id: int):
    if not _check_admin(request):
        return HttpResponseForbidden("Недостаточно прав.")
    location = get_object_or_404(Location, pk=location_id)
    location.delete()
    messages.success(request, "Локация удалена.")
    return redirect("assets:locations_list")
