Развёртывание на Ubuntu
=======================

Один шаг (из корня репозитория IAS_VNIIC):

  sudo bash deploy/ubuntu-setup.sh

Переменные окружения (опционально, перед sudo):

  IAS_REPO_ROOT   — корень репозитория (по умолчанию: родитель deploy/)
  IAS_SQL_DUMP    — путь к .sql дампу (по умолчанию: db/tech.sql)
  DB_NAME         — имя БД (по умолчанию: ias_vniic)
  DB_USER         — пользователь PostgreSQL (по умолчанию: ias_vniic)
  DB_PASSWORD     — пароль пользователя БД

Пример другого дампа:

  IAS_SQL_DUMP=/home/user/IAS_VNIIC/db/ias_vniic_14_02_26.sql sudo -E bash deploy/ubuntu-setup.sh

После установки учётные записи приложения — как в docs/guides/РАЗВЕРТЫВАНИЕ_WINDOWS.md (admin / admin123 и т.д.), пароли сменить.

Скрипт при отсутствии каталога web/ag-grid-community ставит пакет ag-grid-community@32.3.3 через npm (нужен для таблиц/статистики).

---

Apache + PostgreSQL (сервер с уже установленным apache2, кластер PG на порту 5433):

  cd /home/revvarr/IAS_VNIIC   # или ваш путь к репозиторию
  sudo bash deploy/setup-ias-vniic-db-and-apache.sh

Скрипт выставляет пароль postgres в 12345, пересоздаёт БД ias_vniic и заливает дамп (по умолчанию db/tech.sql).
В виртуальном хосте задаётся SetEnv (DB_PORT=5433, DB_PASSWORD=12345), чтобы PHP под Apache подключался к нужному кластеру.

Переменные: IAS_SQL_DUMP, IAS_REPO_ROOT, APP_ROOT (по умолчанию /var/www/html/ias_uch_vnii), PGPORT (по умолчанию 5433).

Если по http://IP/ видна «Apache2 Ubuntu Default Page» — включён sites-enabled/000-default; скрипт его отключает. Вручную: sudo a2dissite 000-default.conf && sudo systemctl reload apache2

Ошибка Yii «could not find driver» при входе — нет расширения pdo_pgsql: sudo apt install -y php-pgsql && sudo systemctl restart apache2
