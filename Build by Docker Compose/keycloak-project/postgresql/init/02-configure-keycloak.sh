#!/usr/bin/env bash
set -Eeuo pipefail

: "${POSTGRES_USER:?POSTGRES_USER is required}"
: "${POSTGRES_DB:?POSTGRES_DB is required}"

KC_DB_SCHEMA="${KC_DB_SCHEMA:-keycloak}"
# کاربری که Keycloak واقعا با آن وصل می‌شود:
APP_DB_USER="${APP_DB_USER:-${KC_DB_USERNAME:-$POSTGRES_USER}}"

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<SQL
-- 1) اسکیمای هدف و مالکیت آن
DO \$\$
BEGIN
  EXECUTE format('CREATE SCHEMA IF NOT EXISTS %I;', '$KC_DB_SCHEMA');
  EXECUTE format('ALTER SCHEMA %I OWNER TO %I;', '$KC_DB_SCHEMA', '$APP_DB_USER');
END
\$\$;

-- 2) گرنت‌های لازم برای کاربر اتصال
DO \$\$
BEGIN
  EXECUTE format('GRANT CONNECT, TEMPORARY ON DATABASE %I TO %I;', '$POSTGRES_DB', '$APP_DB_USER');
  EXECUTE format('GRANT USAGE, CREATE ON SCHEMA %I TO %I;', '$KC_DB_SCHEMA', '$APP_DB_USER');
END
\$\$;

-- 3) search_path برای دیتابیس و نقش
DO \$\$
BEGIN
  EXECUTE format('ALTER DATABASE %I SET search_path TO %I, public;', '$POSTGRES_DB', '$KC_DB_SCHEMA');
  EXECUTE format('ALTER ROLE %I SET search_path TO %I, public;', '$APP_DB_USER', '$KC_DB_SCHEMA');
END
\$\$;

-- 4) Default privileges برای اشیائی که "کاربر اتصال" ایجاد می‌کند
DO \$\$
BEGIN
  EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT ALL ON TABLES    TO %I;',
                 '$APP_DB_USER', '$KC_DB_SCHEMA', '$APP_DB_USER');
  EXECUTE format('ALTER DEFAULT PRIVILEGES FOR ROLE %I IN SCHEMA %I GRANT ALL ON SEQUENCES TO %I;',
                 '$APP_DB_USER', '$KC_DB_SCHEMA', '$APP_DB_USER');
END
\$\$;

-- 5) گزارش تشخیصی: search_path برای نقش اتصال
DO \$\$
DECLARE sp text;
BEGIN
  EXECUTE format('SET ROLE %I;', '$APP_DB_USER');
  SELECT current_setting('search_path', true) INTO sp;
  RAISE NOTICE 'Effective search_path for %: %', '$APP_DB_USER', sp;
  RESET ROLE;
END
\$\$;
SQL
