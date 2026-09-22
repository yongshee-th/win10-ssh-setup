@echo off
setlocal EnableDelayedExpansion
title Setup SSH

REM ===== ขอสิทธิ์ Administrator อัตโนมัติ =====
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo กำลังขอสิทธิ์ Administrator...
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo =====================================================
echo   Setup SSH - เครื่อง: %COMPUTERNAME%
echo   User ปัจจุบัน: %USERNAME%
echo =====================================================
echo.

REM ===== [1] เปิดใช้งาน OpenSSH Server =====
echo [1/5] กำลังติดตั้ง OpenSSH Server...
powershell -NoProfile -Command "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0" >nul 2>&1

echo [2/5] กำลังเปิด service sshd...
powershell -NoProfile -Command "Start-Service sshd; Set-Service -Name sshd -StartupType 'Automatic'"

echo [3/5] กำลังเปิด Firewall port 22...
powershell -NoProfile -Command "if (-not (Get-NetFirewallRule -Name sshd -ErrorAction SilentlyContinue)) { New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 }"

REM ===== [4] ใส่ public key ให้อัตโนมัติ (ตรวจว่า user เป็น admin หรือไม่) =====
echo [4/5] กำลังติดตั้ง SSH public key สำหรับ user: %USERNAME%

set "PUBKEY=ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNKYm6vXFOwSGEMjKT2IMWUcEX+1ubNxyUJkJh3kyok yongshee007@nitro -> lemon-pi"

whoami /groups | find "S-1-5-32-544" >nul
if %errorLevel% == 0 (
    echo    (user นี้เป็น Administrator - ใช้ administrators_authorized_keys^)
    if not exist "C:\ProgramData\ssh" mkdir "C:\ProgramData\ssh"
    > "C:\ProgramData\ssh\administrators_authorized_keys" echo %PUBKEY%
    icacls "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r >nul
    icacls "C:\ProgramData\ssh\administrators_authorized_keys" /grant SYSTEM:F >nul
    icacls "C:\ProgramData\ssh\administrators_authorized_keys" /grant Administrators:F >nul
    net stop sshd >nul
    net start sshd >nul
) else (
    if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"
    > "%USERPROFILE%\.ssh\authorized_keys" echo %PUBKEY%
)

echo [5/5] เสร็จสิ้น! กำลังดึง IP address...
echo.
echo =====================================================
echo   IP Address ของเครื่องนี้:
echo =====================================================
ipconfig | findstr /i "IPv4"
echo.
echo =====================================================
echo   Hostname: %COMPUTERNAME%     User: %USERNAME%
echo   ส่งข้อมูล 2 บรรทัดนี้กลับไปให้ Claude เพื่อทดสอบเชื่อมต่อ
echo =====================================================
echo.
pause
