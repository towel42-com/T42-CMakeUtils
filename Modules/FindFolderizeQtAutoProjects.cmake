# The MIT License (MIT)
#
# Copyright (c) 2025 Scott Aron Bloom
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

message( FATAL_ERROR "Do not use, instead add
    find_package(Qt6 REQUIRED)
    SET_PROPERTY(GLOBAL PROPERTY QT_TARGETS_FOLDER CMakePredefinedTargets/QtInternalTargets)
    qt_standard_project_setup()
    
    To your primary CMakeLists.txt after the find_package( Qt ) call" )
#cmake_minimum_required(VERSION 3.31)
#find_package( FindAllDirectories REQUIRED )

#function( FolderizeQtAutoProjects )
#    set( options "")
#    set( oneValueArgs FOLDER_NAME TOPDIR )
#    set( multiValueArgs )
#
#    cmake_parse_arguments(PARSE_ARGV 0 arg
#        "${options}" "${oneValueArgs}" "${multiValueArgs}"
#    )
#
#    if ( NOT arg_TOPDIR )
#        SET( arg_TOPDIR ${CMAKE_SOURCE_DIR} )
#    endif()
#
#    if ( NOT arg_FOLDER_NAME )
#        SET( arg_FOLDER_NAME QtAutoProjects )
#    endif()
#    
#    message( STATUS "Searching for Qt Auto Projects in=${arg_TOPDIR}" )
#    FindAllDirectories(${arg_TOPDIR} _ALLDIRS )
#    #message( STATUS "BUILDSYSTEM_TARGETS=${BUILDSYSTEM_TARGETS}" )
# 
#    foreach( dir ${_ALLDIRS} )
#        #MESSAGE( STATUS "dir=${dir}" )
#        get_property(targets DIRECTORY ${dir} PROPERTY "BUILDSYSTEM_TARGETS")
#        #MESSAGE( STATUS "targets=${targets}" )
#        set( _suffixes _qmlimportscan _other_files autogen _automoc_json_extraction qt_internal_plugins)
#        STRING( JOIN ")|(" _regex ${_suffixes} )
#        STRING( CONCAT _regex "#.*(" ${_regex} ")$" )
#        foreach( _target ${targets} )
#            get_target_property(target_type ${_target} TYPE)
#            #MESSAGE( STATUS "${dir} - ${_target} - TARGETTYPE=${target_type}" )
#            if( ${_target} MATCHES ${_regex} )
#                message( STATUS "Adding target '${_target}' to ${arg_FOLDER_NAME}" )
#                set_target_properties( ${_target} PROPERTIES FOLDER ${arg_FOLDER_NAME} )
#            endif()
#        endforeach()
#    endforeach()
#endfunction()
#
#