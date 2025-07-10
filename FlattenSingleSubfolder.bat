REM =====================================================================
REM 功能说明：
REM   1. 检索当前目录下的所有一级子文件夹
REM   2. 对于每个子文件夹：
REM       - 检查内部是否只有一个项目（排除"."和".."）
REM       - 确认该项目是一个子文件夹（不是文件）
REM   3. 当条件满足时：
REM       a. 将子文件夹内的所有内容移动到父文件夹
REM       b. 删除已清空的子文件夹
REM 注意事项：
REM   - 仅处理当前目录的直接子文件夹（非递归）
REM   - 会处理隐藏文件和系统文件
REM   - 移动操作将覆盖同名文件（自动确认）
REM   - 空文件夹不会被处理
REM 使用示例：
REM   将此脚本放在目标目录中，双击运行
REM =====================================================================

@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for /d %%A in (*) do (
    set "folder=%%A"
    set "count=0"
    set "subfolder="
    
    pushd "%%A"
    for /f "delims=" %%B in ('dir /b /a 2^>nul') do (
        if not "%%B"=="." if not "%%B"==".." (
            set /a "count+=1"
            set "subfolder=%%B"
        )
    )
    
    if !count! equ 1 (
        if exist "!subfolder!\" (
            move /y "!subfolder!\*" . >nul 2>&1
            rd "!subfolder!"
            echo 已处理: "!folder!"
        )
    )
    popd
)

echo 操作完成
pause
endlocal