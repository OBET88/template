@echo off
title Git Project Manager - Auto Cek & Link Install
color 0A
cls

setlocal EnableDelayedExpansion

:: ===== CEK & ARAHKAN INSTALL JIKA PERLU =====
echo ==================================================
echo      CEK SOFTWARE WAJIB: Git, PHP, Composer, NPM
echo ==================================================

call :cek_software "Git" "git --version" "https://git-scm.com/download/win"
call :cek_software "PHP" "php -v" "https://windows.php.net/download/"
call :cek_software "Composer" "composer --version" "https://getcomposer.org/Composer-Setup.exe"
call :cek_software "Node.js & NPM" "npm -v" "https://nodejs.org/"

echo ==================================================
echo Pastikan semua software di atas sudah terinstal.
pause

goto menu

:: ===== CEK SOFTWARE =====
:cek_software
setlocal EnableDelayedExpansion
set "software=%~1"
set "command=%~2"
set "download_url=%~3"

echo Mengecek %software%...

:: Jalankan perintah dan simpan output
del tmp_check.txt >nul 2>&1
cmd /c "!command!" > tmp_check.txt 2>&1

if errorlevel 1 (
    echo [X] %software% TIDAK TERDETEKSI!
    echo     Buka halaman download: %download_url%
    start "" %download_url%
    del tmp_check.txt >nul 2>&1
    endlocal
    exit /b
)

set "foundLine="
for /f "tokens=*" %%i in (tmp_check.txt) do (
    if not defined foundLine set "foundLine=%%i"
)

if defined foundLine (
    echo [OK] %software% terdeteksi: !foundLine!
) else (
    echo [X] %software% TERPASANG tapi tidak memberikan output versi.
)

del tmp_check.txt >nul 2>&1
endlocal
exit /b

:: ===== FUNGSI DETEKSI BRANCH =====
:detect_branch
set "BRANCH=main"
for /f "delims=" %%B in ('git branch 2^>nul') do (
    echo %%B | findstr /C:"master" >nul && set "BRANCH=master"
    echo %%B | findstr /C:"main" >nul && set "BRANCH=main"
)
exit /b

:: ===== MENU GIT =====
:menu
cls
echo ========================================================
echo               GIT PROJECT MANAGER - MENU UTAMA
echo ========================================================
echo 1. [CLONE] Ambil project dari GitHub ke komputer ini
echo    → Untuk project yang SUDAH ADA di GitHub.
echo.
echo 2. [UPLOAD PERTAMA] Kirim project lokal ini ke GitHub
echo    → Untuk project lokal BARU yang belum diupload ke GitHub.
echo.
echo 3. [UPDATE: COMMIT DAN PUSH] Kirim perubahan ke GitHub
echo    → Setelah kamu ubah isi project di lokal.
echo.
echo 4. [AMBIL UPDATE: PULL] Ambil perubahan terbaru dari GitHub
echo    → Kalau temanmu sudah push ke GitHub.
echo.
echo 5. [CEK STATUS] Lihat file yang berubah di lokal
echo.
echo 6. [KELUAR]
echo ========================================================
set /p pilihan=Masukkan pilihan (1-6): 

if "%pilihan%"=="1" goto clone
if "%pilihan%"=="2" goto upload_pertama
if "%pilihan%"=="3" goto update_project
if "%pilihan%"=="4" goto pull_project
if "%pilihan%"=="5" goto cek_status
if "%pilihan%"=="6" exit

echo Pilihan tidak valid!
pause
goto menu

:clone
cls
set /p clone_url=Masukkan URL repo GitHub (contoh: https://github.com/user/repo.git): 
git clone %clone_url%
echo [SELESAI] Project berhasil di-clone ke lokal.
pause
goto menu

:upload_pertama
cls
if exist ".git" (
    echo [INFO] Folder ini sudah merupakan Git repository.
    echo Upload pertama hanya untuk project lokal yang belum dihubungkan ke GitHub.
    pause
    goto menu
)

set /p remote_url=Masukkan URL repo GitHub tujuan (https://github.com/...): 
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin %remote_url%
git push -u origin main
echo [SELESAI] Project berhasil diupload ke GitHub.
pause
goto menu

:update_project
cls
if not exist ".git" (
    echo [ERROR] Folder ini belum merupakan Git repository.
    pause
    goto menu
)

call :detect_branch
git status
set /p commit_msg=Masukkan pesan commit: 
git add .
git commit -m "%commit_msg%"
git push origin !BRANCH!
echo [SELESAI] Perubahan berhasil dikirim ke GitHub (!BRANCH!).
pause
goto menu

:pull_project
cls
if not exist ".git" (
    echo [ERROR] Folder ini belum merupakan Git repository.
    pause
    goto menu
)

call :detect_branch
git pull origin !BRANCH!
echo [SELESAI] Update dari GitHub berhasil ditarik (!BRANCH!).
pause
goto menu

:cek_status
cls
if not exist ".git" (
    echo [ERROR] Folder ini belum merupakan Git repository.
    pause
    goto menu
)
git status
pause
goto menu