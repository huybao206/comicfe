@echo off
echo ==========================================
echo Fix Kotlin/image_picker Android cache issue
echo ==========================================
echo.

REM Chay file nay o THU MUC GOC Flutter project, cung cap voi pubspec.yaml

echo [1/7] Stop Gradle daemon...
cd android
call gradlew --stop
cd ..

echo.
echo [2/7] Clean Flutter...
call flutter clean

echo.
echo [3/7] Delete project build caches...
if exist build rmdir /s /q build
if exist .dart_tool rmdir /s /q .dart_tool
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\app\build rmdir /s /q android\app\build

echo.
echo [4/7] Delete image_picker Android plugin cache from Pub cache...
if exist "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\image_picker_android-0.8.13+17" (
  rmdir /s /q "%LOCALAPPDATA%\Pub\Cache\hosted\pub.dev\image_picker_android-0.8.13+17"
)

echo.
echo [5/7] Repair Pub cache...
call dart pub cache repair

echo.
echo [6/7] Get packages...
call flutter pub get

echo.
echo [7/7] Run app...
call flutter run

pause
