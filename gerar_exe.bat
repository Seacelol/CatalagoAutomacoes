@echo off
chcp 65001 >nul
setlocal
cd /d "%~dp0"

rem ==================================================================
rem  Gera CatalogoAutomacoes.exe a partir de catalogo_automacoes.py
rem  Coloque este .bat na mesma pasta do .py (e do icone.ico, se tiver)
rem  Requisito na maquina que gera: Python 3.10+ 64 bits no PATH
rem ==================================================================

where python >nul 2>nul || (echo Python nao encontrado no PATH. & goto erro)

echo.
echo [1/4] Criando ambiente limpo...
if exist .venv-build rmdir /s /q .venv-build
python -m venv .venv-build || goto erro
call .venv-build\Scripts\activate.bat

echo.
echo [2/4] Instalando dependencias...
python -m pip install --upgrade pip >nul
pip install PySide6-Essentials openpyxl pyinstaller pillow || goto erro

echo.
echo [3/4] Gerando o executavel...
set ICON_ARGS=
if exist icone.ico set ICON_ARGS=--icon=icone.ico --add-data "icone.ico;."
pyinstaller --noconfirm --clean --onefile --windowed --name CatalogoAutomacoes %ICON_ARGS% ^
    --exclude-module tkinter --exclude-module unittest ^
    catalogo_automacoes.py || goto erro

echo.
echo [4/4] Finalizando...
if exist config.json copy /y config.json dist\ >nul
call deactivate
rmdir /s /q build .venv-build 2>nul
del /q CatalogoAutomacoes.spec 2>nul

echo.
echo Pronto: %~dp0dist\CatalogoAutomacoes.exe
explorer dist
pause
exit /b 0

:erro
echo.
echo Falha ao gerar o executavel. Veja a mensagem acima.
pause
exit /b 1
