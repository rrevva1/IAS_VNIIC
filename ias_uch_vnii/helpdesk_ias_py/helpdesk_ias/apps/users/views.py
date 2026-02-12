from __future__ import annotations

from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.http import HttpResponseForbidden
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_POST

from apps.assets.models import Equipment
from apps.tasks.policies import is_admin
from apps.users.forms import UserCreateForm, UserSelfUpdateForm, UserUpdateForm
from apps.users.models import User


def _admin_required(user):
    return is_admin(user)


@login_required
def user_list(request):
    if not is_admin(request.user):
        return redirect("users:detail", user_id=request.user.id)
    users = User.objects.order_by("full_name")
    return render(request, "users/list.html", {"users": users})


@login_required
def user_detail(request, user_id: int):
    user = get_object_or_404(User, pk=user_id)
    if not is_admin(request.user) and user.id != request.user.id:
        return HttpResponseForbidden("Недостаточно прав.")

    equipment = Equipment.objects.filter(user=user).select_related("location")
    return render(request, "users/detail.html", {"profile": user, "equipment": equipment, "is_admin": is_admin(request.user)})


@login_required
def user_create(request):
    if not is_admin(request.user):
        return HttpResponseForbidden("Недостаточно прав.")

    form = UserCreateForm(request.POST or None)
    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Пользователь создан.")
        return redirect("users:list")

    return render(request, "users/form.html", {"form": form, "mode": "create"})


@login_required
def user_update(request, user_id: int):
    user = get_object_or_404(User, pk=user_id)
    if not is_admin(request.user) and user.id != request.user.id:
        return HttpResponseForbidden("Недостаточно прав.")

    if is_admin(request.user):
        form = UserUpdateForm(request.POST or None, instance=user)
    else:
        form = UserSelfUpdateForm(request.POST or None, instance=user)

    if request.method == "POST" and form.is_valid():
        form.save()
        messages.success(request, "Данные обновлены.")
        return redirect("users:detail", user_id=user.id)

    return render(
        request,
        "users/form.html",
        {"form": form, "mode": "update", "profile": user, "is_admin": is_admin(request.user)},
    )


@login_required
@require_POST
def user_delete(request, user_id: int):
    if not is_admin(request.user):
        return HttpResponseForbidden("Недостаточно прав.")

    user = get_object_or_404(User, pk=user_id)
    user.delete()
    messages.success(request, "Пользователь удалён.")
    return redirect("users:list")


@login_required
def reset_password(request, user_id: int):
    if not is_admin(request.user):
        return HttpResponseForbidden("Недостаточно прав.")

    user = get_object_or_404(User, pk=user_id)
    new_password = "password123"
    user.set_password(new_password)
    user.legacy_password_md5 = ""
    user.save(update_fields=["password", "legacy_password_md5"])
    messages.success(request, f"Пароль сброшен. Новый пароль: {new_password}")
    return redirect("users:detail", user_id=user.id)
