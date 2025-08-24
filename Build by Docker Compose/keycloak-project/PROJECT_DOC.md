# 📁 keycloak-project
> مستندسازی خودکار پروژه (ساختار درختی + محتوای فایل‌های مهم)

## ساختار پروژه

```text
./
├── docgen.sh*
├── docker-compose.yml
├── .env
├── .env.example 
├── keycloak/
│   ├── conf/
│   │   └── keycloak.conf
│   ├── Dockerfile
│   ├── logs/
│   │   ├── keycloak.log
│   │   ├── keycloak.log.1
│   │   ├── keycloak.log.2
│   │   ├── keycloak.log.3
│   │   ├── keycloak.log.4
│   │   └── keycloak.log.5
│   ├── realms/
│   │   └── my-realm.json
│   └── themes/
│       └── my-theme/
├── postgresql/
│   ├── Dockerfile
│   └── init/
│       ├── 00-create-roles.sh*
│       ├── 01-keycloak.sql
│       └── 02-configure-keycloak.sh*
└── PROJECT_DOC.md

8 directories, 18 files
```

## محتوا بر اساس ساختار

## 🧩 docgen.sh

> مسیر: `docgen.sh` | خطوط: `144` | اندازه: `8.0K`

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="."
OUT_FILE="PROJECT_DOC.md"
MAX_LINES=300

# الگوی فایل‌های مهم
pattern=(-iname '*.yml' -o -iname '*.yaml' -o -iname '*.py' -o -iname '*.sh' \
         -o -iname '*.sql' -o -iname '*.json' -o -iname '*.conf' \
         -o -iname '*.env.example' -o -iname '*.enc.example' \
         -o -iname 'dockerfile' -o -iname 'Dockerfile')

# آیکون‌ها
FOLDER_ICON="📁"
FILE_CODE_ICON="🧩"
FILE_CONF_ICON="⚙️"
FILE_LOCK_ICON="🔐"
FILE_DOCKER_ICON="🐳"

# زبان کد برای هایلایت
code_lang() {
  local f="$1"; local l="${f,,}"
  case "$l" in
    *.yml|*.yaml) echo "yaml" ;;
    *.py)         echo "python" ;;
    *.sh)         echo "bash" ;;
    *.sql)        echo "sql" ;;
    *.json)       echo "json" ;;
    *.conf)       echo "properties" ;;
    *.env.example) echo "ini" ;;
    *.enc.example) echo "" ;;
    dockerfile)   echo "dockerfile" ;;
    *)            echo "" ;;
  esac
}

# آیکون فایل بر اساس پسوند
file_icon() {
  local f="$1"; local base="$(basename "$f")"; local l="${base,,}"
  case "$l" in
    *.conf|*.env.example) echo "$FILE_CONF_ICON" ;;
    *.enc.example)        echo "$FILE_LOCK_ICON" ;;
    dockerfile)           echo "$FILE_DOCKER_ICON" ;;
    *)                    echo "$FILE_CODE_ICON" ;;
  esac
}

# ساختار درختی
make_tree_block() {
  echo "## ساختار پروژه"
  echo
  echo '```text'
  if command -v tree >/dev/null 2>&1; then
    tree -a -F -I '.git|__pycache__|.venv|node_modules|dist|build' "$ROOT_DIR"
  else
    # جایگزین ساده
    find "$ROOT_DIR" \
      -path "$ROOT_DIR/.git" -prune -o \
      -path "$ROOT_DIR/__pycache__" -prune -o \
      -path "$ROOT_DIR/.venv" -prune -o \
      -path "$ROOT_DIR/node_modules" -prune -o \
      -path "$ROOT_DIR/dist" -prune -o \
      -path "$ROOT_DIR/build" -prune -o \
      -print \
      | sed "s#^$ROOT_DIR/##"
  fi
  echo '```'
  echo
}

