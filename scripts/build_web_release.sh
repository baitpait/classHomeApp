#!/usr/bin/env bash
# بناء نسخة الويب للإنتاج — المحتوى الجاهز للرفع: مجلد build/web
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
flutter pub get
flutter build web --release
echo "تم. ارفع محتويات المجلد إلى السيرفر: $ROOT/build/web/"
