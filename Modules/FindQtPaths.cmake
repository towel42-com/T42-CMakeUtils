# The MIT License (MIT)
#
# Copyright (c) 2025- Scott Aron Bloom
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

FUNCTION( FindQtDir OUTPUT_VAR PROP_NAME)

    SET( _KNOWN_PROPERTY_DIRS
         "QT_SYSROOT"
         "QT_INSTALL_PREFIX"
         "QT_INSTALL_ARCHDATA"
         "QT_INSTALL_DATA"
         "QT_INSTALL_DOCS"
         "QT_INSTALL_HEADERS"
         "QT_INSTALL_LIBS"
         "QT_INSTALL_LIBEXECS"
         "QT_INSTALL_BINS"
         "QT_INSTALL_TESTS"
         "QT_INSTALL_PLUGINS"
         "QT_INSTALL_QML"
         "QT_INSTALL_TRANSLATIONS"
         "QT_INSTALL_CONFIGURATION"
         "QT_INSTALL_EXAMPLES"
         "QT_INSTALL_DEMOS"
         "QT_HOST_PREFIX"
         "QT_HOST_DATA"
         "QT_HOST_BINS"
         "QT_HOST_LIBEXECS"
         "QT_HOST_LIBS"
         "QMAKE_SPEC"
         "QMAKE_XSPEC"
         "QMAKE_VERSION"
         "QT_VERSION"
    )
    SET( _KNOWN_LOCATIONS_DIRS 
        AppConfigLocation
        AppDataLocation
        AppLocalDataLocation
        ApplicationsLocation
        CacheLocation
        ConfigLocation
        DesktopLocation
        DocumentsLocation
        DownloadLocation
        FontsLocation
        GenericCacheLocation
        GenericConfigLocation
        GenericDataLocation
        GenericStateLocation
        HomeLocation
        MoviesLocation
        MusicLocation
        PicturesLocation
        PublicShareLocation
        RuntimeLocation
        StateLocation
        TempLocation
        TemplatesLocation
    )
    
    if (     ( NOT ${PROP_NAME} IN_LIST ${_KNOWN_PROPERTY_DIRS} ) 
         AND  NOT ${PROP_NAME} IN_LIST ${_KNOWN_LOCATIONS_DIRS} )
        MESSAGE( FATAL_ERROR "Invalid Property Name '${PROP_NAME}'" )
    endif()
    
    find_program(_qtpaths_exec qtpaths REQUIRED)
    
    if ( ${PROP_NAME} IN_LIST ${_KNOWN_PROPERTY_DIRS} )
        execute_process( 
            COMMAND ${_qtpaths_exec} --query ${PROP_NAME}
            OUTPUT_VARIABLE _result
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    else()
        execute_process( 
            COMMAND ${_qtpaths_exec} --locate-directory ${PROP_NAME}
            OUTPUT_VARIABLE _result
            OUTPUT_STRIP_TRAILING_WHITESPACE
        )
    endif()
    
    IF( NOT EXISTS "${_result}" )
        MESSAGE( FATAL_ERROR "Reported Qt '${PROP_NAME}' Directory '${_result}' does not exist'")
    ENDIF()

    SET( ${OUTPUT_VAR} ${_result})
    SET( ${OUTPUT_VAR} ${_result} PARENT_SCOPE)
ENDFUNCTION()

FUNCTION( FindQtBinDir OUTPUT_VAR )
    find_program(_qtpaths_exec qtpaths REQUIRED)
    execute_process( 
        COMMAND ${_qtpaths_exec} --binaries-dir
        OUTPUT_VARIABLE _result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    IF( NOT EXISTS "${_result}" )
        MESSAGE( FATAL_ERROR "Reported Qt Binary Directory '${_result}' does not exist'")
    ENDIF()

    SET( ${OUTPUT_VAR} ${_result})
    SET( ${OUTPUT_VAR} ${_result} PARENT_SCOPE)
ENDIF()

FUNCTION( FindQtInstallDir OUTPUT_VAR )
    find_program(_qtpaths_exec qtpaths REQUIRED)
    execute_process( 
        COMMAND ${_qtpaths_exec} --install-prefix
        OUTPUT_VARIABLE _result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    IF( NOT EXISTS "${_result}" )
        MESSAGE( FATAL_ERROR "Reported Qt Install Directory '${_result}' does not exist'")
    ENDIF()

    SET( ${OUTPUT_VAR} ${_result})
    SET( ${OUTPUT_VAR} ${_result} PARENT_SCOPE)
ENDIF()

FUNCTION( FindQtPlugInDir OUTPUT_VAR )
    find_program(_qtpaths_exec qtpaths REQUIRED)
    execute_process( 
        COMMAND ${_qtpaths_exec} --plugin-dir
        OUTPUT_VARIABLE _result
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    IF( NOT EXISTS "${_result}" )
        MESSAGE( FATAL_ERROR "Reported Qt Plug-in Directory '${_result}' does not exist'")
    ENDIF()

    SET( ${OUTPUT_VAR} ${_result})
    SET( ${OUTPUT_VAR} ${_result} PARENT_SCOPE)
ENDIF()
