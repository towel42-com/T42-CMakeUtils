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

cmake_minimum_required(VERSION 3.31)

function(getAllSubdirs dir _OUTVAR)
    set(_dirs "")
    # get subdirectories for dir
    get_property(subdirs DIRECTORY ${dir} PROPERTY SUBDIRECTORIES)
    # iterate any found subdirectories
    foreach(subdir ${subdirs})
#        # append each sub directory
        list(APPEND _dirs ${subdir})
        getAllSubdirs(${subdir} curr_OUTVAR)
        list(APPEND _dirs ${curr_OUTVAR})
    endforeach()
    SET( ${_OUTVAR} ${_dirs} PARENT_SCOPE )
endfunction()

function( FolderizeQtAutoProjects )
    #message( STATUS "CMAKE_SOURCE_DIR=${CMAKE_SOURCE_DIR}" )
    getAllSubDirs(${CMAKE_SOURCE_DIR} _ALLDIRS )

    foreach( dir ${_ALLDIRS} )
        get_property(targets DIRECTORY ${dir} PROPERTY "BUILDSYSTEM_TARGETS")
        foreach( _target ${targets} )
            STRING( FIND ${_target} "_qmlimportscan" _pos1 )
            STRING( FIND ${_target} "_other_files" _pos2 )
            if( ( _pos1 EQUAL -1 ) AND ( _pos2 EQUAL -1 ) )
                continue()
            endif()
            #message( STATUS "Adding target ${_target} to QtAutoProjects" )
            set_target_properties( ${_target} PROPERTIES FOLDER QtAutoProjects )
        endforeach()
    endforeach()
endfunction()

