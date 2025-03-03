#!/bin/sh
# Add path for wanted dependencies
for l in \
    assimp \
    bullet \
    ffmpeg \
    freetype \
    jpeg \
    openal \
    openssl \
    png \
    python \
    tiff \
    vorbis \
    zlib \
    harfbuzz \
    opus
do
    export ADDITIONAL_OPTIONS=--$l-incdir\ $PREFIX/include\ $ADDITIONAL_OPTIONS
    export ADDITIONAL_OPTIONS=--$l-libdir\ $PREFIX/lib\ $ADDITIONAL_OPTIONS
done
# Special treatment for eigen
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

# Make panda using special panda3d tool
$PYTHON makepanda/makepanda.py \
    --threads=${CPU_COUNT} \
    --outputdir=build \
    --everything \
    --verbose \
    $ADDITIONAL_OPTIONS

# Install wheel which install python, bin
$PYTHON -m pip install panda3d*.whl -vv

cd build

# Install lib in sysroot-folder
# Too brutal and wrong
rsync -a lib                  $PREFIX

# Make etc
mkdir $PREFIX/etc || true
mkdir $PREFIX/etc/panda3d
cp -r etc/*                   $PREFIX/etc/panda3d

# Install headers
mkdir $PREFIX/include || true
mkdir $PREFIX/include/panda3d
cp -r include/*               $PREFIX/include/panda3d

# Make share
# # Shares that are created by installpanda.py and not yet manually handled
# share/application-registry/panda3d.applications
# share/applications/pview.desktop
# share/mime/packages/panda3d.xml
# share/mime-info/panda3d.keys
# share/mime-info/panda3d.mime

mkdir $PREFIX/share/panda3d
rsync -a direct               $PREFIX/share/panda3d
rsync -a models               $PREFIX/share/panda3d
rsync -a pandac               $PREFIX/share/panda3d
rsync -a plugins              $PREFIX/share/panda3d
rsync -a samples              $PREFIX/share/panda3d
cp ReleaseNotes               $PREFIX/share/panda3d
cp LICENSE                    $PREFIX/share/panda3d

# Copy the [de]activate scripts to $PREFIX/etc/conda/[de]activate.d.
# This will allow them to be run on environment activation.
for CHANGE in "activate" "deactivate"
do
    mkdir -p "${PREFIX}/etc/conda/${CHANGE}.d"
    cp "${RECIPE_DIR}/${CHANGE}.sh" "${PREFIX}/etc/conda/${CHANGE}.d/${PKG_NAME}_${CHANGE}.sh"
done
