@echo off
setlocal enabledelayedexpansion

REM Default PATH: "C:\Program Files\7-Zip\7z.exe" (DO NOT ADD TO WINDOWS PATH VARIABLES)
set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"

set "DB_host=%~1"
set "DB_user=%~2"
set "DB_pass=%~3"
set "DB=%~4"
set "DIR=%~5"

if "!DB_host!"=="" set /p DB_host=Enter DB_HOST:
if "!DB_user!"=="" set /p DB_user=Enter DB_USER:
if "!DB_pass!"=="" set /p DB_pass=Enter DB_PASSWORD:
if "!DB!"=="" set /p DB=Enter DB_NAME:

echo Default directory will be a folder in the same place as the .bat file with the format "YYYY-MM-DD DatabaseName HH.MM.SS"
if "!DIR!"=="" set /p DIR=Enter output directory (default is .):

REM If DIR is . or empty, set to "YYYY-MM-DD DatabaseName HH:MM:SS" at batch location
if "!DIR!"=="" set "DIR=."
if "!DIR!"=="." (
    for /f "tokens=1-3 delims=/- " %%a in ("!date!") do (
        set "YYYY=%%c"
        set "MM=%%b"
        set "DD=%%a"
    )
    for /f "tokens=1-3 delims=:." %%h in ("!time!") do (
        set "HH=%%h"
        set "MI=%%i"
        set "SS=%%j"
    )
    REM Windows does not allow ":" in folder names, so replace ":" with "." for the folder name
    set "DIR=%~dp0!YYYY!-!MM!-!DD! !DB! !HH!.!MI!.!SS!"
)

if not exist "!DIR!" mkdir "!DIR!"

echo.
echo Dumping tables into separate SQL command files for database '!DB!' into dir=!DIR!

set tbl_count=0

for /f "delims=" %%t in ('mysql -NBA -h !DB_host! -u !DB_user! -p!DB_pass! -D !DB! -e "show tables"') do (
    echo DUMPING TABLE: !DB!.%%t
    mysqldump --no-tablespaces --column-statistics=0 -h !DB_host! -u !DB_user! -p!DB_pass! !DB! %%t > "!DIR!\!DB!.%%t.sql"
    "!SEVENZIP!" a -tgzip "!DIR!\!DB!.%%t.sql.gz" "!DIR!\!DB!.%%t.sql" >nul
    del "!DIR!\!DB!.%%t.sql"
    set /a tbl_count+=1
)

echo !tbl_count! tables dumped from database '!DB!' into dir=!DIR!
endlocal
pause
