cmake_minimum_required(VERSION 3.22)

project( T42-CMakeUtils )

FILE(GLOB _CMAKE_SUPPORT_FILES "${CMAKE_CURRENT_SOURCE_DIR}/*" "${CMAKE_CURRENT_SOURCE_DIR}/Modules/*")

source_group("CMake Files" FILES ${_CMAKE_SUPPORT_FILES} )

add_library( CMakeSupport INTERFACE ${_CMAKE_SUPPORT_FILES} )
   
