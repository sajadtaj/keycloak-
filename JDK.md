

## 🎯 بخش ۱: وضعیت نصب OpenJDK

### ✅ JDK های شناسایی شده در سیستم:

| نسخه | مسیر نصب | وضعیت |
| :--- | :--- | :--- |
| **OpenJDK 21** | `/usr/lib/jvm/java-1.21.0-openjdk-amd64` | ✅ نصب شده |
| **OpenJDK 17** | `/usr/lib/jvm/java-1.17.0-openjdk-amd64` | ✅ نصب شده (پیش‌فرض) |
| **OpenJDK 11** | `/usr/lib/jvm/java-1.11.0-openjdk-amd64` | ✅ نصب شده |

### 🔍 دستورات تأیید نصب:

### بررسی اینکه قبلا ایا نصب شده است

```bash
# بررسی نسخه پیش‌فرض
java -version
javac -version

# لیست تمام JDK های نصب شده
update-java-alternatives --list
ls /usr/lib/jvm/
```

---

## ⚙️ بخش ۲: پیکربندی و تغییر نسخه پیش‌فرض

### 🔄 روش‌های تغییر به نسخه دیگر اگر چند نسحه نصب است:

#### روش ۱: تغییر سیستم‌عامل (دائمی)
```bash

# Example : java-1.21.0-openjdk-amd64
sudo update-java-alternatives --set java-1.21.0-openjdk-amd64
```

#### روش ۲: انتخاب تعاملی
```bash
sudo update-alternatives --config java
# سپس عدد مربوط به JDK 21 را انتخاب کنید
```

#### روش ۳: تغییر موقت (فصل جاری ترمینال)
```bash
export JAVA_HOME=/usr/lib/jvm/java-1.21.0-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
```

### 📝 نمونه خروجی مورد انتظار پس از تغییر:

```bash
$ java -version
openjdk version "21.0.1" 2023-10-17
OpenJDK Runtime Environment (build 21.0.1+12-29)
OpenJDK 64-Bit Server VM (build 21.0.1+12-29, mixed mode, sharing)
```

---

## 🚀 بخش ۳: دستورات مفید مدیریت JDK

### 🔍 بررسی وضعیت فعلی:
```bash
# نمایش مسیر JAVA_HOME
echo $JAVA_HOME

# نمایش مسیر کامل اجرایی java
which java
readlink -f $(which java)

# بررسی نسخه دقیق
java -XshowSettings:properties -version 2>&1 | grep 'java.version'
```

### 🔧 مدیریت چند نسخه‌ای:
```bash
# مشاهده لیست کامل آلترناتیوها
update-alternatives --list java
update-alternatives --list javac

# بررسی وضعیت فعلی آلترناتیوها
update-alternatives --display java
```

### 🗑️ حذف نسخه‌های غیرضروری (اختیاری):
```bash
# حذف JDK 11 در صورت عدم نیاز
sudo apt remove openjdk-11-jdk
```

---

## 📊 جدول مقایسه نسخه‌های نصب شده

| ویژگی | OpenJDK 11 | OpenJDK 17 | OpenJDK 21 |
| :--- | :--- | :--- | :--- |
| **وضعیت** | LTS | LTS | **LTS (جدیدترین)** |
| **پشتیبانی** | تا ۲۰۲۴ | تا ۲۰۲۹ | تا ۲۰۳۱ |
| **پیش‌فرض** | ❌ | ✅ | ❌ (هدف) |
| **توصیه** | منسوخ شده | پایدار | **توصیه شده** |

---

## 💡 توصیه نهایی

1. **تغییر به OpenJDK 21** برای پروژه‌های جدید
2. **حفظ OpenJDK 17** برای compatibility با پروژه‌های موجود
3. **حذف OpenJDK 11** در صورت عدم نیاز برای صرفه‌جویی در فضای دیسک

