cmake_minimum_required(VERSION 3.15)

# The entire purpose of this project is to test a correct installation of
# panda3d, by linking a simple executable against it.
project(Panda3dTestConda)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}")

find_package(Panda3d REQUIRED)
find_package(Eigen3 REQUIRED CONFIG)

add_executable(TestExe test.cpp)
target_link_libraries(TestExe PUBLIC 
  Eigen3::Eigen
  panda3d::panda
  panda3d::pandaexpress
  panda3d::p3dtoolconfig
  panda3d::p3dtool
  panda3d::p3framework)
