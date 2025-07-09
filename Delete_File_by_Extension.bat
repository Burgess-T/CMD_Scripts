@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: Set multiple extensions to delete (space separated)
set /p "EXTENSIONS=Enter the file extension you want to delete: "

echo Recursively deleting all files with specified extensions (including hidden files)...
for %%e in (%EXTENSIONS%) do (
    echo Processing .%%e files...
    for /f "delims=" %%i in ('dir /s /b /a:-D *.%%e 2^>nul') do (
        attrib -h -s "%%i" >nul 2>&1
        del /f /q "%%i" >nul
        if exist "%%i" (
            echo Failed to delete file: "%%i"
        ) else (
            echo Deleted: "%%i"
        )
    )
)

echo Operation completed.
pause
exit /b