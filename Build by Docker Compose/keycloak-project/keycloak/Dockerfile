FROM keycloak/keycloak:26.3

# تم‌ها و ریلم‌ها
COPY ./themes /opt/keycloak/themes

# پیکربندی سرور (overrides)
# اگر فایل keycloak.conf را mount می‌کنی، این COPY صرفاً fallback است.
COPY ./conf/keycloak.conf /opt/keycloak/conf/keycloak.conf

# در dev: import realm ها؛ در prod در compose override کن
CMD ["start-dev", "--metrics-enabled=true", "--health-enabled=true"]
