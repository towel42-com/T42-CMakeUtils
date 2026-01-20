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

find_package(DeploySystem REQUIRED)

if( NOT DEFINED USE_QT OR USE_QT )
    find_package(Qt6Core REQUIRED)

    if( NOT DEFINED DEPLOYQT_EXECUTABLE )
        # Retrieve the absolute path to qmake and then use that path to find
        # the <os>deployqt binaries
        find_program(_qtpaths_exec qtpaths REQUIRED)
        #message( STATUS "Found qtpaths=${_qtpaths_exec}")
        execute_process( 
            COMMAND ${_qtpaths_exec} -qt-query QT_INSTALL_BINS
            OUTPUT_VARIABLE _qt_bin_dir
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
        #message( STATUS "bindir = ${_qt_bin_dir}")
        if ( NOT EXISTS "${_qt_bin_dir}" )
            MESSAGE( FATAL "Could not find Qt's Bin Dir'")
        endif()

        find_program(DEPLOYQT_EXECUTABLE windeployqt HINTS "${_qt_bin_dir}")
        if(NOT DEPLOYQT_EXECUTABLE)
            message(FATAL_ERROR "windeployqt not found")
        endif()
        message(STATUS "Found windeployqt: ${DEPLOYQT_EXECUTABLE}")
        # Doing this with MSVC 2015 requires CMake 3.6+
        if( (MSVC_VERSION VERSION_EQUAL 1900 OR MSVC_VERSION VERSION_GREATER 1900) AND CMAKE_VERSION VERSION_LESS "3.6")
            message(WARNING "Deploying with MSVC 2015+ requires CMake 3.6+")
        endif()
    mark_as_advanced(DEPLOYQT_EXECUTABLE)
endif()


    # Add commands that copy the required Qt files to the same directory as the
    # target after being built as well as including them in final installation
    function(DeployQt target directory)
        if(NOT DEPLOYQT_EXECUTABLE)
            IF( UNIX )
                return()
            ENDIF()

            message(FATAL_ERROR "deployqt not found")
        endif()

        set( options )
        set( oneValueArgs INSTALL_ONLY NON_INSTALL_ONLY NO_TRANSLATIONS EXTRA_TARGETS_DIR EXTRA_TARGETS_DIR2 )
        set( multiValueArgs EXTRA_TARGETS EXTRA_TARGETS2 )

        cmake_parse_arguments( "" "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )
        if ( _NO_TRANSLATIONS )
            SET( NO_TRANSLATIONS_OPT "--no-translations")
        endif()

        #message( STATUS "EXTRA_TARGETS=${_EXTRA_TARGETS}" )
        #message( STATUS "EXTRA_TARGETS_DIR=${_EXTRA_TARGETS_DIR}" )

        #message( STATUS "EXTRA_TARGETS2=${_EXTRA_TARGETS2}" )
        #message( STATUS "EXTRA_TARGETS_DIR2=${_EXTRA_TARGETS_DIR2}" )
        if ( _EXTRA_TARGETS )
            foreach(currExtraTarget ${_EXTRA_TARGETS})
                if ( NOT TARGET ${currExtraTarget} )
                    continue()
                endif()
                
                SET( EXTRA_TARGETS_OPT ${EXTRA_TARGETS_OPT} "$<TARGET_FILE:${currExtraTarget}>")

                add_custom_command(TARGET ${target} POST_BUILD
                    COMMAND "${CMAKE_COMMAND}" -E echo "Making Directory '$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR}' for '${target}'"
                    COMMAND "${CMAKE_COMMAND}" -E make_directory \"$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR}\"
                    COMMAND "${CMAKE_COMMAND}" -E echo "Linking Target Library Library '$<TARGET_FILE_NAME:${currExtraTarget}>' for '${target}'"
                    COMMAND "${CMAKE_COMMAND}" -E create_symlink "$<TARGET_FILE:${currExtraTarget}>" \"$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR}/$<TARGET_FILE_NAME:${currExtraTarget}>\"
                    COMMAND "${CMAKE_COMMAND}" -E echo "Linking Target PDB File '$<TARGET_PDB_FILE:${currExtraTarget}>' for '${target}'"
                    COMMAND "${CMAKE_COMMAND}" -E create_symlink "$<TARGET_PDB_FILE:${currExtraTarget}>" \"$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR}/$<TARGET_FILE_BASE_NAME:${currExtraTarget}>.pdb\"
                )
            endforeach()
        endif()

        if ( _EXTRA_TARGETS2 )
            foreach(currExtraTarget ${_EXTRA_TARGETS2})
                if ( NOT TARGET ${currExtraTarget} )
                    continue()
                endif()

                SET( EXTRA_TARGETS_OPT ${EXTRA_TARGETS_OPT} "$<TARGET_FILE:${currExtraTarget}>")

                add_custom_command(TARGET ${target} POST_BUILD
                    COMMAND "${CMAKE_COMMAND}" -E echo "Making Directory '$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR2}' for '${target}'"
                    COMMAND "${CMAKE_COMMAND}" -E make_directory \"$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR2}\"
                    COMMAND "${CMAKE_COMMAND}" -E echo "Linking Target Library Library '$<TARGET_FILE_NAME:${currExtraTarget}>' for '${target}'"
                    COMMAND "${CMAKE_COMMAND}" -E create_symlink "$<TARGET_FILE:${currExtraTarget}>" \"$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR2}/$<TARGET_FILE_NAME:${currExtraTarget}>\"
                    COMMAND "${CMAKE_COMMAND}" -E echo "Copying Target PDB File '$<TARGET_PDB_FILE:${currExtraTarget}>' for '${target}'"
                    COMMAND "${CMAKE_COMMAND}" -E create_symlink "$<TARGET_PDB_FILE:${currExtraTarget}>" \"$<TARGET_FILE_DIR:${target}>/${_EXTRA_TARGETS_DIR2}/$<TARGET_FILE_BASE_NAME:${currExtraTarget}>.pdb\"
                )
            endforeach()
        endif()

        if ( NOT _INSTALL_ONLY )
            SET(_QTDEPLOY_TARGET "$<TARGET_FILE:${target}>" )
            SET(_QTDEPLOY_OPTIONS_LCL "--dir=\"$<TARGET_FILE_DIR:${target}>\";--verbose=1;--no-compiler-runtime;--no-opengl-sw;--no-system-dxc-compiler;--pdb;${NO_TRANSLATIONS_OPT}" )

            # Run deployqt immediately after build to make the build area "complete"
            add_custom_command(TARGET ${target} POST_BUILD
                COMMAND "${CMAKE_COMMAND}" -E echo "Deploying Qt to Build Area for Project '${target}' using '${DEPLOYQT_EXECUTABLE}' ${_QTDEPLOY_OPTIONS_LCL} ${_QTDEPLOY_TARGET} ${EXTRA_TARGETS_OPT}"
                COMMAND "${CMAKE_COMMAND}" -E
                    env PATH="${_qt_bin_dir}" "${DEPLOYQT_EXECUTABLE}"
                        ${_QTDEPLOY_OPTIONS_LCL}
                        ${_QTDEPLOY_TARGET} ${EXTRA_TARGETS_OPT}
            )
        endif()
        
        # install(CODE ...) doesn't support generator expressions, but
        # file(GENERATE ...) does - store the path in a file
        file(GENERATE 
            OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${target}_$<CONFIG>_path"
            CONTENT "$<TARGET_FILE:${target}>"
        )

        # Before installation, run a series of commands that copy each of the Qt
        # runtime files to the appropriate directory for installation
        if ( NOT _NON_INSTALL_ONLY )
            install(CODE
                "
                file(READ \"${CMAKE_CURRENT_BINARY_DIR}/${target}_\${CMAKE_INSTALL_CONFIG_NAME}_path\" _file)
                SET(_QTDEPLOY_OPTIONS \"--dry-run;--list;mapping;--no-compiler-runtime;--no-opengl-sw;--no-system-dxc-compiler;${NO_TRANSLATIONS_OPT}\" )

                MESSAGE( STATUS \"Deploying Qt to the Install Area '\${CMAKE_INSTALL_PREFIX}/${directory}' for Project '${target}' using '${DEPLOYQT_EXECUTABLE}' ...\" )
                execute_process(
                    COMMAND \"${CMAKE_COMMAND}\" -E
                        env PATH=\"${_qt_bin_dir}\" \"${DEPLOYQT_EXECUTABLE}\"
                            \${_QTDEPLOY_OPTIONS}
                            \${_file}
                    OUTPUT_VARIABLE _output
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                )
                separate_arguments(_files NATIVE_COMMAND \${_output})
                while(_files)
                    list(GET _files 0 _src)
                    list(GET _files 1 _dest)
                    execute_process(
                        COMMAND \"${CMAKE_COMMAND}\" -E
                            compare_files \"\${_src}\" \"\${CMAKE_INSTALL_PREFIX}/\${directory}/\${_dest}\"
                            OUTPUT_VARIABLE _outvar
                            ERROR_VARIABLE _errvar
                            RESULT_VARIABLE _result_code
                    )
                    if( \${_result_code} )
                        MESSAGE( STATUS \"Installing: \${CMAKE_INSTALL_PREFIX}/\${directory}/\${_dest}\" )
                        execute_process(
                            COMMAND \"${CMAKE_COMMAND}\" -E
                                copy \${_src} \"\${CMAKE_INSTALL_PREFIX}/\${directory}/\${_dest}\"
                        )
                    ELSE()
                        MESSAGE( STATUS \"Up-to-date: \${CMAKE_INSTALL_PREFIX}/${directory}/\${_dest}\" )
                    ENDIF()
                    list(REMOVE_AT _files 0 1)
                endwhile()
                MESSAGE( STATUS \"Finished deploying Qt\" )
                "
            )
        endif()
    endfunction()
endif()


