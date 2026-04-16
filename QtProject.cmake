# The MIT License (MIT)
#
# Copyright (c) 2020-2021 Scott Aron Bloom
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sub-license, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

cmake_minimum_required(VERSION 3.31)

if( NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/Project.cmake" )
    message( FATAL_ERROR "Could not find '${CMAKE_CURRENT_LIST_DIR}/Project.cmake'" )
endif()
if( NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/QtCompilerSettings.cmake" )
    message( FATAL_ERROR "Could not find '${CMAKE_CURRENT_LIST_DIR}/QtCompilerSettings.cmake'" )
endif()

include( ${CMAKE_CURRENT_LIST_DIR}/Project.cmake )

MACRO(AddQtComponent whichLibVar component)
    if( ${whichLibVar} AND NOT Qt6${component}_FOUND )
        find_package( Qt6 COMPONENTS ${component} REQUIRED )
        add_definitions( -D${whichLibVar} )        
    endif()
endmacro()


AddQtComponent( TOWEL42_BIFSUPPORT Core )
AddQtComponent( TOWEL42_GIFSUPPORT Core )
AddQtComponent( TOWEL42_MKVUTILS Multimedia )
AddQtComponent( TOWEL42_ZIP_SUPPORT Core )

find_package(Qt6SrcMoc)

SET(CMAKE_AUTOMOC OFF)
SET(CMAKE_AUTORCC OFF)
SET(CMAKE_AUTOUIC OFF)

UNSET( qtproject_UIS_H )
UNSET( qtproject_MOC_SRCS )
UNSET( qtproject_CPPMOC_H )
UNSET( qtproject_QRC_SRCS )
if( Qt6_Widgets_FOUND )
    QT6_WRAP_UI(qtproject_UIS_H ${qtproject_UIS})

    if( DEFINED TOWEL42_MOC_OPTIONS )
        QT6_WRAP_CPP(qtproject_MOC_SRCS ${qtproject_H} OPTIONS ${TOWEL42_MOC_OPTIONS})
        TOWEL42_WRAP_SRCMOC(qtproject_CPPMOC_H ${qtproject_CPPMOC_SRCS} OPTIONS ${TOWEL42_MOC_OPTIONS})
    else()
        QT6_WRAP_CPP(qtproject_MOC_SRCS ${qtproject_H})
        TOWEL42_WRAP_SRCMOC(qtproject_CPPMOC_H ${qtproject_CPPMOC_SRCS})
    endif()
endif()

QT6_ADD_RESOURCES( qtproject_QRC_SRCS ${qtproject_QRC} )

source_group("Generated Files" FILES ${qtproject_UIS_H} ${qtproject_MOC_SRCS} ${qtproject_QRC_SRCS} ${qtproject_CPPMOC_H})
source_group("Resource Files"  FILES ${qtproject_QRC} ${qtproject_QRC_SOURCES} )
source_group("Designer Files"  FILES ${qtproject_UIS} )
source_group("Header Files"    FILES ${qtproject_H} )
source_group("Source Files"    FILES ${qtproject_CPPMOC_SRCS} )
source_group("Source Files"    FILES ${qtproject_SRCS} )

include( ${CMAKE_CURRENT_LIST_DIR}/QtCompilerSettings.cmake )

SET( _PROJECT_DEPENDENCIES
    ${_PROJECT_DEPENDENCIES}
    ${qtproject_SRCS} 
    ${qtproject_QRC} 
    ${qtproject_QRC_SRCS} 
    ${qtproject_UIS_H} 
    ${qtproject_MOC_SRCS} 
    ${qtproject_H} 
    ${qtproject_UIS}
    ${qtproject_QRC_SOURCES}
)

SET( project_pub_DEPS
     Qt6::Core
     ${project_pub_DEPS}
     )

SET( project_pri_DEPS
    # insert and "global default" qt private depends here
    ${project_pri_DEPS}
)
