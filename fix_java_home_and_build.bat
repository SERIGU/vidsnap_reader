@echo off
setlocal EnableExtensions

REM === CONFIGURACIÓN ===
set "PROJECT_DIR=%~dp0"
set "JDK_DIR=C:\Program Files\Eclipse Adoptium\jdk-17.0.16.8-hotspot"
set "GRADLE_PROPS=%PROJECT_DIR%android\gradle.properties"

echo ===============================================
echo  VidSnap Reader - Fix JAVA_HOME y Build (Admin)
echo  Proyecto: %PROJECT_DIR%
echo  JDK objetivo: %JDK_DIR%
echo ===============================================
echo.

REM 1) Validar que el JDK exista
if not exist "%JDK_DIR%\bin\java.exe" (
  echo [ERROR] No se encontro %JDK_DIR%\bin\java.exe
  echo Instala Temurin JDK 17.0.16.8 o corrige la ruta JDK_DIR en este script.
  exit /b 1
)

REM 2) Limpiar JAVA_HOME de Usuario y Sistema
echo [INFO] Limpiando JAVA_HOME (User y Machine)...
powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('JAVA_HOME',$null,'User')"
powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('JAVA_HOME',$null,'Machine')"

REM 3) Fijar JAVA_HOME correcto (Usuario y Sistema)
echo [INFO] Estableciendo JAVA_HOME correcto...
powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('JAVA_HOME','%JDK_DIR%','User')"
powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('JAVA_HOME','%JDK_DIR%','Machine')"

REM 4) Prepend del PATH para esta sesion
set "PATH=%JDK_DIR%\bin;%PATH%"

REM 5) Verificación rápida de Java
echo.
echo [CHECK] java -version
"%JDK_DIR%\bin\java.exe" -version || (echo [ERROR] Java no responde. & exit /b 1)

REM 6) Asegurar org.gradle.java.home en gradle.properties
echo.
echo [INFO] Asegurando org.gradle.java.home en:
echo        %GRADLE_PROPS%

if not exist "%GRADLE_PROPS%" (
  echo org.gradle.jvmargs=-Xmx4g -Dfile.encoding=UTF-8> "%GRADLE_PROPS%"
  echo android.useAndroidX=true>> "%GRADLE_PROPS%"
  echo android.enableJetifier=true>> "%GRADLE_PROPS%"
)

REM Quitar lineas previas de org.gradle.java.home si existieran (crear tmp)
set "TMP_FILE=%GRADLE_PROPS%.tmp"
type "%GRADLE_PROPS%" | findstr /R /V /C:"^org.gradle.java.home=" > "%TMP_FILE%"
move /Y "%TMP_FILE%" "%GRADLE_PROPS%" >nul

echo org.gradle.java.home=%JDK_DIR%>> "%GRADLE_PROPS%"
echo [OK] gradle.properties actualizado.

REM 7) Verificar Gradle con el JDK correcto
echo.
echo [CHECK] Gradle wrapper usando JDK correcto:
call "%PROJECT_DIR%android\gradlew.bat" -p "%PROJECT_DIR%android" -v
if errorlevel 1 (
  echo [WARN] gradlew -v devolvio error, continuaremos con Flutter (puede deberse a cache previa).
)

REM 8) (Opcional) Compilar APK
echo.
choice /M "Deseas compilar ahora el APK (flutter build apk)?" /C SY /N
if errorlevel 2 goto END

echo.
echo [BUILD] Ejecutando flutter clean / pub get / build apk...
cd /d "%PROJECT_DIR%"
call flutter clean
if errorlevel 1 goto BUILD_ERR
call flutter pub get
if errorlevel 1 goto BUILD_ERR
call flutter build apk
if errorlevel 1 goto BUILD_ERR

echo.
echo [SUCCESS] Build completado. APK listo en:
echo %PROJECT_DIR%build\app\outputs\flutter-apk\app-release.apk
goto END

:BUILD_ERR
echo.
echo [ERROR] Fallo durante el build. Revisa la salida anterior.

:END
echo.
echo [DONE] Script finalizado.
endlocal
