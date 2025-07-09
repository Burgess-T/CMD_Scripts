@REM ===============================================================
@REM 处理规则：
@REM   1. 如果父文件夹下只有一个子文件夹且没有其他文件
@REM   2. 则将子文件夹下的所有内容移动到父文件夹
@REM   3. 删除原子文件夹
@REM 注意事项：
@REM   - 脚本会修改目录结构，操作不可逆
@REM   - 需要以管理员身份运行才能处理系统/隐藏文件
@REM   - 支持包含空格和特殊字符的文件名
@REM ===============================================================

@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

for %%I in ("%cd%") do set "start_dir=%%~fI"
:: 从当前目录开始深度优先遍历
call :recurse_folder "%start_dir%"

echo Operation completed.
pause
exit /b

:recurse_folder
set "current_dir=%~1"
pushd "%current_dir%" || exit /b

set "abs_path=%CD%"

:: 先递归处理所有子文件夹（深度优先）
for /f "delims=" %%b in ('dir /ad /b 2^>nul') do (
    call :recurse_folder "%%b"
)

:: 处理当前文件夹
set folder_count=0
set file_count=0
set child_folder=

:: 计数当前目录内容
for /f "delims=" %%c in ('dir /a /b 2^>nul') do (
    if exist "%%c\" (
        set /a folder_count+=1
        set "child_folder=%%c"
    ) else (
        set /a file_count+=1
    )
)

:: 检查合并条件
if !folder_count! equ 1 if !file_count! equ 0 (
    echo "Merging folder: "!abs_path!""
    robocopy "!child_folder!" "." /E /MOVE /NFL /NDL /NJH /NJS >nul 2>&1
)

popd
goto :eof