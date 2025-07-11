@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Set multiple extensions to delete (space separated)
set /p "FILE_PATTERNS=Enter the filename pattern (e.g. test.txt, *.tmp): "

echo Recursively deleting all matching files (including hidden files)...

:: Build quoted patterns to prevent premature expansion
set "quoted_patterns="
for %%a in (%FILE_PATTERNS%) do (
    set "quoted_patterns=!quoted_patterns! "%%a""
)

for %%p in (!quoted_patterns!) do (
    set "pattern=%%~p"
    echo Processing pattern: "!pattern!"
    for /f "delims=" %%i in ('dir /s /b /a:-D "!pattern!" 2^>nul') do (
        attrib -h -s "%%i" >nul 2>&1
        del /f /q "%%i" >nul
        if exist "%%i" (
            echo Failed to delete: "%%i"
        ) else (
            echo Deleted: "%%i"
        )
    )
)

echo Operation completed.
pause
exit /b