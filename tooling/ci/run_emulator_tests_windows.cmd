@echo off
REM Script run inside firebase emulators:exec on Windows runners
echo Running emulator test script (Windows)

REM Change to repository root (two levels up from tooling\ci)
cd /d "%~dp0\..\.."
echo Repo root: %cd%

echo Installing npm deps for tooling...
npm ci --prefix tooling

echo Generating staff idToken...
npm run gen-token --prefix tooling

echo Running flutter test for emulator REST tests...
flutter test test/session_emulator_rest_test.dart -r expanded

exit /b %ERRORLEVEL%
