// ========================================================================
// KILL-SWITCH SERVICE WORKER (mahfoozco.com)
// ------------------------------------------------------------------------
// هذا الملف يحل محل flutter_service_worker.js القديم على السيرفر.
// المشكلة التي حلها: SW قديم في متصفحات المستخدمين يخدم main.dart.js قديم
// من الـ cache، فيستمر السلوك القديم (Bearer null, &&offset, ...) حتى بعد
// رفع البيلد الجديد على السيرفر.
//
// الآلية:
//  1. كل متصفح فيه SW قديم يفحص flutter_service_worker.js بصورة دورية.
//  2. عندما يكتشف أن الملف اختلف عن المُسجَّل، يبدأ install للنسخة الجديدة.
//  3. هذه النسخة (الـ kill-switch) في install: skipWaiting() → نشط فوراً.
//  4. في activate: يلغي تسجيل نفسه + يحذف كل caches + يجبر كل صفحات
//     المستخدمين المفتوحة على إعادة التحميل.
//  5. النتيجة: لا SW، لا cache قديم، main.dart.js يأتي مباشرة من Apache.
//
// بعد تطبيق هذا، الزوار الجدد لا يحتاجون أي عمل يدوي. كل مستخدم سابق
// عند زيارته التالية يحدث له تنظيف تلقائي.
// ========================================================================

self.addEventListener('install', function (event) {
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', function (event) {
  event.waitUntil(
    (async function () {
      try {
        var keys = await caches.keys();
        await Promise.all(keys.map(function (k) { return caches.delete(k); }));
      } catch (e) { /* تجاهل أخطاء الـ cache */ }

      try {
        await self.registration.unregister();
      } catch (e) { /* تجاهل أخطاء unregister */ }

      try {
        var clients = await self.clients.matchAll({ type: 'window' });
        clients.forEach(function (client) {
          try { client.navigate(client.url); } catch (e) { /* تجاهل */ }
        });
      } catch (e) { /* تجاهل */ }
    })()
  );
});

self.addEventListener('fetch', function (event) {
  // مرر كل الطلبات إلى الشبكة مباشرة بلا cache.
  return;
});
