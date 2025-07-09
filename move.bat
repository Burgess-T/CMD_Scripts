@echo off
setlocal enabledelayedexpansion

@REM 将当前目录下所有子文件夹中的文件移动到脚本所在目录
@REM 显示包含嵌套子文件夹的目录
@REM 删除所有空文件夹
@REM 脚本只处理一级子文件夹（不会递归处理更深层的文件夹）
@REM 系统文件和隐藏文件不会被移动
@REM 文件名冲突时自动添加数字后缀（如file.txt → file_1.txt）

:: 获取脚本所在目录
set "root_dir=%~dp0"
set "has_subfolders_list="

echo 正在扫描目录结构...
echo ------------------------------

:: 第一阶段：列出包含子文件夹的目录
for /d %%d in ("%root_dir%*") do (
    dir /ad /b "%%d" 2>nul | findstr . >nul
    if not errorlevel 1 (
        echo [包含子文件夹] %%~nxd
        set "has_subfolders_list=!has_subfolders_list!%%~nxd,"
    )
)

echo ------------------------------
echo 开始移动文件...
echo.

:: 第二阶段：移动文件并处理冲突
set file_count=0
for /d %%d in ("%root_dir%*") do (
    pushd "%%d"
    for /f "delims=" %%f in ('dir /b /a-d 2^>nul') do (
        set /a file_count+=1
        if exist "%root_dir%%%f" (
            set "counter=1"
            set "filename=%%~nf"
            set "ext=%%~xf"
            
            :rename_loop
            set "newfile=!filename!_!counter!!ext!"
            if exist "%root_dir%!newfile!" (
                set /a counter+=1
                goto :rename_loop
            )
            move "%%f" "%root_dir%!newfile!" >nul
            echo 移动: %%~nxf --^> !newfile!
        ) else (
            move "%%f" "%root_dir%%%f" >nul
            echo 移动: %%~nxf
        )
    )
    popd
)

echo ------------------------------
echo 正在清理空文件夹...

:: 第三阶段：删除空文件夹
set folder_count=0
for /d %%d in ("%root_dir%*") do (
    rmdir "%%d" 2>nul && (
        echo 删除: %%~nxd
        set /a folder_count+=1
    )
)

echo ------------------------------
echo 操作完成!
echo.
echo 移动文件数量: %file_count%
echo 删除空文件夹: %folder_count%
echo.

:: 显示包含子文件夹的目录列表
if defined has_subfolders_list (
    echo 包含子文件夹的目录:
    set "temp_list=%has_subfolders_list%"
    :display_loop
    for /f "delims=, tokens=1*" %%a in ("!temp_list!") do (
        echo   - %%a
        set "temp_list=%%b"
    )
    if defined temp_list goto :display_loop
) else (
    echo 没有包含子文件夹的目录
)

echo.
pause