"""
Настройки Django для Python-версии IAS.

Фаза 2 (по плану):
- инициализация проекта и apps-структуры,
- `django-environ` для секретов,
- `django-debug-toolbar` (dev), `django-extensions`,
- логирование в `logs/app.log`, `logs/security.log`, `logs/audit.log`.
"""

from __future__ import annotations

from pathlib import Path

import environ

BASE_DIR = Path(__file__).resolve().parent.parent

# --------------------------------------------------------------------
# ENV
# --------------------------------------------------------------------
env = environ.Env(
    DEBUG=(bool, False),
)

# Подхватываем переменные из .env, если файл существует.
environ.Env.read_env(BASE_DIR / ".env")

# --------------------------------------------------------------------
# SECURITY / BASIC
# --------------------------------------------------------------------
SECRET_KEY = env("DJANGO_SECRET_KEY", default="CHANGE_ME__DJANGO_SECRET_KEY")
DEBUG = env.bool("DEBUG", default=False)
ALLOWED_HOSTS: list[str] = env.list("ALLOWED_HOSTS", default=["127.0.0.1", "localhost"])

# --------------------------------------------------------------------
# APPLICATIONS
# --------------------------------------------------------------------
INSTALLED_APPS = [
    # Django
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",

    # 3rd-party (dev tools)
    "django_extensions",

    # Project apps
    "apps.core",
    "apps.users",
    "apps.tasks",
    "apps.assets",
    "apps.software",
    "apps.reports",
    "apps.procurement",
    "apps.audit",
    "apps.api",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

if DEBUG:
    INSTALLED_APPS.insert(0, "debug_toolbar")
    MIDDLEWARE.insert(0, "debug_toolbar.middleware.DebugToolbarMiddleware")

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

# --------------------------------------------------------------------
# DATABASE
# --------------------------------------------------------------------
# По умолчанию используем DATABASE_URL.
# Пример: postgres://postgres:12345@localhost:5432/ias_vnii
_legacy_db = env("LEGACY_DATABASE_URL", default="").strip()

DATABASES = {
    "default": env.db("DATABASE_URL", default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}"),
}

if _legacy_db:
    # Legacy/source DB (Yii2). Используется ТОЛЬКО для чтения при миграции данных (Фаза 4).
    DATABASES["legacy"] = env.db("LEGACY_DATABASE_URL")

# --------------------------------------------------------------------
# AUTH
# --------------------------------------------------------------------
AUTH_USER_MODEL = "users.User"

AUTHENTICATION_BACKENDS = [
    "django.contrib.auth.backends.ModelBackend",
    "apps.users.auth_backends.LegacyMd5Backend",
]

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LOGIN_URL = "/login/"
LOGIN_REDIRECT_URL = "/"
LOGOUT_REDIRECT_URL = "/login/"

# --------------------------------------------------------------------
# I18N / TZ
# --------------------------------------------------------------------
LANGUAGE_CODE = "ru-ru"
TIME_ZONE = env("TIME_ZONE", default="Europe/Moscow")
USE_I18N = True
USE_TZ = True

# --------------------------------------------------------------------
# STATIC / MEDIA
# --------------------------------------------------------------------
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"
STATICFILES_DIRS = [BASE_DIR / "static"]

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

# --------------------------------------------------------------------
# LOGGING
# --------------------------------------------------------------------
LOG_DIR = BASE_DIR / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "default": {
            "format": "%(asctime)s | %(levelname)s | %(name)s | %(message)s",
        },
    },
    "handlers": {
        "app_file": {
            "class": "logging.FileHandler",
            "filename": str(LOG_DIR / "app.log"),
            "formatter": "default",
        },
        "security_file": {
            "class": "logging.FileHandler",
            "filename": str(LOG_DIR / "security.log"),
            "formatter": "default",
        },
        "audit_file": {
            "class": "logging.FileHandler",
            "filename": str(LOG_DIR / "audit.log"),
            "formatter": "default",
        },
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "default",
        },
    },
    "loggers": {
        # Общий лог приложения
        "": {
            "handlers": ["console", "app_file"],
            "level": env("LOG_LEVEL", default="INFO"),
        },
        # Безопасность (аутентификация, права, suspicious events)
        "security": {
            "handlers": ["security_file", "console"],
            "level": "INFO",
            "propagate": False,
        },
        # Аудит (критичные бизнес-операции)
        "audit": {
            "handlers": ["audit_file", "console"],
            "level": "INFO",
            "propagate": False,
        },
    },
}

# Debug toolbar
INTERNAL_IPS = env.list("INTERNAL_IPS", default=["127.0.0.1"])

# Default primary key field type
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
