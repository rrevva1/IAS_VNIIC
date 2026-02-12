from __future__ import annotations

import csv
import mimetypes
from pathlib import Path

from django.conf import settings
from django.contrib import messages
from django.contrib.auth.decorators import login_required
from django.db.models import Count, Q
from django.http import FileResponse, Http404, HttpResponse, HttpResponseForbidden, JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone
from django.views.decorators.http import require_POST

from apps.tasks.forms import TaskFilterForm, TaskForm
from apps.tasks.models import Attachment, Task, TaskAttachment, TaskStatus
from apps.users.models import User
from apps.tasks.policies import TaskPolicy, is_admin
from apps.tasks.services import delete_attachment, save_attachments


def _get_attachment_file(att: Attachment) -> Path:
    rel = (att.path or "").lstrip("/").strip()
    if not rel:
        raise Http404("Путь к файлу не указан.")
    return Path(settings.MEDIA_ROOT) / rel


@login_required
def task_list(request):
    qs = (
        Task.objects.select_related("status", "creator", "executor")
        .prefetch_related("attachments")
        .order_by("-created_at")
    )
    if not is_admin(request.user):
        qs = qs.filter(Q(creator=request.user) | Q(executor=request.user))

    form = TaskFilterForm(request.GET)
    if form.is_valid():
        q = form.cleaned_data.get("q")
        status = form.cleaned_data.get("status")
        creator = form.cleaned_data.get("creator")
        executor = form.cleaned_data.get("executor")
        if q:
            qs = qs.filter(description__icontains=q)
        if status:
            qs = qs.filter(status_id=status)
        if creator:
            qs = qs.filter(creator_id=creator)
        if executor:
            qs = qs.filter(executor_id=executor)

    statuses = TaskStatus.objects.all().order_by("id")
    creators = (
        Task.objects.select_related("creator")
        .values("creator_id", "creator__full_name")
        .distinct()
        .order_by("creator__full_name")
    )
    executors = (
        Task.objects.select_related("executor")
        .values("executor_id", "executor__full_name")
        .distinct()
        .order_by("executor__full_name")
    )

    return render(
        request,
        "tasks/list.html",
        {
            "tasks": qs,
            "statuses": statuses,
            "creators": creators,
            "executors": executors,
            "is_admin": is_admin(request.user),
        },
    )


@login_required
def task_aggrid(request):
    return render(request, "tasks/aggrid.html", {"is_admin": is_admin(request.user)})


@login_required
def task_detail(request, task_id: int):
    task = get_object_or_404(Task.objects.select_related("status", "creator", "executor"), pk=task_id)
    if not TaskPolicy.can_view(request.user, task):
        return HttpResponseForbidden("Недостаточно прав.")

    admin = is_admin(request.user)
    statuses = TaskStatus.objects.all().order_by("id") if admin else []
    executors = User.objects.order_by("full_name") if admin else []

    return render(
        request,
        "tasks/detail.html",
        {
            "task": task,
            "is_admin": admin,
            "can_edit": TaskPolicy.can_edit(request.user, task),
            "can_change_status": TaskPolicy.can_change_status(request.user, task),
            "can_assign_executor": TaskPolicy.can_assign_executor(request.user, task),
            "statuses": statuses,
            "executors": executors,
        },
    )


@login_required
def task_create(request):
    form = TaskForm(request.POST or None, request.FILES or None)
    admin = is_admin(request.user)
    if not admin:
        form.fields["status"].disabled = True
        form.fields["executor"].disabled = True

    if request.method == "POST" and form.is_valid():
        task = form.save(commit=False)
        task.creator = request.user
        if not task.status_id:
            task.status = TaskStatus.objects.order_by("id").first()
        task.updated_at = timezone.now()
        task.save()

        try:
            save_attachments(task, request.FILES.getlist("upload_files"))
        except Exception as exc:
            messages.error(request, str(exc))
        else:
            messages.success(request, "Заявка создана.")
            return redirect("tasks:detail", task_id=task.id)

    return render(request, "tasks/form.html", {"form": form, "is_admin": admin, "mode": "create"})


