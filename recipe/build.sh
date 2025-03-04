#!/bin/sh

# Add path for wanted dependencies
for l in \
    assimp \
    bullet \
    ffmpeg \
    fftw \
    fltk \
    freetype \
    harfbuzz \
    jpeg \
    mimalloc \
    ode \
    openal \
    openssl \
    opus \
    png \
    python \
    swresample \
    swscale \
    tiff \
    vorbis \
    wx \
    zlib
do
    export ADDITIONAL_OPTIONS=--$l-incdir\ $PREFIX/include\ $ADDITIONAL_OPTIONS
    export ADDITIONAL_OPTIONS=--$l-libdir\ $PREFIX/lib\ $ADDITIONAL_OPTIONS
done
# Special treatment for eigen MAYBE OTHER FROM THE LIST ABOVE
export ADDITIONAL_OPTIONS=--eigen-incdir\ $PREFIX/include/eigen3\ $ADDITIONAL_OPTIONS
# Exclude unwanted dependencies
for l in \
    egl \
    gles \
    gles2 \
    opencv
do
    export ADDITIONAL_OPTIONS=--no-$l\ $ADDITIONAL_OPTIONS
done

# Build panda using special panda3d tool
$PYTHON makepanda/makepanda.py \
    --wheel \
    --threads=${CPU_COUNT} \
    --outputdir=build \
    --everything \
    --verbose \
    $ADDITIONAL_OPTIONS

# Install wheel which install python site-package and binaries
$PYTHON -m pip install panda3d*.whl -vv

# Manual installation of other elements
cd build

# Install /lib
mkdir $PREFIX/lib || true
for file in lib/*.*; do
  if [ -f "$file" ]; then
    cp "$file"                       $PREFIX/lib
  fi
done

# Install /etc
# Etc that are created by installpanda.py and not yet manually handled
# - etc/ld.so.conf.d/panda3d.conf
mkdir $PREFIX/etc || true
mkdir $PREFIX/etc/panda3d
cp -r etc/*                          $PREFIX/etc/panda3d

# Install /include
mkdir $PREFIX/include || true
mkdir $PREFIX/include/panda3d
cp -r include/*                      $PREFIX/include/panda3d

# Make /share
# Shares that are created by installpanda.py and not yet manually handled
# - share/application-registry/panda3d.applications
# - share/applications/pview.desktop
# - share/mime/packages/panda3d.xml
# - share/mime-info/panda3d.keys
# - share/mime-info/panda3d.mime
mkdir $PREFIX/share/panda3d
rsync -a direct                      $PREFIX/share/panda3d
rsync -a models                      $PREFIX/share/panda3d
rsync -a pandac                      $PREFIX/share/panda3d
rsync -a plugins                     $PREFIX/share/panda3d
rsync -a ../samples                  $PREFIX/share/panda3d
cp ReleaseNotes                      $PREFIX/share/panda3d
cp LICENSE                           $PREFIX/share/panda3d

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/scripts/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
