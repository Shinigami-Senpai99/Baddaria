@echo off
setlocal enabledelayedexpansion

rem Ensure all arguments are properly handled
set CONFIG=%~1
set DLL_DIR=%~2
set OUTPUT_DIR=%~3

rem Debugging: Display the received arguments
echo CONFIG: %CONFIG%
echo DLL_DIR: %DLL_DIR%
echo OUTPUT_DIR: %OUTPUT_DIR%

rem Create output directory if it doesn't exist
if not exist "%OUTPUT_DIR%" (
    mkdir "%OUTPUT_DIR%"
)

rem Iterate through all DLLs
for %%f in ("%DLL_DIR%\sfml-*-3.dll") do (
    echo Processing: %%~nxf
    if "%CONFIG%"=="Debug" (
        echo Debug build detected.
        echo Checking for Debug DLL: %%~nxf
        echo %%~nxf | find "-d-3.dll" >nul
        if not errorlevel 1 (
            echo Copying %%~nxf to "%OUTPUT_DIR%"...
            copy "%%f" "%OUTPUT_DIR%" >nul
        )
    ) else (
        echo Release build detected.
        echo Checking for Release DLL: %%~nxf
        echo %%~nxf | find "-d-3.dll" >nul
        if errorlevel 1 (
            echo Copying %%~nxf to "%OUTPUT_DIR%"...
            copy "%%f" "%OUTPUT_DIR%" >nul
        )
    )
)

echo All relevant DLLs have been copied.
exit /b 0
