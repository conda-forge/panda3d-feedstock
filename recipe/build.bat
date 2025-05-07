set ADDITIONAL_OPTIONS=

:: Add path for wanted dependencies
for %%l in (^
    assimp ^
    bullet ^ 
    ffmpeg ^
    fltk ^
    freetype ^
    harfbuzz ^
    jpeg ^
    mimalloc ^
    ode ^
    openal ^
    openssl ^
    png ^
    python ^
    swresample ^
    swscale ^
    tiff ^
    vorbis ^
    wx ^
    zlib) do (
    call set "ADDITIONAL_OPTIONS= --%%l-incdir=%LIBRARY_INC% %%ADDITIONAL_OPTIONS%%"
    call set "ADDITIONAL_OPTIONS= --%%l-libdir=%LIBRARY_LIB% %%ADDITIONAL_OPTIONS%%"
)
:: Special treatment for eigen
set ADDITIONAL_OPTIONS= --eigen-incdir=%LIBRARY_INC%\eigen3 %ADDITIONAL_OPTIONS%
:: Exclude dependencies missing on conda
for %%l in (^
    artoolkit ^
    fcollada ^
    fmodex ^
    gles ^
    gles2 ^
    nvidiacg ^
    opencv ^
    opus ^
    rocket ^
    squish ^
    vrpn) do (
    call set "ADDITIONAL_OPTIONS=--no-%%l %%ADDITIONAL_OPTIONS%%"
)

:: Build panda using special panda3d tool
:: Use vs2019 compiler (msvc_version 14.2)
%PYTHON% makepanda/makepanda.py ^
    --threads=%CPU_COUNT% ^
    --outputdir=build ^
    --everything ^
    --verbose ^
    --msvc-version=14.2 ^
    --windows-sdk=10 ^
    %ADDITIONAL_OPTIONS%
if errorlevel 1 exit 1

cd build

:: Install site-packages
mkdir %SP_DIR%\panda3d
robocopy panda3d %SP_DIR%\panda3d /E >nul
mkdir %SP_DIR%\direct
robocopy direct %SP_DIR%\direct /E >nul

:: Install bin & lib in sysroot-folder
robocopy bin %LIBRARY_BIN% /E >nul
robocopy lib %LIBRARY_LIB% /E >nul

:: Install etc
mkdir %LIBRARY_PREFIX%\etc\panda3d
robocopy etc %LIBRARY_PREFIX%\etc\panda3d /E >nul

:: Install headers
mkdir %LIBRARY_INC%\panda3d
robocopy include %LIBRARY_INC%\panda3d /E >nul

:: Install share
mkdir %LIBRARY_PREFIX%\share\panda3d\models
robocopy models %LIBRARY_PREFIX%\share\panda3d\models /E >nul

mkdir %LIBRARY_PREFIX%\share\panda3d\pandac
robocopy pandac %LIBRARY_PREFIX%\share\panda3d\pandac /E >nul

mkdir %LIBRARY_PREFIX%\share\panda3d\plugins
robocopy plugins %LIBRARY_PREFIX%\share\panda3d\plugins /E >nul

mkdir %LIBRARY_PREFIX%\share\panda3d\samples
robocopy ..\samples %LIBRARY_PREFIX%\share\panda3d\samples /E >nul

copy ReleaseNotes %LIBRARY_PREFIX%\share\panda3d\
copy LICENSE %LIBRARY_PREFIX%\share\panda3d\

:: Copy the [de]activate scripts to %PREFIX%\etc\conda\[de]activate.d.
:: This will allow them to be run on environment activation.
for %%F in (activate deactivate) DO (
  if not exist %PREFIX%\etc\conda\%%F.d mkdir %PREFIX%\etc\conda\%%F.d
  copy %RECIPE_DIR%\scripts\%%F.bat %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.bat
  :: Copy unix shell activation scripts, needed by Windows Bash users
  copy %RECIPE_DIR%\scripts\%%F.sh %PREFIX%\etc\conda\%%F.d\%PKG_NAME%_%%F.sh
)
