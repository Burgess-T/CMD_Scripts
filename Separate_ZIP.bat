@echo off
:: ------------------------------------------------------------------
:: Batch Compression Script with Source Deletion Option
::
:: Functionality:
:: 1. Compresses all folders in current directory using 7-Zip Zstandard
:: 2. Asks user whether to delete source folders after successful compression
:: 3. Shows real-time progress and success/failure status
:: 4. Only deletes source folders when:
::    - User confirms (Y)
::    - Compression completes successfully
::
:: Requirements:
:: - 7-Zip Zstandard installed at: D:\7-Zip-Zstandard\7z.exe
:: - Run from command prompt as administrator if deleting protected files
:: ------------------------------------------------------------------
setlocal enabledelayedexpansion

:ASK_USER
set /p "choice=Delete source folders after compression? (Y/N): "
if /i "!choice!"=="Y" goto COMPRESS
if /i "!choice!"=="N" goto COMPRESS
echo Invalid input. Please enter Y or N.
goto ASK_USER

:COMPRESS
for /d %%X in (*) do (
    echo Compressing: %%X...
    "D:\7-Zip-Zstandard\7z.exe" a "%%X.7z" "%%X\"
    
    if !errorlevel! equ 0 (
        echo  Success: %%X.7z created
        if /i "!choice!"=="Y" (
            rd /s /q "%%X" 2>nul
            echo  [Source deleted] %%X
        )
    ) else (
        echo  Error compressing: %%X
    )
    echo.
)
pause
endlocal