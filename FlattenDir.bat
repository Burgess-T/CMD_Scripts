:: 将当前目录下所有子文件夹中的文件移动到脚本所在目录
:: 显示包含嵌套子文件夹的目录
:: 删除所有空文件夹
:: 脚本不会递归处理更深层的文件夹
:: 系统文件和隐藏文件不会被移动
:: 文件名冲突时自动添加数字后缀（如file.txt → file_1.txt）


@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion


:: Get script directory
set "root_dir=%~dp0"
set "has_subfolders_list="

echo Scanning directory structure...
echo ------------------------------

:: Phase 1: List directories containing subfolders
for /d %%d in ("%root_dir%*") do (
    dir /ad /b "%%d" 2>nul | findstr . >nul
    if not errorlevel 1 (
        echo [Has Subfolders] %%~nxd
        set "has_subfolders_list=!has_subfolders_list!%%~nxd,"
    )
)

echo ------------------------------
echo Starting file move operation...
echo.

:: Phase 2: Move files and handle conflicts
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
            echo Moved: %%~nxf --^> !newfile!
        ) else (
            move "%%f" "%root_dir%%%f" >nul
            echo Moved: %%~nxf
        )
    )
    popd
)

echo ------------------------------
echo Cleaning up empty folders...

:: Phase 3: Remove empty folders
set folder_count=0
for /d %%d in ("%root_dir%*") do (
    rmdir "%%d" 2>nul && (
        echo Deleted: %%~nxd
        set /a folder_count+=1
    )
)

echo ------------------------------
echo Operation completed!
echo.
echo Files moved: %file_count%
echo Folders deleted: %folder_count%
echo.

:: Display list of directories with subfolders
if defined has_subfolders_list (
    echo Directories containing subfolders:
    set "temp_list=%has_subfolders_list%"
    :display_loop
    for /f "delims=, tokens=1*" %%a in ("!temp_list!") do (
        echo   - %%a
        set "temp_list=%%b"
    )
    if defined temp_list goto :display_loop
) else (
    echo No directories contain subfolders
)

echo Operation completed.
pause
exit /b