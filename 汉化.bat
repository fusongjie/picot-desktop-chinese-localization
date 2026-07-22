@echo off
setlocal enabledelayedexpansion

:: -- 检测可用的 PowerShell --
set "_ps="
where pwsh >nul 2>&1
if !errorlevel! equ 0 (
    set "_ps=pwsh"
) else (
    where powershell >nul 2>&1
    if !errorlevel! equ 0 (
        set "_ps=powershell"
    ) else (
        echo [错误] 未找到 PowerShell，请安装 PowerShell 7 或更高版本。
        pause
        exit /b 1
    )
)

:menu
cls
echo =============================================
echo  Picot Desktop GUI 汉化工具
echo =============================================
echo.
echo [1] 执行汉化
echo [2] 预览（不修改）
echo [3] 还原英文版
echo [4] 退出
echo.
set /p "choice=请选择 (1-4): "

:: 去除输入中的空格
set "choice=%choice: =%"

if "%choice%"=="1" (
    echo.
    echo 正在汉化...
    !_ps! -NoProfile -ExecutionPolicy Bypass -File "%~dp0picot-han.ps1"
    echo.
    pause
    goto :menu
)
if "%choice%"=="2" (
    echo.
    echo 正在预览...
    !_ps! -NoProfile -ExecutionPolicy Bypass -File "%~dp0picot-han.ps1" -Check
    echo.
    pause
    goto :menu
)
if "%choice%"=="3" (
    echo.
    echo 正在还原...
    !_ps! -NoProfile -ExecutionPolicy Bypass -File "%~dp0picot-han.ps1" -Reset
    echo.
    pause
    goto :menu
)
if "%choice%"=="4" (
    endlocal
    exit /b
)

echo.
echo [无效输入，请输入 1-4]
pause
goto :menu