@login_required
def task_update(request, task_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_edit(request.user, task):
        return HttpResponseForbidden("Недостаточно прав.")

    form = TaskForm(request.POST or None, request.FILES or None, instance=task)
    admin = is_admin(request.user)
    if not admin:
        form.fields["status"].disabled = True
        form.fields["executor"].disabled = True

    if request.method == "POST" and form.is_valid():
        task = form.save(commit=False)
        task.updated_at = timezone.now()
        task.save()

        try:
            save_attachments(task, request.FILES.getlist("upload_files"))
        except Exception as exc:
            messages.error(request, str(exc))
        else:
            messages.success(request, "Заявка обновлена.")
            return redirect("tasks:detail", task_id=task.id)

    return render(request, "tasks/form.html", {"form": form, "is_admin": admin, "mode": "update", "task": task})


@login_required
@require_POST
def task_delete(request, task_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_edit(request.user, task):
        return HttpResponseForbidden("Недостаточно прав.")

    for link in TaskAttachment.objects.filter(task=task).select_related("attachment"):
        delete_attachment(link.attachment)
    task.delete()
    messages.success(request, "Заявка удалена.")
    return redirect("tasks:list")


@login_required
@require_POST
def change_status(request, task_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_change_status(request.user, task):
        return JsonResponse({"success": False, "message": "Недостаточно прав."}, status=403)

    status_id = request.POST.get("status_id")
    status = get_object_or_404(TaskStatus, pk=status_id)
    task.status = status
    task.updated_at = timezone.now()
    task.save(update_fields=["status", "updated_at"])
    return JsonResponse({"success": True, "status": status.name})


@login_required
@require_POST
def assign_executor(request, task_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_assign_executor(request.user, task):
        return JsonResponse({"success": False, "message": "Недостаточно прав."}, status=403)

    executor_id = request.POST.get("executor_id") or None
    task.executor_id = executor_id
    task.updated_at = timezone.now()
    task.save(update_fields=["executor", "updated_at"])
    return JsonResponse({"success": True})


@login_required
@require_POST
def update_comment(request, task_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_edit(request.user, task):
        return JsonResponse({"success": False, "message": "Недостаточно прав."}, status=403)

    task.comment = request.POST.get("comment", "")
    task.updated_at = timezone.now()
    task.save(update_fields=["comment", "updated_at"])
    return JsonResponse({"success": True})


@login_required
def task_grid_data(request):
    qs = Task.objects.select_related("status", "creator", "executor").order_by("-created_at")
    if not is_admin(request.user):
        qs = qs.filter(Q(creator=request.user) | Q(executor=request.user))

    data = []
    for task in qs:
        data.append(
            {
                "id": task.id,
                "description": task.description,
                "status": task.status.name if task.status else "",
                "creator": task.creator.full_name if task.creator else "",
                "executor": task.executor.full_name if task.executor else "",
                "created_at": task.created_at.strftime("%d.%m.%Y %H:%M"),
                "updated_at": task.updated_at.strftime("%d.%m.%Y %H:%M"),
                "attachments": task.attachments.count(),
                "detail_url": f"/tasks/{task.id}/",
            }
        )
    return JsonResponse({"rows": data})


@login_required
def task_stats(request):
    by_status = (
        Task.objects.values("status__name")
        .annotate(total=Count("id"))
        .order_by("status__name")
    )
    by_executor = (
        Task.objects.values("executor__full_name")
        .annotate(total=Count("id"))
        .order_by("executor__full_name")
    )
    return render(
        request,
        "tasks/stats.html",
        {"by_status": by_status, "by_executor": by_executor},
    )


@login_required
def export_csv(request):
    qs = Task.objects.select_related("status", "creator", "executor").order_by("-created_at")
    if not is_admin(request.user):
        qs = qs.filter(Q(creator=request.user) | Q(executor=request.user))

    response = HttpResponse(content_type="text/csv")
    response["Content-Disposition"] = 'attachment; filename="tasks.csv"'
    writer = csv.writer(response)
    writer.writerow(["ID", "Статус", "Описание", "Автор", "Исполнитель", "Создана", "Обновлена"])
    for task in qs:
        writer.writerow(
            [
                task.id,
                task.status.name if task.status else "",
                task.description,
                task.creator.full_name if task.creator else "",
                task.executor.full_name if task.executor else "",
                task.created_at.strftime("%d.%m.%Y %H:%M"),
                task.updated_at.strftime("%d.%m.%Y %H:%M"),
            ]
        )
    return response


@login_required
def export_excel(request):
    from openpyxl import Workbook

    qs = Task.objects.select_related("status", "creator", "executor").order_by("-created_at")
    if not is_admin(request.user):
        qs = qs.filter(Q(creator=request.user) | Q(executor=request.user))

    wb = Workbook()
    ws = wb.active
    ws.title = "Заявки"
    ws.append(["ID", "Статус", "Описание", "Автор", "Исполнитель", "Создана", "Обновлена"])
    for task in qs:
        ws.append(
            [
                task.id,
                task.status.name if task.status else "",
                task.description,
                task.creator.full_name if task.creator else "",
                task.executor.full_name if task.executor else "",
                task.created_at.strftime("%d.%m.%Y %H:%M"),
                task.updated_at.strftime("%d.%m.%Y %H:%M"),
            ]
        )

    response = HttpResponse(
        content_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )
    response["Content-Disposition"] = 'attachment; filename="tasks.xlsx"'
    wb.save(response)
    return response


@login_required
def download_attachment(request, task_id: int, attachment_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_view(request.user, task):
        return HttpResponseForbidden("Недостаточно прав.")

    if not TaskAttachment.objects.filter(task_id=task_id, attachment_id=attachment_id).exists():
        return HttpResponseForbidden("Вложение не принадлежит задаче.")

    att = get_object_or_404(Attachment, pk=attachment_id)
    file_path = _get_attachment_file(att)
    if not file_path.exists():
        raise Http404("Файл не найден.")

    resp = FileResponse(open(file_path, "rb"), as_attachment=True, filename=att.name)
    resp["X-Content-Type-Options"] = "nosniff"
    return resp


@login_required
def preview_attachment(request, task_id: int, attachment_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_view(request.user, task):
        return HttpResponseForbidden("Недостаточно прав.")

    if not TaskAttachment.objects.filter(task_id=task_id, attachment_id=attachment_id).exists():
        return HttpResponseForbidden("Вложение не принадлежит задаче.")

    att = get_object_or_404(Attachment, pk=attachment_id)
    safe_ext = {"pdf", "png", "jpg", "jpeg", "gif", "bmp"}
    ext = (att.extension or Path(att.name).suffix.lstrip(".")).lower()
    if ext not in safe_ext:
        raise Http404("Предпросмотр недоступен для данного типа файла.")

    file_path = _get_attachment_file(att)
    if not file_path.exists():
        raise Http404("Файл не найден.")

    content_type, _ = mimetypes.guess_type(att.name)
    resp = FileResponse(open(file_path, "rb"), as_attachment=False, filename=att.name, content_type=content_type)
    resp["Content-Disposition"] = f'inline; filename=\"{att.name}\"'
    resp["X-Content-Type-Options"] = "nosniff"
    return resp


@login_required
@require_POST
def delete_attachment_view(request, task_id: int, attachment_id: int):
    task = get_object_or_404(Task, pk=task_id)
    if not TaskPolicy.can_manage_attachments(request.user, task):
        return HttpResponseForbidden("Недостаточно прав.")

    if not TaskAttachment.objects.filter(task_id=task_id, attachment_id=attachment_id).exists():
        return HttpResponseForbidden("Вложение не принадлежит задаче.")

    att = get_object_or_404(Attachment, pk=attachment_id)
    delete_attachment(att)
    messages.success(request, "Вложение удалено.")
    return redirect("tasks:detail", task_id=task_id)
