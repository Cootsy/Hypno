@echo off
setlocal enabledelayedexpansion

:: ==========================================
:: CONFIGURATION SECTION
:: ==========================================
:: Define your single target destination folder
set "DEST_DIR=C:\Users\damia\AppData\Roaming\.minecraft\figura\avatars\Hypno"
set "my_dir=%CD%"
set "SOURCE_DIR=%my_dir%"

:: Ensure the destination folder exists
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

:: ==========================================
:: STEP 1: COPY SPECIFIC FOLDERS
:: ==========================================
echo Copying folders...

:: Folder 1: Copies all contents and subfolders (/E) Exclude existing files (/XO) retry 2 times (/R:2) wait 5 seconds between retries (/W:5)
ROBOCOPY "%SOURCE_DIR%\models" "%DEST_DIR%\models" /E /XO /R:2 /W:5

:: Folder 2: Repeat the command for as many folders as you need
ROBOCOPY "%SOURCE_DIR%\scripts" "%DEST_DIR%\scripts" /E /XO /R:2 /W:5

:: Folder 3: Repeat the command for as many folders as you need
ROBOCOPY "%SOURCE_DIR%\sounds" "%DEST_DIR%\sounds" /E /XO /R:2 /W:5

:: Folder 4: Repeat the command for as many folders as you need
ROBOCOPY "%SOURCE_DIR%\textures" "%DEST_DIR%\textures" /E /XO /R:2 /W:5


:: ==========================================
:: STEP 2: COPY SPECIFIC FILES
:: ==========================================
echo Copying individual files...

:: File 1: Single file copy
robocopy "%SOURCE_DIR%" "%DEST_DIR%" "_CREDITS.txt" /XO /NJH /NJS /NC /NS /NP
:: File 2: Single file copy
robocopy "%SOURCE_DIR%" "%DEST_DIR%" "_READ_ME.txt" /XO /NJH /NJS /NC /NS /NP
:: File 3: Single file copy
robocopy "%SOURCE_DIR%" "%DEST_DIR%" "avatar.json" /XO /NJH /NJS /NC /NS /NP
:: File 4: Single file copy
robocopy "%SOURCE_DIR%" "%DEST_DIR%" "avatar.png" /XO /NJH /NJS /NC /NS /NP
:: File 4: Single file copy
robocopy "%SOURCE_DIR%" "%DEST_DIR%" "config.lua" /XO /NJH /NJS /NC /NS /NP

:: ==========================================
:: FINISH
:: ==========================================
echo Done! All items have been consolidated.
pause