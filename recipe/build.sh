#!/bin/sh

# Add path for wanted dependencies
for l in \
    assimp \
    bullet \
    ffmpeg \
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
# Exclude dependencies missing on conda
for l in \
    artoolkit \
    fcollada \
    fftw \
    fmodex \
    gtk2 \
    nvidiacg \
    rocket \
    squish \
    vrpn
do
    export ADDITIONAL_OPTIONS=--no-$l\ $ADDITIONAL_OPTIONS
done


# Build panda using special panda3d tool
$PYTHON makepanda/makepanda.py \
    --threads=${CPU_COUNT} \
    --outputdir=build \
    --everything \
    --verbose \
    $ADDITIONAL_OPTIONS

# Manual installation of other elements
cd build

# Fix install-name on darwin
if [[ "$target_platform" == osx-* ]]; then
  for file in lib/*.dylib bin/* panda3d/*.so direct/*.so; do
    if [[ $file == *".dylib" ]]; then
      install_name_tool -id @rpath/$(basename "$file") $file
    fi
    otool -L $file | tail -n +2 | tr -d '\t' | cut -d ' ' -f 1 > tmp_otool.txt
    while read linked; do
      if [[ $linked == "@loader_path/../lib"* ]]; then
        new_linked=$(echo "$linked" | sed "s/@loader_path\/..\/lib/@rpath/")
        install_name_tool -change $linked $new_linked $file
      fi
    done < tmp_otool.txt
  done
fi

# Install site-packages
cp -r panda3d $SP_DIR
cp -r direct $SP_DIR

# Install bin
cp -r bin/* $PREFIX/bin

# Install lib
mkdir $PREFIX/lib || true
for file in lib/*.*; do
  if [ -f "$file" ]; then
    cp "$file"                       $PREFIX/lib
  fi
done

# Install etc
# Etc that are created by installpanda.py and not yet manually handled
# - etc/ld.so.conf.d/panda3d.conf
mkdir $PREFIX/etc || true
mkdir $PREFIX/etc/panda3d
cp -r etc/*                          $PREFIX/etc/panda3d

# Install headers
mkdir $PREFIX/include || true
mkdir $PREFIX/include/panda3d
cp -r include/*                      $PREFIX/include/panda3d

# Install share
# Shares that are created by installpanda.py and not yet manually handled
# - share/application-registry/panda3d.applications
# - share/applications/pview.desktop
# - share/mime/packages/panda3d.xml
# - share/mime-info/panda3d.keys
# - share/mime-info/panda3d.mime
mkdir $PREFIX/share/panda3d
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
