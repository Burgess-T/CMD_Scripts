:: ========================================================================
:: Batch ZIP Extraction Tool
:: 
:: 功能说明：
::   1. 递归遍历所有子文件夹中的加密压缩文件
::   2. 支持带密码的加密压缩包（统一密码）
::   3. 生成解压文件夹
::
:: 使用说明：
::   1. 确保7-Zip路径正确（默认：D:\7-Zip-Zstandard\7z.exe）
::   2. 双击运行脚本
::   3. 选择是否创建同名文件夹存放解压内容
::   4. 输入统一的解压密码
::   5. 等待自动处理完成
:: ========================================================================

@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul & reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul

:: Configure 7-Zip path
set "sevenzip=D:\7-Zip-Zstandard\7z.exe"

if not exist "%sevenzip%" (
    echo [Error] Invalid 7z.exe path
    pause
    exit /b
)

:: Count total archive files
set file_count=0
for /r %%d in (*.rar;*.7z) do set /a file_count+=1
if %file_count% equ 0 (
    echo No ZIP files found
    pause
    exit /b
)
echo Total files: %file_count%

:: Ask user for options
set /p "folder_option=Create folder with archive name? (y/n): "
set /p "delete_option=Delete ZIP file after the progress? (y/n): "
set /p "password=Enter extraction password: "

:: Start timer
set "start_time=%time%"
echo Start time: %start_time%

:: Progress counter
set current=0
for /r %%d in (*.rar;*.7z) do (
    set /a current+=1
    
    :: Red progress display
    <nul set /p=[31m[!current!/%file_count%][0m 
    echo Processing: %%~d

    :: Set unzip folder path
    set "target_path=%%~dpd\"
    if /i "!folder_option!"=="y" (
        set "target_path=%%~dpnd"
        mkdir "!target_path!" >nul 2>&1
    )
    
    "%sevenzip%" x "%%~d" -p"%password%" -o"!target_path!" -y -bse0 > nul && (
        echo [Success] Extraction completed
    )

    :: Delete file
    if /i "!delete_option!"=="y" (
        del "%%~d"
    )
)

:: Calculate elapsed time
call :time_diff "%start_time%" "%time%" total_time
echo Total time: %total_time%
echo Processing completed!
pause
exit /b

:time_diff
setlocal
set "start=%~1"
set "end=%~2"
set /a start_h=1%start:~0,2%%%100, start_m=1%start:~3,2%%%100, start_s=1%start:~6,2%%%100
set /a end_h=1%end:~0,2%%%100, end_m=1%end:~3,2%%%100, end_s=1%end:~6,2%%%100
set /a diff=(end_h*3600 + end_m*60 + end_s) - (start_h*3600 + start_m*60 + start_s)
set /a hh=diff/3600, mm=(diff%%3600)/60, ss=diff%%60
set "total_time="
if %hh% gtr 0 set "total_time=%hh% hours"
if %mm% gtr 0 set "total_time=%total_time% %mm% minutes"
set "total_time=%total_time% %ss% seconds"
endlocal & set "%3=%total_time%"