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
