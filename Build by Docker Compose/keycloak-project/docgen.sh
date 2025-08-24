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
