from __future__ import annotations

from django import forms


class MultipleFileInput(forms.ClearableFileInput):
    allow_multiple_selected = True

from apps.tasks.models import Task


class TaskForm(forms.ModelForm):
    upload_files = forms.FileField(
        label="Вложения",
        required=False,
        widget=MultipleFileInput(attrs={"multiple": True}),
    )

    class Meta:
        model = Task
        fields = ["description", "status", "executor", "comment"]
        widgets = {
            "description": forms.Textarea(attrs={"class": "form-control", "rows": 4}),
            "status": forms.Select(attrs={"class": "form-select"}),
            "executor": forms.Select(attrs={"class": "form-select"}),
            "comment": forms.Textarea(attrs={"class": "form-control", "rows": 3}),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields["upload_files"].widget.attrs.update({"class": "form-control"})


class TaskFilterForm(forms.Form):
    q = forms.CharField(label="Поиск", required=False)
    status = forms.IntegerField(label="Статус", required=False)
    creator = forms.IntegerField(label="Автор", required=False)
    executor = forms.IntegerField(label="Исполнитель", required=False)
