# نشر تطبيق الويب (Flutter Web فقط)

هذا المشروع **واجهة ويب**؛ على السيرفر تُرفع **محتويات `build/web/`** فقط (وليس مشروع Android/iOS).

## 1) رفع الكود إلى GitHub

المستودع الحالي (مثال من الإعداد لديك):

`https://github.com/baitpait/-StorAnagheem.git`

من جهازك داخل مجلد المشروع:

```bash
git add -A
git status
git commit -m "Prepare web deploy workflow and docs"
git push origin main
```

إذا كان الفرع اسمه `master` استبدل `main` بـ `master`.

## 2) البناء التلقائي على GitHub

بعد الدفع، يعمل الملف `.github/workflows/build-web.yml`:

1. افتح المستودع على GitHub → **Actions**
2. اختر سير العمل **Build Flutter Web**
3. عند اكتمال التشغيل → **Artifacts** → نزّل **web-build**
4. فك الضغط وارفع **كل الملفات** داخل الأرشيف إلى جذر موقعك على السيرفر

## 3) البناء محلياً ثم الرفع للسيرفر

```bash
chmod +x scripts/build_web_release.sh
./scripts/build_web_release.sh
```

أو يدوياً:

```bash
flutter pub get
flutter build web --release
```

ثم انسخ محتويات `build/web/` إلى الاستضافة (SFTP / SCP / لوحة تحكم).

مثال `scp`:

```bash
scp -r build/web/* user@your-server:/var/www/anagheem/
```

## 4) إعداد السيرفر (مسارات التطبيق)

التطبيق يستخدم **توجيهاً من جانب العميل** (مثل `/contact-us`). يجب أن يعيد السيرفر **`index.html`** لأي مسار غير ملف ثابت.

- **Nginx:** راجع `deploy/nginx.site.example.conf`
- **Apache:** انسخ `deploy/htaccess.apache.example` إلى `.htaccess` بجانب `index.html`

## 5) الموقع في مجلد فرعي

إذا كان العنوان مثل `https://example.com/shop/` وليس الجذر، عدّل في `web/index.html`:

```html
<base href="/shop/">
```

ثم أعد `flutter build web --release`.

## 6) معاينة محلية بعد البناء

```bash
chmod +x scripts/serve_build_web.sh
./scripts/serve_build_web.sh
```

ثم افتح `http://127.0.0.1:8765/`

## 7) ملاحظات أمان

- لا ترفع ملفات `.env` أو أسرار لوحة التحكم.
- مفاتيح API الظاهرة في الكود (مثل Firebase في `main.dart` إن وُجدت) يُفضّل نقلها لاحقاً لمتغيرات بيئة أو بناء من CI.

## 8) السيرفر: جلب المشروع من GitHub وبناء الويب ونشره

### مرجع الإنتاج (مثال مُطبَّق)

| البند | القيمة |
|--------|--------|
| الدومين | `anagheemhome.com` |
| جذر الموقع (Document root) | `/home/baitpait/anagheemhome` |
| المستودع على القرص | `/home/baitpait/src/-StorAnagheem` |
| رابط الاستنساخ | `https://github.com/baitpait/-StorAnagheem.git` |
| الفرع | `main` |

**مهم:** اسم المجلد بعد الاستنساخ يبدأ بشرطة: **`-StorAnagheem`**. استخدم `cd -- -StorAnagheem` أو `cd -- /home/baitpait/src/-StorAnagheem` حتى لا يفسّر `cd` الاسم كخيارات.

**الفكرة:** تُستنسخ **المستودع** في مجلد **خارج** جذر الموقع العام (لا تُعرَض `lib/` و`android/` للزوار)، ثم يُبنى `build/web/` ويُنسخ **محتواه فقط** إلى مجلد الدومين.

---

### أ) متطلبات على السيرفر (Linux)

