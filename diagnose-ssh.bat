@echo off
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

set "OUT=%~dp0diagnose-result.txt"

echo ===================================================== > "%OUT%"
echo   1) เนื้อหาไฟล์ authorized_keys >> "%OUT%"
echo ===================================================== >> "%OUT%"
type C:\ProgramData\ssh\administrators_authorized_keys >> "%OUT%" 2>&1
echo. >> "%OUT%"
echo ===================================================== >> "%OUT%"
echo   2) Permission ของไฟล์นั้น >> "%OUT%"
echo ===================================================== >> "%OUT%"
icacls C:\ProgramData\ssh\administrators_authorized_keys >> "%OUT%" 2>&1
echo. >> "%OUT%"
echo ===================================================== >> "%OUT%"
echo   3) sshd_config ส่วนที่เกี่ยวกับ administrators >> "%OUT%"
echo ===================================================== >> "%OUT%"
findstr /i "administrators AuthorizedKeysFile PubkeyAuthentication StrictModes" C:\ProgramData\ssh\sshd_config >> "%OUT%" 2>&1
echo. >> "%OUT%"
echo ===================================================== >> "%OUT%"
echo   4) สถานะ service sshd >> "%OUT%"
echo ===================================================== >> "%OUT%"
sc query sshd | findstr STATE >> "%OUT%"
echo. >> "%OUT%"
echo ===================================================== >> "%OUT%"
echo   5) Log ล่าสุด 15 รายการ >> "%OUT%"
echo ===================================================== >> "%OUT%"
powershell -NoProfile -Command "Get-WinEvent -LogName 'OpenSSH/Operational' -MaxEvents 15 -ErrorAction SilentlyContinue | Select-Object TimeCreated,Message | Format-List" >> "%OUT%" 2>&1

notepad "%OUT%"
