from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import AuthenticationForm
from django.shortcuts import redirect, render

from apps.tasks.policies import is_admin


def login_view(request):
    if request.user.is_authenticated:
        return redirect("core:home")

    form = AuthenticationForm(request, data=request.POST or None)
    form.fields["username"].label = "Email"
    form.fields["username"].widget.attrs.update({"class": "form-control", "placeholder": "name@example.com"})
    form.fields["password"].widget.attrs.update({"class": "form-control"})
    if request.method == "POST" and form.is_valid():
        login(request, form.get_user())
        next_url = request.GET.get("next") or "core:home"
        return redirect(next_url)

    return render(request, "core/login.html", {"form": form})


@login_required
def logout_view(request):
    logout(request)
    return redirect("core:login")


@login_required
def home(request):
    if is_admin(request.user):
        return redirect("tasks:list")
    return redirect("tasks:list")
