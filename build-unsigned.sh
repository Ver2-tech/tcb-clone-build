#!/bin/bash
set -e

# Chạy trên máy Mac có Xcode.
# Kết quả: TCBClone-unsigned.ipa — đem sang Windows dùng Sideloadly để ký và cài.

cd "$(dirname "$0")"

rm -rf Build Payload TCBClone-unsigned.ipa

xcodebuild \
  -project TCBClone.xcodeproj \
  -target TCBClone \
  -configuration Release \
  -sdk iphoneos \
  -derivedDataPath Build \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_STYLE=Manual \
  build

APP="Build/Build/Products/Release-iphoneos/TCBClone.app"
test -d "$APP" || { echo "Không tìm thấy $APP"; exit 1; }

mkdir -p Payload
cp -R "$APP" Payload/TCBClone.app
zip -qry TCBClone-unsigned.ipa Payload

echo "Xong: $(pwd)/TCBClone-unsigned.ipa"
