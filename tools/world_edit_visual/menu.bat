@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
title World Edit Visual
mode con: cols=110 lines=35 >nul 2>nul
cd /d "%~dp0\..\.."

:main_menu
cls
echo ========================================================
echo World Edit Visual
echo ========================================================
echo.
echo [1] Render all cases
echo [2] Render one case
echo [3] Create case
echo [4] Open output folder
echo [0] Exit
echo.
set /p action="Choose action: "

if "%action%"=="1" goto render_all
if "%action%"=="2" goto select_case
if "%action%"=="3" goto case_wizard
if "%action%"=="4" goto open_output
if "%action%"=="0" exit /b 0
goto main_menu

:render_all
cls
echo Rendering all cases.
echo This window shows short status only.
echo.
py -3 -u tools\world_edit_visual\scripts\render_workflow.py
echo.
set "rc=%ERRORLEVEL%"
if "%rc%"=="0" (
    echo Render completed successfully.
) else (
    echo Render failed. Exit code: %rc%
)
echo Details: tools\world_edit_visual\workflow.log
echo Index: tools\world_edit_visual\index.md
pause
goto main_menu

:case_wizard
cls
py -3 -u tools\world_edit_visual\scripts\case_wizard.py
echo.
set "rc=%ERRORLEVEL%"
if "%rc%"=="0" (
    echo Case wizard completed.
) else (
    echo Case wizard failed. Exit code: %rc%
)
pause
goto main_menu

:open_output
if not exist "tools\world_edit_visual\out" mkdir "tools\world_edit_visual\out"
start "" "tools\world_edit_visual\out"
goto main_menu

:select_case
cls
echo ========================================================
echo Select Case
echo ========================================================
echo.
set count=0
for /r tools\world_edit_visual\cases %%f in (*.json) do (
    set /a count+=1
    set "case_path[!count!]=%%f"
    echo [!count!] %%~nf
)
echo.
echo [0] Back
echo.
set /p case_choice="Choose case: "
if "%case_choice%"=="0" goto main_menu

set "selected_path=!case_path[%case_choice%]!"
if "!selected_path!"=="" (
    echo Invalid selection.
    pause
    goto select_case
)

cls
echo Rendering selected case:
echo !selected_path!
echo This window shows short status only.
echo.
py -3 -u tools\world_edit_visual\scripts\render_workflow.py --case-path "!selected_path!"
echo.
set "rc=!ERRORLEVEL!"
if "!rc!"=="0" (
    echo Render completed successfully.
) else (
    echo Render failed. Exit code: !rc!
)
echo Details: tools\world_edit_visual\workflow.log
echo Index: tools\world_edit_visual\index.md
pause
goto main_menu
