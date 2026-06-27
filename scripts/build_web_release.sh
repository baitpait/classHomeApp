#!/usr/bin/env bash
# بناء نسخة الويب للإنتاج — المحتوى الجاهز للرفع: مجلد build/web
# الاستخدام:
#   bash scripts/build_web_release.sh                          # يستخدم admin.mahfoozco.com افتراضياً
#   API_BASE_URL=https://other.example.com/ bash scripts/...   # يخصّص الـ baseUrl
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# baseUrl للإنتاج — يمكن تخصيصه عبر متغير بيئة
API_BASE_URL="${API_BASE_URL:-https://admin.mahfoozco.com/}"

echo "==> Build configuration:"
echo "    API_BASE_URL = $API_BASE_URL"

# يحدّث web/index.html و web/manifest.json من /api/v1/config قبل البناء (ميتا واتساب/SEO = لوحة التحكم)
python3 scripts/sync_web_meta_from_api.py
flutter pub get
# --pwa-strategy=none: نُعطّل Service Worker بشكل كامل لمنع مشكلة الـ cache العنيد.
# Flutter يولّد `serviceWorkerVersion` بنفس القيمة أحياناً رغم تغير الملفات،
# مما يجعل SW القديم في المتصفح يستمر بخدمة main.dart.js قديم من الـ cache.
# للمتجر الذي يحتاج بيانات حية من الـ API، تعطيل PWA cache أفضل من البديل.
flutter build web --release \
  --pwa-strategy=none \
  --dart-define=API_BASE_URL="$API_BASE_URL"

# ============================================================================
# حقن "kill-switch service worker" فوق الملف الفارغ الذي يولّده Flutter.
# الهدف: المتصفحات التي فيها SW قديم تستبدله بهذا SW الجديد الذي ينتحر ذاتياً
# وينظّف كل caches القديمة. بدون هذا، يستمر السلوك القديم (Bearer null,
# &&offset، الكود القديم) لأن SW القديم يخدم main.dart.js من cache.
# ============================================================================
KILLSWITCH_SRC="$ROOT/web/flutter_service_worker_killswitch.js"
KILLSWITCH_DST="$ROOT/build/web/flutter_service_worker.js"
if [ -f "$KILLSWITCH_SRC" ]; then
  cp "$KILLSWITCH_SRC" "$KILLSWITCH_DST"
  echo "==> حُقن kill-switch في flutter_service_worker.js ($(wc -c < "$KILLSWITCH_DST") bytes)"
else
  echo "⚠️  لم يُعثر على $KILLSWITCH_SRC — flutter_service_worker.js سيبقى فارغاً"
fi

# نفس المعالجة لـ firebase-messaging-sw.js في حال كان مسجلاً عند المستخدمين سابقاً.
FIREBASE_SW="$ROOT/build/web/firebase-messaging-sw.js"
if [ -f "$FIREBASE_SW" ] && [ -f "$KILLSWITCH_SRC" ]; then
  cp "$KILLSWITCH_SRC" "$FIREBASE_SW"
  echo "==> حُقن kill-switch في firebase-messaging-sw.js"
fi

echo "تم. ارفع محتويات المجلد إلى السيرفر: $ROOT/build/web/"
