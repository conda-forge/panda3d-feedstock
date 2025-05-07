# Find the panda3d headers and libraries
#
# Defines:
#   Panda3d_FOUND : True if panda3d (all libraries) is found
#   Panda3d_INCLUDE_DIRS
#   Panda3D_LIBRARIES
#
# Provides targets 
#   panda3d::panda
#   panda3d::p3framework
#   panda3d::pandaexpress
#   panda3d::p3dtoolconfig
#   panda3d::p3dtool
#   panda3d::p3direct
#   panda3d::pandaegg
#   panda3d::p3ffmpeg
#   panda3d::p3interrogatedb
#   panda3d::p3tinydisplay
#   panda3d::p3vision
#   panda3d::pandaai
#   panda3d::pandafx
#   panda3d::pandaphysics
#   panda3d::pandaskel

set(PANDA3D_LIBS
  panda p3framework pandaexpress
  p3dtoolconfig p3dtool p3direct
  pandaegg p3ffmpeg p3interrogatedb p3tinydisplay p3vision
  pandaai pandafx pandaphysics pandaskel
)

find_path(Panda3d_INCLUDE_DIRS panda3d/panda.h PATH_SUFFIXES include)

mark_as_advanced(Panda3d_INCLUDE_DIRS)

# Fetch all libraries
set(Panda3D_LIBRARIES "")
set(ALL_LIBS_FOUND TRUE)
foreach(lib_name ${PANDA3D_LIBS})
  find_library(Panda3d_${lib_name}_LIBRARY NAMES ${lib_name} PATH_SUFFIXES lib)
  if(NOT Panda3d_${lib_name}_LIBRARY)
    set(ALL_LIBS_FOUND FALSE)
  else()
    list(APPEND Panda3D_LIBRARIES ${Panda3d_${lib_name}_LIBRARY})
    add_library(panda3d::${lib_name} SHARED IMPORTED)
    set_property(TARGET panda3d::${lib_name} PROPERTY IMPORTED_LOCATION "${Panda3d_${lib_name}_LIBRARY}")
    if(WIN32)
      set_property(TARGET panda3d::${lib_name} PROPERTY IMPORTED_IMPLIB "${Panda3d_${lib_name}_LIBRARY}")
    endif()
    set_property(TARGET panda3d::${lib_name} PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${Panda3d_INCLUDE_DIRS}")
  endif()

  mark_as_advanced(Panda3d_${lib_name}_LIBRARY)
endforeach()


include(FindPackageHandleStandardArgs)
# Handle the QUIETLY and REQUIRED arguments and set the Panda3D_FOUND to TRUE
# if all listed variables are TRUE
find_package_handle_standard_args(Panda3d DEFAULT_MSG ALL_LIBS_FOUND Panda3d_INCLUDE_DIRS)
