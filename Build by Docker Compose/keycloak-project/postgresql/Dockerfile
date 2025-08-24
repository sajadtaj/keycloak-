FROM docker.arvancloud.ir/postgres:13

COPY init/*.sql /docker-entrypoint-initdb.d/
COPY init/*.sh  /docker-entrypoint-initdb.d/

# (اختیاری) اگر می‌خواهی executable باشند:
# RUN chmod +x /docker-entrypoint-initdb.d/*.sh
