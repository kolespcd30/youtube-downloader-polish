@echo off
rem Copyright (c) 2026 koles_pcd
rem SPDX-License-Identifier: MIT
rem Licencja MIT - pelny tekst w pliku LICENSE.
setlocal
cd /d "%~dp0"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0Downloader.ps1"
pause
