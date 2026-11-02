#!/usr/bin/env bash
# Chạy E2E Maestro: backend -> build -> cài -> maestro -> tắt backend.
# Dùng: scripts/run_e2e.sh [android|ios] [smoke]
set -euo pipefail

PLATFORM="${1:-android}"
SUITE="${2:-smoke}"
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FE="$ROOT/FE_Flutter"
BE="$ROOT/BE_GoLang"
REPORT="$FE/report.xml"

case "$PLATFORM" in
  android) APP_ID="com.example.inventory"; APP_API="http://10.0.2.2:8080" ;;
  ios)     APP_ID="com.namtruong244.personal-inventory"; APP_API="http://localhost:8080" ;;
  *) echo "Platform phải là android hoặc ios" >&2; exit 2 ;;
esac
# Suite full (F1–F15) chưa có thư mục .maestro/full: từ chối ngay thay vì build xong mới lỗi.
[[ "$SUITE" == "smoke" ]] || { echo "Suite phải là smoke (suite full chưa làm, xem E2E_TEST_PLAN.md)" >&2; exit 2; }
command -v maestro >/dev/null || { echo "Thiếu maestro: https://maestro.mobile.dev" >&2; exit 1; }

BE_PID=""
# `go run` sinh tiến trình con (binary api): tắt cả con lẫn cha.
cleanup() {
  [[ -n "$BE_PID" ]] || return 0
  pkill -P "$BE_PID" 2>/dev/null || true
  kill "$BE_PID" 2>/dev/null || true
}
trap cleanup EXIT

echo "==> Backend"
if ! docker ps --format '{{.Names}}' | grep -qx inventory_postgres; then
  (cd "$BE" && make db-up)
fi
# AUTH_RATE_LIMIT nới giới hạn /auth/* (mặc định 30/15 phút/IP) vì mỗi flow đăng ký user mới.
(cd "$BE" && AUTH_RATE_LIMIT=100000 exec go run ./cmd/api) >"$FE/.e2e_backend.log" 2>&1 &
BE_PID=$!
for _ in $(seq 1 60); do
  curl -fs http://localhost:8080/health >/dev/null && break
  sleep 1
done
curl -fs http://localhost:8080/health >/dev/null || { echo "Backend không lên (xem .e2e_backend.log)" >&2; exit 1; }

echo "==> Build & cài ($PLATFORM)"
cd "$FE"
DEFINES=(--dart-define=API_BASE_URL="$APP_API" --dart-define=E2E=true)
if [[ "$PLATFORM" == android ]]; then
  flutter build apk --debug "${DEFINES[@]}"
  adb install -r build/app/outputs/flutter-apk/app-debug.apk
else
  flutter build ios --simulator --debug "${DEFINES[@]}"
  xcrun simctl install booted build/ios/iphonesimulator/Runner.app
fi

echo "==> Maestro ($SUITE)"
# seed.js luôn gọi backend từ máy host.
maestro test ".maestro/$SUITE" \
  -e APP_ID="$APP_ID" -e API_URL=http://localhost:8080 \
  --format junit --output "$REPORT"
echo "Báo cáo: $REPORT  (ảnh chụp: ~/.maestro/tests/)"
