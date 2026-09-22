@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo =====================================================
echo   1) เนื้อหาไฟล์ authorized_keys
echo =====================================================
type C:\ProgramData\ssh\administrators_authorized_keys
echo.
echo =====================================================
echo   2) Permission ของไฟล์นั้น (ต้องมีแค่ SYSTEM กับ Administrators)
echo =====================================================
icacls C:\ProgramData\ssh\administrators_authorized_keys
echo.
echo =====================================================
echo   3) เนื้อหา sshd_config ส่วน Match Group administrators
echo =====================================================
findstr /i "administrators AuthorizedKeysFile PubkeyAuthentication" C:\ProgramData\ssh\sshd_config
echo.
echo =====================================================
echo   4) สถานะ service sshd
echo =====================================================
sc query sshd | findstr STATE
echo.
echo =====================================================
echo   5) เปิด log ชั่วคราวแล้วดึง error ล่าสุด (ถ้ามี)
echo =====================================================
powershell -NoProfile -Command "Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 15 -ErrorAction SilentlyContinue | Select-Object TimeCreated,Message | Format-List"
echo.
pause