- `git`
- لبناء Flutter على Linux: إما **حزمة snap** (سريعة على Ubuntu) أو **أرشيف رسمي** — راجع [تثبيت Flutter على Linux](https://docs.flutter.dev/get-started/install/linux).
- `rsync` (للنشر؛ غالباً مثبت مسبقاً)

### ب) تثبيت Flutter (مرة واحدة)

#### خيار 1 — Snap (Ubuntu / عندما يقترح النظام `snap install flutter`)

```bash
snap install flutter --classic
```

بعدها يجب أن يكون **`/snap/bin`** في **`PATH`**، وإلا يظهر `flutter: command not found`:

```bash
export PATH="/snap/bin:$PATH"
flutter --version
```

للديمومة (مثال لـ root):

```bash
grep -q '/snap/bin' /root/.bashrc || echo 'export PATH="/snap/bin:$PATH"' >> /root/.bashrc
```

**تشغيل Flutter كـ root:** يظهر تحذير *«We strongly recommend running without superuser»*؛ البناء يعمل. الأفضل مستقبلاً مستخدم عادي بصلاحيات كتابة على مجلدات `src` و`anagheemhome`.

#### خيار 2 — أرشيف tarball رسمي

نزّل أحدث **Linux stable** من صفحة Flutter، ثم مثلاً:

```bash
cd ~
tar xf flutter_linux_*-stable.tar.xz
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
flutter doctor
```

تأكد أن `flutter build web` يعمل (`flutter doctor` بدون عوائق حرجة).

### ج) إعداد مجلد الموقع (مرة واحدة)

المجلد الذي يشير إليه الدومين يجب أن يكون **مساراً مطلقاً** يبدأ بـ `/`:

```bash
mkdir -p /home/baitpait/anagheemhome
ls -la /home/baitpait/anagheemhome
```

**خطأ شائع:** كتابة `cd home/baitpait/anagheemhome` بدون `/` في البداية — يبحث النظام عن مسار نسبي من مجلدك الحالي (مثل `/root/home/...`) ويفشل. الصحيح: `cd /home/baitpait/anagheemhome`.

ربط الدومين بهذا المسار يتم من **Nginx / Apache / لوحة الاستضافة** (راجع القسم 4 و`deploy/nginx.site.example.conf`).

### د) استنساخ المستودع (أول مرة)

كمستخدم **root** أو **baitpait** (حسب سياسة السيرفر):

```bash
mkdir -p /home/baitpait/src
cd /home/baitpait/src
git clone https://github.com/baitpait/-StorAnagheem.git
chown -R baitpait:baitpait /home/baitpait/src/-StorAnagheem
cd -- /home/baitpait/src/-StorAnagheem
git checkout main
```

إذا كان المستودع **خاصاً**: **Deploy key** على GitHub أو **PAT** في رابط الاستنساخ (تجنّب تسريب التوكن في السجلات).

### هـ) جلب الحزم والبناء

```bash
export PATH="/snap/bin:$PATH"   # إن كنت تستخدم snap
cd -- /home/baitpait/src/-StorAnagheem
flutter pub get
flutter build web --release
```

أو السكربت الجاهز (ينفّذ `pub get` ثم البناء):

```bash
chmod +x scripts/build_web_release.sh
./scripts/build_web_release.sh
```

**مخرجات البناء الناجحة:** تظهر `✓ Built build/web`.

**تحذيرات Wasm dry run** (`dart:html unsupported`، إلخ): معلومات عن توافق **WebAssembly** مستقبلاً؛ **لا تمنع** بناء الويب الاعتيادي (JavaScript). يمكن تجاهلها أو استخدام `--no-wasm-dry-run` لتقليل الضجيج.

### و) نشر الملفات إلى جذر الموقع

ينسخ **محتويات** `build/web/` إلى مجلد الدومين (`--delete` يزيل من الوجهة ما لم يعد موجوداً في البناء):

```bash
rsync -av --delete /home/baitpait/src/-StorAnagheem/build/web/ /home/baitpait/anagheemhome/
```

**Apache:** انسخ قواعد إعادة الكتابة إلى `.htaccess` بجانب `index.html`:

```bash
cp /home/baitpait/src/-StorAnagheem/deploy/htaccess.apache.example /home/baitpait/anagheemhome/.htaccess
```

**Nginx:** لا يُستخدم `.htaccess`؛ اضبط `try_files` كما في `deploy/nginx.site.example.conf`.

توحيد المالك بعد النسخ (إن لزم):

```bash
chown -R baitpait:baitpait /home/baitpait/anagheemhome
```

**التحقق:** افتح `https://anagheemhome.com/` وجرب تحديث صفحة على مسار داخلي (مثل صفحة اتصل بنا) — يجب ألا تُرجع 404 من السيرفر.

### ز) التحديثات لاحقاً

```bash
export PATH="/snap/bin:$PATH"
cd -- /home/baitpait/src/-StorAnagheem
git pull origin main
./scripts/build_web_release.sh
rsync -av --delete /home/baitpait/src/-StorAnagheem/build/web/ /home/baitpait/anagheemhome/
```

---

### ح) قائمة تحقق سريعة (خطوة بخطوة)

1. `git --version` يعمل على السيرفر.
2. مجلد `/home/baitpait/anagheemhome` موجود؛ الدومين يشير إليه في إعداد الويب سيرفر.
3. Flutter مثبت؛ `export PATH="/snap/bin:$PATH"` (snap) أو مسار tarball في `PATH`.
4. `git clone` داخل `/home/baitpait/src/` والمجلد `.../src/-StorAnagheem` موجود.
5. `flutter pub get` بدون أخطاء حرجة (تنبيهات «discontinued» أو إصدارات أحدث **عادية**).
6. `flutter build web --release` → `✓ Built build/web`.
7. `rsync` إلى `/home/baitpait/anagheemhome/`.
8. Apache: `.htaccess` من `deploy/htaccess.apache.example`.
9. `chown` إن احتجت.
10. اختبار الموقع في المتصفح.

## 9) أخطاء ومفاجآت شائعة

### المسار النسبي بدل المطلق

- **خطأ:** `cd home/baitpait/anagheemhome`
- **صواب:** `cd /home/baitpait/anagheemhome`

بدون `/` في البداية يُفسَّر المسار من مجلد العمل الحالي.

### لصق مخرجات `curl` في الطرفية

أسطر مثل `% Total` و`Dload` و`100 1444M` هي **مخرجات تحميل** وليست أوامر. لصقها في bash يسبب أخطاء مثل `command not found`. انسخ الأوامر فقط.

### `flutter: command not found` بعد تثبيت snap

أضف `/snap/bin` إلى `PATH` (انظر القسم 8 ب)، أو استخدم `/snap/bin/flutter` مباشرة.

### `su - baitpait` → «This account is currently not available»

غالباً صدفة المستخدم `nologin`. يمكن:

- المتابعة كـ **root** للبناء (مع تحذير Flutter)، أو
- تفعيل دخول تفاعلي لمستخدم الاستضافة عبر لوحة التحكم أو `chsh` (بحذر وبما يتوافق مع سياسة الأمان).

### رفع ملفات GitHub Actions ورفض الـ push

إذا رفض GitHub الدفع بسبب ملف `.github/workflows/*.yml`، فالـ **Personal Access Token** يحتاج صلاحية **`workflow`**. بديل: إضافة الملف من واجهة GitHub أو استخدام PAT محدّث.

## 10) الملفات المرجعية في المستودع

| الملف | الغرض |
|--------|--------|
| `scripts/build_web_release.sh` | `pub get` + `flutter build web --release` |
| `scripts/serve_build_web.sh` | معاينة محليّة لـ `build/web` |
| `deploy/nginx.site.example.conf` | مثال Nginx + `try_files` لـ SPA |
| `deploy/htaccess.apache.example` | قواعد Apache لإرجاع `index.html` |
| `.github/workflows/build-web.yml` | بناء على GitHub Actions (يتطلّب PAT بصلاحية workflow عند الدفع) |
