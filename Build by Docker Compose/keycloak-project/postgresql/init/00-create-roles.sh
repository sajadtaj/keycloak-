#!/usr/bin/env bash
set -Eeuo pipefail

# این اسکریپت با کاربر سوپر (POSTGRES_USER) روی دیتابیس POSTGRES_DB اجرا می‌شود.
: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"

# اگر APP_DB_USER تعریف نشده باشد، از KC_DB_USERNAME و در نهایت از POSTGRES_USER استفاده کن
APP_DB_USER="${APP_DB_USER:-${KC_DB_USERNAME:-$POSTGRES_USER}}"
APP_DB_PASSWORD="${APP_DB_PASSWORD:-${KC_DB_PASSWORD:-}}"
APP_DB_CONN_LIMIT="${APP_DB_CONN_LIMIT:-50}"

# اگر قرار نیست کاربر جدا بسازیم (APP_DB_USER == POSTGRES_USER)، از ساخت نقش عبور کن
if [[ "$APP_DB_USER" != "$POSTGRES_USER" ]]; then
  if [[ -z "$APP_DB_PASSWORD" ]]; then
    echo "ERROR: APP_DB_PASSWORD not set for APP_DB_USER=$APP_DB_USER" >&2
    exit 1
  fi

  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = ${pg_quote_literal:-quote_literal}('$APP_DB_USER')) THEN
    EXECUTE format(
      'CREATE ROLE %I LOGIN PASSWORD %L NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT CONNECTION LIMIT %s',
      '$APP_DB_USER', '$APP_DB_PASSWORD', '$APP_DB_CONN_LIMIT'
    );
  END IF;
END
\$\$;
SQL
fi

# سوپریوزر نگه‌دار (اختیاری؛ فقط اگر هر دو مقدار داده شده‌اند)
if [[ -n "${MAINT_SUPERUSER:-}" && -n "${MAINT_SUPERPASS:-}" ]]; then
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
DO \$\$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = ${pg_quote_literal:-quote_literal}('$MAINT_SUPERUSER')) THEN
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L SUPERUSER INHERIT', '$MAINT_SUPERUSER', '$MAINT_SUPERPASS');
  END IF;
END
\$\$;
SQL
fi
