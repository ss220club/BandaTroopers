@echo off
setlocal
chcp 65001 >nul
title World Edit Visual
cd /d "%~dp0\..\..\.."

py -3 -u tools\world_edit_visual\scripts\watch_cases.py
exit /b %ERRORLEVEL%
