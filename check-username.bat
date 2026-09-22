@echo off
echo =====================================================
echo   1) whoami (username เต็มที่ OpenSSH ควรใช้)
echo =====================================================
whoami
echo.
echo =====================================================
echo   2) env USERNAME / USERDOMAIN
echo =====================================================
echo USERNAME=%USERNAME%
echo USERDOMAIN=%USERDOMAIN%
echo.
echo =====================================================
echo   3) รายชื่อ local user account ทั้งหมดในเครื่องนี้
echo =====================================================
net user
echo.
pause
