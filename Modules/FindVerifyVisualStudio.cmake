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

FUNCTION( getInstallMajorVersion versionString VARNAME)
    string( REGEX MATCH "([0-9]+)\.[0-9]+\.[0-9]+(\.[0-9]+)?" TMP ${versionString} )
    if( CMAKE_MATCH_COUNT EQUAL 0 )
        message( FATAL_ERROR "    Could not determine major version from '${versionString}'" )
    endif()
    
    SET( ${VARNAME} ${CMAKE_MATCH_1} PARENT_SCOPE )
endfunction()

FUNCTION( getDisplayNameYear displayName VARNAME)
    string( REGEX MATCH "[A-Za-z ]+([0-9][0-9][0-9][0-9])" TMP ${displayName} )
    if( CMAKE_MATCH_COUNT EQUAL 0 )
        message( FATAL_ERROR "    Could not determine year from the displayName '${displayName}'" )
    endif()
    
    SET( ${VARNAME} ${CMAKE_MATCH_1} PARENT_SCOPE )
endfunction()

FUNCTION(VerifyVisualStudio PREFIX)
    SET( ${PREFIX}VISUAL_STUDIO_FOUND FALSE PARENT_SCOPE )
    IF( NOT WIN32)
        return()
    ENDIF()
    
    find_program( CL cl.exe NO_CACHE REQUIRED)
    find_program( LINK link.exe NO_CACHE REQUIRED)
    find_program( DEVENV devenv.exe NO_CACHE REQUIRED)
    find_program( VSWHERE vswhere.exe 
            PATHS "$ENV{PROGRAMFILES\(X86\)}/Microsoft Visual Studio/Installer"
            NO_CACHE 
            REQUIRED )
    file(TO_CMAKE_PATH ${CL} CL)
    file(TO_CMAKE_PATH ${LINK} LINK)
    file(TO_CMAKE_PATH ${DEVENV} DEVENV)
    file(TO_CMAKE_PATH ${VSWHERE} VSWHERE)

    #message( STATUS "CL=${CL}" )
    #message( STATUS "LINK=${LINK}" )
    #message( STATUS "DEVENV=${DEVENV}" )
    #message( STATUS "VSWHERE=${VSWHERE}" )
    
    get_filename_component( VSDIR ${CL} DIRECTORY )
    get_filename_component( LNKDIR ${LINK} DIRECTORY )
    #get_filename_component( DEVENVDIR ${DEVENV} DIRECTORY )
    if( NOT ${VSDIR} STREQUAL ${LNKDIR} )
        message( FATAL_ERROR "    cl.exe was found in directory '${VSDIR}'\n    link.exe was found in directory '${LNKDIR}'\nlink.exe and cl.exe should be from the same release" )
    endif()

    get_filename_component( VSARCH ${VSDIR} NAME )
    #message( STATUS "VSARCH=${VSARCH}" )
    
    execute_process( 
        COMMAND ${VSWHERE} -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -format JSON
        OUTPUT_VARIABLE fullJSON
        ERROR_QUIET
    )
    string( JSON num LENGTH ${fullJSON} )
    math( EXPR num "${num}-1")
    SET( installVersions "" )
    SET( installPaths "" )
    SET( productPaths "" )
    SET( displayNames "")
    SET( productLineVersions "" )
    SET( featureReleaseYears "" )
    
    
    foreach( currInstallNum RANGE 0 ${num} )
        string( JSON currInstallInfo ERROR_VARIABLE errorVar GET ${fullJSON} ${currInstallNum} )
        #message( STATUS "errorVar=${errorVar}" )
        #message( STATUS currInstallInfo=${currInstallInfo} )
        
        STRING( JSON installVersion ERROR_VARIABLE errorVar GET ${currInstallInfo} "installationVersion" )
        #message( STATUS "installVersion=${installVersion}" )
        #message( STATUS "errorVar=${errorVar}" )
        list( APPEND installVersions ${installVersion} )
        
        STRING( JSON installationPath ERROR_VARIABLE errorVar GET ${currInstallInfo} "installationPath" )
        #message( STATUS "errorVar=${errorVar}" )
        #message( STATUS "installationPath=${installationPath}" )
        list( APPEND installPaths ${installationPath} )
        
        STRING( JSON productPath ERROR_VARIABLE errorVar GET ${currInstallInfo} "productPath" )
        #message( STATUS "errorVar=${errorVar}" )
        #message( STATUS "productPath=${productPath}" )
        list( APPEND productPaths ${productPath} )

        STRING( JSON displayName ERROR_VARIABLE errorVar GET ${currInstallInfo} "displayName" )
        #message( STATUS "errorVar=${errorVar}" )
        list( APPEND displayNames ${displayName} )

        string( JSON currCatalog GET ${currInstallInfo} "catalog" )
        #message( STATUS "errorVar=${errorVar}" )
        #message( STATUS "currCatalog=${currCatalog}" )

        STRING( JSON featureReleaseYear ERROR_VARIABLE errorVar GET ${currCatalog} "featureReleaseYear" )
        #message( STATUS "errorVar=${errorVar}" )
        #message( STATUS "featureReleaseYear=${featureReleaseYear}" )
        list( APPEND featureReleaseYears ${featureReleaseYear} )

        STRING( JSON productLineVersion ERROR_VARIABLE errorVar GET ${currCatalog} "productLineVersion" )
        #message( STATUS "errorVar=${errorVar}" )
        #message( STATUS "productLineVersion=${productLineVersion}" )
        list( APPEND productLineVersions ${productLineVersion} )
    endforeach()

    #message( STATUS "installPaths=${installPaths}" )
    #message( STATUS "productPaths=${productPaths}" )
    #message( STATUS "displayNames=${displayNames}" )
    #message( STATUS "productLineVersions=${productLineVersions}" )
    #message( STATUS "featureReleaseYears=${featureReleaseYears}" )
    
    foreach( installPath productPath displayName installVersion productLineVersion featureReleaseYear IN ZIP_LISTS installPaths productPaths displayNames installVersions productLineVersions featureReleaseYears )
        file(TO_CMAKE_PATH ${installPath} installPath)
        file(TO_CMAKE_PATH ${productPath} productPath)

        #message( STATUS "===========================" )
        #message( STATUS "installPath=${installPath}" )
        #message( STATUS "productPath=${productPath}" )
        getDisplayNameYear( ${displayName} displayNameYear )
        #message( STATUS "displayName=${displayName}" )
        #message( STATUS "displayNameYear=${displayNameYear}" )

        #message( STATUS "installVersion=${installVersion}" )
        getInstallMajorVersion( ${installVersion} majorVersion )
        #message( STATUS "majorVersion=${majorVersion}" )
        #message( STATUS "productLineVersion=${productLineVersion}" )
        #message( STATUS "featureReleaseYear=${featureReleaseYear}" )

        if ( ${productPath} STREQUAL ${DEVENV} )
            #MESSAGE( STATUS "Found DevEnv in use: ${DEVENV} - ${productPath}" )
            
            SET( ${PREFIX}VISUAL_STUDIO_FOUND TRUE PARENT_SCOPE )
            SET( ${PREFIX}VISUAL_STUDIO_INSTALLPATH ${installPath} PARENT_SCOPE )
            SET( ${PREFIX}VISUAL_STUDIO_PRODUCTLINEVERSION ${productLineVersion} PARENT_SCOPE )
            SET( ${PREFIX}VISUAL_STUDIO_INSTALLVERSION ${installVersion} PARENT_SCOPE )
            
            SET( generator "Visual Studio ${majorVersion}" )
            if ( featureReleaseYear )
                SET( generator "${generator} ${featureReleaseYear}" )
            elseif ( productLineVersion )
                SET( generator "${generator} ${productLineVersion}" )
            elseif ( displayNameYear )
                SET( generator "${generator} ${displayNameYear}" )
            endif()
            
            #message( STATUS "generator = ${generator}" )
            SET( ${PREFIX}VISUAL_STUDIO_GENERATOR ${generator} PARENT_SCOPE )
            if ( NOT "${generator}" STREQUAL "${CMAKE_GENERATOR}" )
                MESSAGE( FATAL_ERROR "    Visual Studio should use generator '${generator}' is not the same as the current CMAKE_GENERATOR '${CMAKE_GENERATOR}'\n    Please use -G \"${generator}\" or set the environment variable CMAKE_GENERATOR=\"${generator}\"" )
            else()
                MESSAGE( STATUS "Search path to Visual Studio verified" )
            endif()
            #MESSAGE( STATUS "${PREFIX}VISUAL_STUDIO_INSTALLPATH=${installPath}" )
            #MESSAGE( STATUS "${PREFIX}VISUAL_STUDIO_GENERATOR=${generator}" )
            break()
        endif()
    endforeach()
ENDFUNCTION()


