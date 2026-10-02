#!/bin/bash
# Chạy trên máy Mac có Xcode 16+. Tạo ra ScanPro.ipa (chưa ký) trong thư mục build/
set -e
command -v xcodegen >/dev/null || brew install xcodegen
xcodegen generate
xcodebuild -project ScanPro.xcodeproj -scheme ScanPro -configuration Release \
  -sdk iphoneos -derivedDataPath build/derived \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY="" build
rm -rf build/Payload && mkdir -p build/Payload
cp -R build/derived/Build/Products/Release-iphoneos/ScanPro.app build/Payload/
(cd build && zip -qr ScanPro.ipa Payload)
echo "Xong: build/ScanPro.ipa"
