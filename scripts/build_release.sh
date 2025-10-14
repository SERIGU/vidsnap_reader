#!/usr/bin/env bash
set -euo pipefail

flutter clean
flutter pub get
flutter build apk --release
echo "APK listo en build/app/outputs/flutter-apk/app-release.apk"
