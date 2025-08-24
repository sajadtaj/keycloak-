<div dir="rtl">

# ساختار دایرکتوری (Directory Structure)

## محل‌های نصب (Installation Locations)

اگر از یک فایل zip نصب کنید، به‌طور پیش‌فرض یک دایرکتوری نصب ریشه با نام `keycloak-26.3.3` خواهید داشت که می‌توانید آن را در هر جایی از فایل‌سیستم خود ایجاد کنید.

`/opt/keycloak` مکان نصب ریشه برای سرور در تمامی استفاده‌های کانتینری Keycloak است، شامل Running Keycloak in a container، Docker، Podman، Kubernetes و OpenShift.

در ادامه‌ی مستندات، مسیرهای نسبی به ریشه نصب در نظر گرفته می‌شوند – برای مثال `conf/file.xml` به معنی `<install root>/conf/file.xml` است.

---

## ساختار دایرکتوری (Directory Structure)

</div>

```bash
<install root>/        (مثال: /opt/keycloak یا keycloak-26.3.3)
├── bin/               # شامل اسکریپت‌های اجرایی مثل kc.sh, kcadm.sh, kcreg.sh
├── client/            # استفاده داخلی
├── conf/              # فایل‌های پیکربندی (keycloak.conf و ...)
├── truststores/       # مسیر پیش‌فرض برای truststore-paths
├── data/              # اطلاعات زمان اجرا (runtime) مثل transaction logs
├── logs/              # مسیر پیش‌فرض ذخیره‌سازی فایل‌های log
├── lib/               # استفاده داخلی
├── providers/         # وابستگی‌های ارائه‌شده توسط کاربر (مثل JDBC driver)
└── themes/            # سفارشی‌سازی Admin Console (theme ها)
```

<div dir="rtl">


زیر دایرکتوری نصب Keycloak پوشه‌های زیر وجود دارد:

* **bin/**
  شامل تمام اسکریپت‌های shell برای سرور است، از جمله `kc.sh|bat`، `kcadm.sh|bat` و `kcreg.sh|bat`.

* **client/**
  برای استفاده‌ی داخلی است.

* **conf/**
  پوشه‌ی مورد استفاده برای فایل‌های پیکربندی، از جمله `keycloak.conf`.
  نگاه کنید به بخش *Configuring Keycloak*. بسیاری از گزینه‌هایی که برای مشخص کردن فایل پیکربندی استفاده می‌شوند، مسیرهای نسبی به این پوشه را انتظار دارند.

* **truststores/**
  مسیر پیش‌فرضی است که توسط گزینه‌ی `truststore-paths` استفاده می‌شود.
  نگاه کنید به بخش *Configuring trusted certificates*.

* **data/**
  پوشه‌ای برای ذخیره‌سازی اطلاعات زمان اجرا (runtime) سرور، مانند transaction logs.

* **logs/**
  پوشه‌ی پیش‌فرض برای ذخیره‌سازی log فایل‌ها.
  نگاه کنید به بخش *Configuring logging*.

* **lib/**
  برای استفاده‌ی داخلی است.

* **providers/**
  پوشه‌ای برای وابستگی‌هایی که توسط کاربر فراهم می‌شوند.
  نگاه کنید به بخش *Configuring providers* برای گسترش سرور و *Configuring the database* به‌عنوان مثالی از اضافه کردن یک JDBC driver.

* **themes/**
  پوشه‌ای برای سفارشی‌سازی Admin Console.
  نگاه کنید به بخش *Developing Themes*.

---

می‌خواهی همین سبک را برای کل مستند Keycloak (همه‌ی بخش‌ها مثل Configuring، Logging، Providers، Themes و …) ادامه بدهم تا یک ترجمه کامل و یکپارچه فارسی آماده شود؟
