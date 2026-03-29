#!/usr/bin/env bash
# Flutter Web يجب أن يُفتح عبر http:// وليس file://
# الاستخدام: بعد  flutter build web  شغّل:
#   chmod +x scripts/serve_build_web.sh && ./scripts/serve_build_web.sh
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
if [[ ! -f build/web/index.html ]]; then
  echo "لا يوجد build/web — نفّذ أولاً: flutter build web"
  exit 1
fi
PORT="${1:-8765}"
echo "افتح في المتصفح: http://127.0.0.1:${PORT}/"
cd build/web
exec python3 -m http.server "$PORT"
