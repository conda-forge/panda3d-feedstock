setlocal EnableDelayedExpansion

if not defined PANDA_PRC_DIR exit 1

cd test
mkdir build

:: Compile basic example that links panda3d
cd build
cmake -GNinja -DCMAKE_BUILD_TYPE=Release ..
if errorlevel 1 exit 1

cmake --build . --config Release
if errorlevel 1 exit 1
