@echo off
setlocal enabledelayedexpansion
title 🏥 NextGen Hospital OPD Queue & Management System Launcher
color 0F

echo =====================================================================
echo   🏥 NextGen Hospital OPD Queue & Management System
echo   Shri Satya Sai Gramya Arogya Mandir
echo =====================================================================
echo.

:: 1. Check MongoDB Service
echo [1/4] Checking MongoDB Service...
sc query MongoDB | findstr /i "STATE" | findstr /i "RUNNING" >nul 2>&1
if %errorlevel% equ 0 (
    echo   [OK] MongoDB Service is RUNNING.
) else (
    echo   [!] Attempting to start MongoDB service...
    net start MongoDB >nul 2>&1
    if %errorlevel% equ 0 (
        echo   [OK] MongoDB Service started successfully.
    ) else (
        echo   [WARN] Could not auto-start MongoDB service.
        echo          Ensure MongoDB is running locally on port 27017 or Atlas URI is in .env
    )
)
echo.

:: 2. Check Backend Environment file
echo [2/4] Verifying Environment Configuration...
if not exist "%~dp0hospital-api-server\.env" (
    if exist "%~dp0hospital-api-server\.env.example" (
        copy "%~dp0hospital-api-server\.env.example" "%~dp0hospital-api-server\.env" >nul
        echo   [OK] Created hospital-api-server\.env from .env.example
    )
) else (
    echo   [OK] hospital-api-server\.env is present.
)
echo.

:: 3. Launch Services in Separate Windows
echo [3/4] Launching Monorepo Services...
echo   - Spawning Hospital API Server (:4000)...
start "🏥 Hospital API Server (:4000)" cmd /k "cd /d "%~dp0hospital-api-server" && title 🏥 Hospital API Server (:4000) && color 0A && echo [API SERVER] Starting Node.js backend on http://localhost:4000 ... && npm start"

echo   - Spawning Staff Admin Portal (:3001)...
start "📋 Hospital Admin Web App (:3001)" cmd /k "cd /d "%~dp0hospital-admin-app" && title 📋 Hospital Admin Web App (:3001) && color 0B && echo [ADMIN PORTAL] Starting Next.js app on http://localhost:3001 ... && npm run dev"

echo   - Spawning Patient App (Flutter)...
start "📱 Hospital Patient App (Flutter)" cmd /k "cd /d "%~dp0hospital_patient_app" && title 📱 Hospital Patient App (Flutter) && color 0E && echo [PATIENT APP] Starting Flutter client... && flutter run"

echo.
echo [4/4] System launched successfully!
echo.
echo =====================================================================
echo                     🚀 QUICK ACCESS URLS & CREDENTIALS
echo =====================================================================
echo   * Backend API:       http://localhost:4000
echo   * Health Check:      http://localhost:4000/health
echo   * Staff Admin Portal: http://localhost:3001  (Default PIN: 1234)
echo   * Patient Flutter App: Running in dedicated Flutter terminal
echo =====================================================================
echo.
echo Opening Admin Portal in your default browser in 4 seconds...
timeout /t 4 /nobreak >nul
start http://localhost:3001

echo.
echo Press any key to exit this launcher window (services will stay running in their windows).
pause >nul
