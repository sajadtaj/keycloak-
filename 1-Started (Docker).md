
<div dir='rtl'>

# Docker
## شروع کار (Getting Started)

شروع به کار با Keycloak روی یک سرور فیزیکی یا مجازی.

---

### قبل از شروع

* [مطمئن شوید ماشین یا پلتفرم کانتینر شما حافظه (Memory) و پردازنده (CPU) کافی برای استفاده موردنظرتان از Keycloak دارد.](https://www.keycloak.org/high-availability/concepts-memory-and-cpu-sizing)
* مطمئن شوید Docker روی سیستم شما نصب شده است.


---

### دانلود Keycloak

* [فایل **keycloak-26.3.3.zip** را از وب‌سایت Keycloak دانلود و استخراج کنید.](https://github.com/keycloak/keycloak/releases/download/26.3.3/keycloak-26.3.3.zip)
* بعد از استخراج، باید پوشه‌ای به نام **keycloak-26.3.3** داشته باشید.

---

### اجرای Keycloak

از ترمینال، دستور زیر را برای اجرای Keycloak وارد کنید:

```bash
docker run -p 127.0.0.1:8080:8080 \
-e KC_BOOTSTRAP_ADMIN_USERNAME=admin \
-e KC_BOOTSTRAP_ADMIN_PASSWORD=admin \
quay.io/keycloak/keycloak:26.3.3 start-dev
```

این دستور Keycloak را روی پورت محلی **8080** اجرا می‌کند و یک کاربر ادمین اولیه با نام کاربری `admin` و رمز عبور `admin` می‌سازد.

---

### ورود به کنسول مدیریتی (Admin Console)

1. به **Keycloak Admin Console** بروید.
2. با نام کاربری و رمز عبوری که ایجاد کردید (admin/admin) وارد شوید.

---

### ایجاد یک Realm

* یک **Realm** در Keycloak معادل یک **Tenant** است.
* هر Realm اجازه می‌دهد مدیر سیستم گروه‌های جداگانه‌ای از کاربران و اپلیکیشن‌ها را مدیریت کند.
* در ابتدا Keycloak یک Realm به نام **master** دارد.
  * از این Realm فقط برای مدیریت Keycloak استفاده کنید، نه برای اپلیکیشن‌ها.

مراحل ایجاد اولین Realm:

1. وارد Admin Console شوید.
2. کنار "Current realm" روی **Create Realm** کلیک کنید.
3. در قسمت **Realm name** مقدار `myrealm` را وارد کنید.
4. روی **Create** کلیک کنید.

---

### ایجاد یک کاربر (User)

* در ابتدا Realm جدید هیچ کاربری ندارد.

مراحل ایجاد کاربر:

1. مطمئن شوید در Realm `myrealm` هستید.
2. از منوی سمت چپ روی **Users** کلیک کنید.
3. روی **Create new user** کلیک کنید.
4. فرم را با مقادیر زیر پر کنید:
   * Username: `myuser`
   * First name: هر نام دلخواه
   * Last name: هر نام دلخواه
5. روی **Create** کلیک کنید.

#### تنظیم رمز عبور برای کاربر:

1. در بالای صفحه روی **Credentials** کلیک کنید.
2. فرم **Set password** را با یک رمز عبور پر کنید.
3. گزینه **Temporary** را روی **Off** قرار دهید تا کاربر مجبور نباشد در اولین ورود رمز را تغییر دهد.

---

### ورود به Account Console

اکنون می‌توانید وارد **Keycloak Account Console** شوید تا بررسی کنید کاربر درست تنظیم شده است.

1. وارد Account Console شوید.
2. با `myuser` و رمزی که ساختید لاگین کنید.

به عنوان یک کاربر در Account Console می‌توانید:

* پروفایل خود را تغییر دهید.
* احراز هویت دومرحله‌ای (2FA) اضافه کنید.
* حساب‌های Identity Provider (مثل Google یا GitHub) متصل کنید.

---

### ایمن کردن اولین اپلیکیشن

برای ایمن‌سازی اولین اپلیکیشن، باید اپلیکیشن را در Keycloak ثبت کنید:

1. وارد Admin Console شوید.
2. مطمئن شوید در Realm `myrealm` هستید.
3. روی **Clients** کلیک کنید.
4. روی **Create client** کلیک کنید.
5. فرم را با مقادیر زیر پر کنید:
   * Client type: `OpenID Connect`
   * Client ID: `myclient`

سپس:

* روی **Next** کلیک کنید.
* مطمئن شوید **Standard flow** فعال است.
* دوباره روی **Next** کلیک کنید.
* در بخش **Login settings** تغییرات زیر را اعمال کنید:
  * **Valid redirect URIs** → `https://www.keycloak.org/app/*`
  * **Web origins** → `https://www.keycloak.org`
* روی **Save** کلیک کنید.

#### تست کلاینت:

* وارد آدرس [https://www.keycloak.org/app/](https://www.keycloak.org/app/) شوید.
* روی **Save** کلیک کنید تا تنظیمات پیش‌فرض اعمال شوند.
* روی **Sign in** کلیک کنید تا با سرور Keycloak خود احراز هویت کنید.

---

### گام‌های بعدی (برای محیط Production)

قبل از اجرای Keycloak در محیط عملیاتی (Production)، موارد زیر را در نظر بگیرید:

* استفاده از دیتابیس آماده تولید (Production Ready) مثل  **PostgreSQL** .
* پیکربندی SSL با گواهی‌های اختصاصی.
* تغییر رمز عبور ادمین به یک رمز قوی‌تر.

برای اطلاعات بیشتر به [**Server Guides**](https://www.keycloak.org/guides#server) مراجعه کنید.

