@echo off
REM Build Debug (local)
flutter build apk --debug

REM Build Release (local, sin firma)
flutter build apk --release

