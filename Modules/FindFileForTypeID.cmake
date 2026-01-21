# The MIT License (MIT)
#
# Copyright (c) 2017 Nathan Osman
# Copyright (c) 2020-2021 Scott Aron Bloom - Work on linux and mac
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

if( DUMPCPP_EXECUTABLE AND NOT EXISTS ${DUMPCPP_EXECUTABLE} )
        MESSAGE( WARNING "'${DUMPCPP_EXECUTABLE}' no longer exists" )
        UNSET( DUMPCPP_EXECUTABLE CACHE )
        UNSET( DUMPCPP_VERSION CACHE )
endif()

#if( NOT DUMPCPP_EXECUTABLE  )
#    message( STATUS "DUMPCPP_EXECUTABLE not set" )
#endif()

#if( NOT DUMPCPP_VERSION  )
#    message( STATUS "DUMPCPP_VERSION not set" )
#endif()

UNSET( DUMPCPP_EXECUTABLE CACHE )
UNSET( DUMPCPP_VERSION CACHE )

if( NOT DUMPCPP_EXECUTABLE OR NOT DUMPCPP_VERSION )
    find_program(DUMPCPP_EXECUTABLE
        NAMES 
            sab_dumpcpp
        PATHS
            ${CMAKE_INSTALL_PREFIX} ${CMAKE_BINARY_DIR}/dumpcpp/RelWithDebInfo ${CMAKE_BINARY_DIR}/dumpcpp/Release ${CMAKE_BINARY_DIR}/dumpcpp/Debug
        DOC
            "path to the dumpcpp executable (from build area)" 
        NO_DEFAULT_PATH
    )

    #find_program(DUMPCPP_EXECUTABLE NAMES dumpcpp
    #  PATHS ${QT6_INSTALL_PREFIX}/bin
    #    DOC "path to the dumpcpp executable (from build area)" 
    #    NO_DEFAULT_PATH
    #    NO_CACHE
    #)

    if( NOT DUMPCPP_EXECUTABLE )
        MESSAGE( WARNING "Could not find build area dumpcpp.  Re-run cmake after initial build" )
    else()
        file( REAL_PATH ${DUMPCPP_EXECUTABLE} DUMPCPP_EXECUTABLE EXPAND_TILDE)
        file( TO_CMAKE_PATH ${DUMPCPP_EXECUTABLE} DUMPCPP_EXECUTABLE)
        mark_as_advanced(DUMPCPP_EXECUTABLE)
    endif()

    if( DUMPCPP_EXECUTABLE )
        execute_process( COMMAND ${DUMPCPP_EXECUTABLE} --version OUTPUT_VARIABLE version OUTPUT_STRIP_TRAILING_WHITESPACE)
        SET( DUMPCPP_VERSION ${version} CACHE STRING "dumpcpp version" FORCE )
        mark_as_advanced(DUMPCPP_VERSION)

        MESSAGE( STATUS "Using dumpcpp: '${DUMPCPP_EXECUTABLE}' - ${DUMPCPP_VERSION}" )
    endif()
endif()

MACRO(FileForTypeID typeID prefix )
    set( ${prefix}_TYPEID_FILEPATH FALSE)
    
    string(CONCAT regPathBase "HKEY_LOCAL_MACHINE\\Software\\Classes\\TypeLib\\"  ${typeID} )
    #message( STATUS "regPathBase=${regPathBase}" )
    cmake_host_system_information(RESULT codes QUERY WINDOWS_REGISTRY ${regPathBase} SUBKEYS SEPARATOR ";")

    #MESSAGE( STATUS "codes=${codes}" )
    foreach( code ${codes} )
        string(CONCAT regPathZero ${regPathBase} "\\" ${code} "\\0" )
        #MESSAGE( STATUS "regPathZero=${regPathZero}" )
        cmake_host_system_information(RESULT oses QUERY WINDOWS_REGISTRY ${regPathZero} SUBKEYS SEPARATOR ";")
        foreach( os ${oses} )
            string(CONCAT regPath ${regPathZero} "\\" ${os} )
            #MESSAGE( STATUS "regPath=${regPath}" )
            cmake_host_system_information(RESULT path QUERY WINDOWS_REGISTRY ${regPath} VALUE "" )
            #MESSAGE( STATUS "path=${path}" )
            if ( EXISTS ${path} )
                #MESSAGE( STATUS "prefix=${prefix}" )
                cmake_path( CONVERT ${path} TO_CMAKE_PATH_LIST ${prefix}_TYPEID_FILEPATH NORMALIZE)
                #message( STATUS "${prefix}_TYPEID_FILEPATH = ${${prefix}_TYPEID_FILEPATH}" )
                break()
            endif()
        endforeach()
    endforeach()
ENDMACRO()


MACRO( GenerateCPPFromFileID fileID prefix enumPrefix )
    if( DUMPCPP_EXECUTABLE )
        if ( NOT EXISTS ${DUMPCPP_EXECUTABLE} )
            message( FATAL_ERROR "${DUMPCPP_EXECUTABLE} does not exist" )
        endif()

        FileForTypeID( ${fileID} ${prefix} )

        #message( STATUS "${prefix}_TYPEID_FILEPATH=${${prefix}_TYPEID_FILEPATH}" )
        if ( NOT EXISTS ${${prefix}_TYPEID_FILEPATH} )
            message( FATAL_ERROR "Could not find OLB file '${${prefix}_TYPEID_FILEPATH}' for file id ${fileID}" )
        endif()

        set( ${prefix}_CPP ${CMAKE_CURRENT_BINARY_DIR}/${prefix}.cpp )
        set( ${prefix}_H ${CMAKE_CURRENT_BINARY_DIR}/${prefix}.h )

        #message( STATUS "${prefix}_CPP=${${prefix}_CPP}" )
        #message( STATUS "${prefix}_H=${${prefix}_H}" )
        #message( STATUS "DUMPCPP_EXECUTABLE=${DUMPCPP_EXECUTABLE} - ${DUMPCPP_VERSION}" )

        find_program( MOC_EXEC moc.exe REQUIRED )
    
        ADD_CUSTOM_COMMAND( 
            OUTPUT 
                ${${prefix}_CPP} ${${prefix}_H}
            COMMENT "[DUMPCPP] Generating ${prefix}.cpp and ${prefix}.h from '${${prefix}_TYPEID_FILEPATH}' using \"${DUMPCPP_EXECUTABLE} - ${DUMPCPP_VERSION}\" ${fileID} -o ${prefix} --enum_class --gen_tofrom_enum --prefix ${enumPrefix} --disable_clang_format"
            COMMAND echo "${DUMPCPP_EXECUTABLE}" ${fileID} -o ${prefix} --enum_class --gen_tofrom_enum --prefix ${enumPrefix} --disable_clang_format -moc_exec "${MOC_EXEC}"
            COMMAND "${DUMPCPP_EXECUTABLE}" ${fileID} -o ${prefix} --enum_class --gen_tofrom_enum --prefix ${enumPrefix} --disable_clang_format --moc_exec "${MOC_EXEC}"
            VERBATIM
            DEPENDS
               ${${prefix}_TYPEID_FILEPATH}
               ${DUMPCPP_EXECUTABLE}
        )
    endif()
endmacro()
   