# چاپ هدینگ سلسله‌مراتبی برای مسیر
# base_level=2  (=> سطح اول دایرکتوری: ## ، بعدی: ### ، فایل: ####)
declare -A PRINTED_HDRS
print_headers_for_path() {
  local rel="$1"; local base_level=2
  IFS='/' read -r -a parts <<< "$rel"
  local n=${#parts[@]}
  local path_acc=""
  # دایرکتوری‌ها (به جز نام فایل)
  for ((i=0; i<n-1; i++)); do
    path_acc+="${parts[$i]}"
    if [[ -z "${PRINTED_HDRS[$path_acc]:-}" ]]; then
      local hashes; hashes=$(printf '#%.0s' $(seq 1 $((base_level+i))))
      echo "${hashes} ${FOLDER_ICON} ${parts[$i]}"
      echo
      PRINTED_HDRS[$path_acc]=1
    fi
    path_acc+="/"
  done
  # هدینگ فایل (سطح بعدی)
  local fname="${parts[$((n-1))]}"
  local hashes; hashes=$(printf '#%.0s' $(seq 1 $((base_level+n-1))))
  local icon; icon="$(file_icon "$fname")"
  echo "${hashes} ${icon} ${fname}"
  echo
}

# تولید بخش محتوا بر اساس ساختار
make_content_by_structure() {
  echo "## محتوا بر اساس ساختار"
  echo
  # فهرست فایل‌های هدف
  mapfile -t files < <(find "$ROOT_DIR" -type f \( "${pattern[@]}" \) | sort)
  for f in "${files[@]}"; do
    # مسیر نسبی بدون پیشوند ROOT_DIR/
    local rel="${f#$ROOT_DIR/}"
    local lang; lang="$(code_lang "$rel")"
    # هدینگ‌ها
    print_headers_for_path "$rel"
    # متادیتا و محتوا
    local lines size
    lines="$(wc -l < "$f" 2>/dev/null || echo 0)"
    size="$(du -h "$f" | awk '{print $1}')"
    echo "> مسیر: \`$rel\` | خطوط: \`$lines\` | اندازه: \`$size\`"
    echo
    echo "\`\`\`$lang"
    if [[ "$lines" -le "$MAX_LINES" ]]; then
      cat "$f"
    else
      head -n $((MAX_LINES/2)) "$f"
      echo -e "\n# --- [ محتوا به‌خاطر طولانی بودن خلاصه شد ] ---\n"
      tail -n $((MAX_LINES/2)) "$f"
    fi
    echo '```'
    echo
  done
}

main() {
  : > "$OUT_FILE"
  local title; title="$(basename "$(pwd)")"
  {
    echo "# ${FOLDER_ICON} ${title}"
    echo "> مستندسازی خودکار پروژه (ساختار درختی + محتوای فایل‌های مهم)"
    echo
    make_tree_block
    make_content_by_structure
  } >> "$OUT_FILE"

  echo "✅ مستند تولید شد: $OUT_FILE"
}

main "$@"
```

## 🧩 docker-compose.yml

> مسیر: `docker-compose.yml` | خطوط: `81` | اندازه: `4.0K`

```yaml
services:
  db:
    build: ./postgresql
    image: local/pg-keycloak:16-alpine
    container_name: keycloak_db
    env_file: ./.env
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
      - KC_DB_SCHEMA=${KC_DB_SCHEMA}

    volumes:
      - pg_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $$POSTGRES_USER -d $$POSTGRES_DB"]
      interval: 5s
      timeout: 3s
      retries: 20

  keycloak:
    build: ./keycloak
    image: local/keycloak:26.3.3
    container_name: keycloak
    env_file: ./.env
    environment:
      # --- DB ---
      - KC_DB=${KC_DB}
      - KC_DB_USERNAME=${KC_DB_USERNAME}
      - KC_DB_PASSWORD=${KC_DB_PASSWORD}
      - KC_DB_URL_HOST=${KC_DB_URL_HOST}
      - KC_DB_URL_DATABASE=${KC_DB_URL_DATABASE}
      - KC_DB_SCHEMA=${KC_DB_SCHEMA}

      # --- Admin bootstrap ---
      - KC_BOOTSTRAP_ADMIN_USERNAME=${KC_BOOTSTRAP_ADMIN_USERNAME}
      - KC_BOOTSTRAP_ADMIN_PASSWORD=${KC_BOOTSTRAP_ADMIN_PASSWORD}

      # --- Proxy/Hostname (در صورت نیاز) ---
      - KC_PROXY=${KC_PROXY}

      # --- Logging: فعال‌سازی فایل + JSON (ECS-friendly) ---
      - KC_LOG=file,console
      - KC_LOG_LEVEL=${KC_LOG_LEVEL:-info}
      - KC_LOG_FILE=/opt/keycloak/data/log/keycloak.log
      - KC_LOG_FILE_OUTPUT=json
      - KC_LOG_FILE_JSON_FORMAT=ecs
      # مثال override سطح یک دسته:
      # - KC_LOG_LEVEL_ORG_KEYCLOAK=debug

      # --- Metrics/Event-metrics ---
      - KC_FEATURES=user-event-metrics
      - KC_EVENT_METRICS_USER_ENABLED=true

    # dev: با import realm بالا بیاید
    command: ["start-dev", "--import-realm", "--metrics-enabled=true", "--health-enabled=true"]
    # prod: در پروفایل جدا با "start --optimized" اجرا کن

    ports:
      - "8080:8080"

    depends_on:
      db:
        condition: service_healthy

    volumes:
      # پیکربندی سرور (قابل ویرایش از میزبان)
      - ./keycloak/conf:/opt/keycloak/conf
      # لاگ‌ها روی میزبان ذخیره شود
      - ./keycloak/logs:/opt/keycloak/data/log
      # داده‌ها (import/realms, themes, cache, …)
      
    healthcheck:
      test: ["CMD-SHELL", "curl -fsS http://localhost:8080/health/ready || exit 1"]
      interval: 10s
      timeout: 5s
      retries: 30

volumes:
  pg_data:
  kc_data:
```

## 📁 keycloak

### 📁 conf

#### ⚙️ keycloak.conf

> مسیر: `keycloak/conf/keycloak.conf` | خطوط: `22` | اندازه: `4.0K`

```properties
# سطح کلی لاگ (می‌تواند با KC_LOG_LEVEL override شود)
log-level=info

# فعال‌سازی handler ها (هم فایل هم کنسول)
log=file,console

# مسیر پیش‌فرض فایل لاگ (با mount شده)
log-file=/opt/keycloak/data/log/keycloak.log

# خروجی JSON برای فایل (ECS برای ELK/Elastic APM دوستانه است)
log-file-output=json
log-file-json-format=ecs

# نمونه‌ی دسته‌بندی خاص
# log-level-org.hibernate=debug

# اگر پشت reverse proxy هستی:
# proxy=edge
# hostname=auth.example.com

# در صورت نیاز:
# metrics-enabled=true
```

### 🐳 Dockerfile

> مسیر: `keycloak/Dockerfile` | خطوط: `11` | اندازه: `4.0K`

```
FROM keycloak/keycloak:26.3

# تم‌ها و ریلم‌ها
COPY ./themes /opt/keycloak/themes

# پیکربندی سرور (overrides)
# اگر فایل keycloak.conf را mount می‌کنی، این COPY صرفاً fallback است.
COPY ./conf/keycloak.conf /opt/keycloak/conf/keycloak.conf

# در dev: import realm ها؛ در prod در compose override کن
CMD ["start-dev", "--metrics-enabled=true", "--health-enabled=true"]
```

### 📁 realms

#### 🧩 my-realm.json

> مسیر: `keycloak/realms/my-realm.json` | خطوط: `20` | اندازه: `4.0K`

```json
{
  "realm": "myrealm",
  "enabled": true,
  "users": [
    {
      "username": "demo",
      "enabled": true,
      "emailVerified": true,
      "firstName": "Demo",
      "lastName": "User",
      "credentials": [
        {
          "type": "password",
          "value": "change_me_strong",
          "temporary": false
        }
      ]
    }
  ]
}
```

## 📁 postgresql

### 🐳 Dockerfile

> مسیر: `postgresql/Dockerfile` | خطوط: `7` | اندازه: `4.0K`

```
FROM docker.arvancloud.ir/postgres:13

COPY init/*.sql /docker-entrypoint-initdb.d/
COPY init/*.sh  /docker-entrypoint-initdb.d/

# (اختیاری) اگر می‌خواهی executable باشند:
# RUN chmod +x /docker-entrypoint-initdb.d/*.sh
```

### 📁 init

#### 🧩 00-create-roles.sh

> مسیر: `postgresql/init/00-create-roles.sh` | خطوط: `45` | اندازه: `4.0K`

```bash
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
```

#### 🧩 01-keycloak.sql

> مسیر: `postgresql/init/01-keycloak.sql` | خطوط: `8` | اندازه: `4.0K`

```sql
-- 01-keycloak.sql
-- Idempotent DB extensions + basic hardening

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- جلوگیری از ایجاد آبجکت در public توسط همه
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
```

#### 🧩 02-configure-keycloak.sh

> مسیر: `postgresql/init/02-configure-keycloak.sh` | خطوط: `56` | اندازه: `4.0K`

```bash
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
```

