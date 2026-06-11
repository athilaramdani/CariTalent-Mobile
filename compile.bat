@echo off
echo Building CariTalent APK...
call flutter build apk --release

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b %ERRORLEVEL%
)

set APK_DIR=build\app\outputs\flutter-apk
set OLD_NAME=app-release.apk
set NEW_NAME=caritalent.apk

echo Renaming APK to %NEW_NAME%...
if exist "%APK_DIR%\%NEW_NAME%" del "%APK_DIR%\%NEW_NAME%"
ren "%APK_DIR%\%OLD_NAME%" "%NEW_NAME%"

echo Opening release folder...
start "" "%APK_DIR%"

echo.
echo ========================================
echo Done! APK location: %APK_DIR%\%NEW_NAME%
echo ========================================
pause
