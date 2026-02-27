"""Конфигурация из переменных окружения."""
import os


def get_settings():
    return type("Settings", (), {
        "db_host": os.getenv("DB_HOST", "localhost"),
        "db_port": int(os.getenv("DB_PORT", "5432")),
        "db_name": os.getenv("DB_NAME", "ias_vniic"),
        "db_user": os.getenv("DB_USER", "postgres"),
        "db_password": os.getenv("DB_PASSWORD", "12345"),
        "db_schema": os.getenv("DB_SCHEMA", "tech_accounting"),
    })()
