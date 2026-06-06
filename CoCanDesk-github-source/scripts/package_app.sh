#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build/release"
APP_DIR="$ROOT_DIR/dist/CoCanDesk.app"

cd "$ROOT_DIR"
mkdir -p .build/home .build/tmp .build/module-cache
HOME="$ROOT_DIR/.build/home" \
TMPDIR="$ROOT_DIR/.build/tmp" \
CLANG_MODULE_CACHE_PATH="$ROOT_DIR/.build/module-cache" \
swift build --disable-sandbox -c release

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BUILD_DIR/CoCanDesk" "$APP_DIR/Contents/MacOS/CoCanDesk"
if [ -f "$ROOT_DIR/Sources/CoCanDesk/Resources/AppIcon.icns" ]; then
  cp "$ROOT_DIR/Sources/CoCanDesk/Resources/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi
if [ -f "$ROOT_DIR/Sources/CoCanDesk/Resources/ProductDevice.png" ]; then
  cp "$ROOT_DIR/Sources/CoCanDesk/Resources/ProductDevice.png" "$APP_DIR/Contents/Resources/ProductDevice.png"
fi
cat > "$APP_DIR/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>CoCanDesk</string>
  <key>CFBundleIdentifier</key>
  <string>com.local.cocandesk</string>
  <key>CFBundleName</key>
  <string>CoCanDesk</string>
  <key>CFBundleDisplayName</key>
  <string>小电拼控制台</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>0.1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>NSLocationUsageDescription</key>
  <string>用于根据本机当前位置获取天气，让糖糖宠物切换白天、夜晚、阴晴雨雪场景。</string>
  <key>NSLocationWhenInUseUsageDescription</key>
  <string>用于根据本机当前位置获取天气，让糖糖宠物切换白天、夜晚、阴晴雨雪场景。</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

if command -v codesign >/dev/null 2>&1; then
  if command -v xattr >/dev/null 2>&1; then
    xattr -cr "$APP_DIR" >/dev/null 2>&1 || true
    xattr -dr com.apple.provenance "$APP_DIR" >/dev/null 2>&1 || true
    xattr -dr com.apple.FinderInfo "$APP_DIR" >/dev/null 2>&1 || true
    xattr -dr 'com.apple.fileprovider.fpfs#P' "$APP_DIR" >/dev/null 2>&1 || true
  fi
  codesign --force --deep --sign - "$APP_DIR" >/dev/null 2>&1 || true
fi

echo "$APP_DIR"
