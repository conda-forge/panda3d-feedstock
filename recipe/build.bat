set ADDITIONAL_OPTIONS=

:: Add path for wanted dependencies
for %%l in (^
    assimp ^
    bullet ^
    ffmpeg ^
    freetype ^
    jpeg ^
    openal ^
    openssl ^
    png ^
    python ^
    tiff ^
    vorbis ^
    zlib) do (
    call set "ADDITIONAL_OPTIONS= --%%l-incdir=%LIBRARY_INC% %%ADDITIONAL_OPTIONS%%"
    call set "ADDITIONAL_OPTIONS= --%%l-libdir=%LIBRARY_LIB% %%ADDITIONAL_OPTIONS%%"
)

:: Special treatment for eigen
set ADDITIONAL_OPTIONS= --eigen-incdir %LIBRARY_INC%\eigen3 %ADDITIONAL_OPTIONS%

:: Disable certain options
for %%l in (^
    nvidiacg ^
    egl ^
    gles ^
    gles2) do (
    call set "ADDITIONAL_OPTIONS=--no-%%l %%ADDITIONAL_OPTIONS%%"
)

:: Make panda using special panda3d tool
:: Use vs2019 compiler (msvc_version 14.2)
%PYTHON% makepanda/makepanda.py --threads=2 --outputdir=build --wheel --everything --msvc-version=14.2 --windows-sdk=10 %ADDITIONAL_OPTIONS%
if errorlevel 1 exit 1

:: Install wheel which install python, bin
:: On Windows the wildcard must be unfold manually
for %%f in (panda3d*.whl) do (
    %PYTHON% -m pip install %%f -vv
)
if errorlevel 1 exit 1

cd build

:: Install lib in sysroot-folder
robocopy lib %LIBRARY_LIB% /E >nul

:: Make etc 
mkdir %LIBRARY_PREFIX%\etc\panda3d
robocopy etc %LIBRARY_PREFIX%\etc\panda3d /E >nul

:: Install headers
mkdir %LIBRARY_INC%\panda3d
robocopy include %LIBRARY_INC%\panda3d /E >nul

:: Make share
mkdir %LIBRARY_PREFIX%\share\panda3d\models
robocopy models %LIBRARY_PREFIX%\share\panda3d\models /E >nul

mkdir %LIBRARY_PREFIX%\share\panda3d\plugins
robocopy plugins %LIBRARY_PREFIX%\share\panda3d\plugins /E >nul

copy ReleaseNotes %LIBRARY_PREFIX%\share\panda3d\
copy LICENSE %LIBRARY_PREFIX%\share\panda3d\
