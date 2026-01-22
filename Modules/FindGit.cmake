SET(GIT_FOUND FALSE)
SET(GIT_EXE_FOUND FALSE)

FIND_PROGRAM(GIT_EXE_EXECUTABLE git
    DOC "GIT command line client")
MARK_AS_ADVANCED(GIT_EXE_EXECUTABLE)

find_package(InstallFile REQUIRED)

MACRO(CheckGITExec)
    IF( ( NOT GIT_FOUND ) OR ( NOT EXISTS ${GIT_EXE_EXECUTABLE} ) )
      IF(GIT_FIND_REQUIRED)
            MESSAGE(FATAL_ERROR "GIT executable was not found.")
      ELSEIF(NOT GIT_FIND_QUIETLY)
            MESSAGE(WARNING "GIT executable was not found.")
      ENDIF()
    ENDIF()
ENDMACRO()    

IF(GIT_EXE_EXECUTABLE)
    SET(GIT_EXE_FOUND TRUE)
    SET(GIT_FOUND TRUE)

    IF( NOT EXISTS "${GIT_EXE_EXECUTABLE}" )
        UNSET( GIT_EXE_EXECUTABLE CACHE )
        UNSET( GIT_EXE_FOUND CACHE )
        UNSET( GIT_FOUND CACHE )
        UNSET( GIT_EXE_EXECUTABLE )
        UNSET( GIT_EXE_FOUND )
        UNSET( GIT_FOUND )
    ENDIF()
    CheckGITExec()

    MACRO(GetGitInfo dir prefix)
        #sets the following variables
        # ${prefix}_REV -> The current git revision to 8 characters (32 bits)
        # ${prefix}_DIFF -> If the git repo has been modified
        # ${prefix}_AHEAD -> If the git repois ahead of the remote server
        # ${prefix}_TAG -> The current git tag
        # ${prefix}_BRANCH -> The current git branch

        SET(_GIT_SAVED_LC_ALL "$ENV{LC_ALL}")
        SET(ENV{LC_ALL} C)

        #MESSAGE( STATUS "Using GIT: '${GIT_EXE_EXECUTABLE}'" )
        #MESSAGE( STATUS "Getting GIT info on '${dir}'" )
        EXECUTE_PROCESS(
            COMMAND 
                ${GIT_EXE_EXECUTABLE} -C "${dir}" 
                    describe --abbrev=8 --exclude \* "--dirty=;TRUE" --always
                    OUTPUT_VARIABLE _FULL_GIT_VERSION 
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_STRIP_TRAILING_WHITESPACE
                    ERROR_STRIP_TRAILING_WHITESPACE
        )
        
        if ( "${_FULL_GIT_VERSION}" STREQUAL "" )
            MESSAGE( FATAL_ERROR "Could not get GIT info on directory '${dir}'\r     '${${prefix}_ERROR}'" )
            SET(${prefix}_REV "N/A")
            SET(${prefix}_DIFF "")
            SET(${prefix}_AHEAD "")
            SET(${prefix}_TAG "N/A")
            SET(${prefix}_BRANCH "N/A")
        else()
            LIST( LENGTH _FULL_GIT_VERSION _LEN )
            if ( _LEN GREATER 2)
                MESSAGE( FATAL_ERROR "Invalid GIT format for version returned '${_FULL_GIT_VERSION}'" )
            ENDIF()

            LIST( GET _FULL_GIT_VERSION 0 ${prefix}_REV )
            if ( _LEN EQUAL 2 )
                LIST( GET _FULL_GIT_VERSION 1 ${prefix}_DIFF )
            ELSE()
                SET( ${prefix}_DIFF FALSE )
            ENDIF()

            string(REPLACE "-g" ";"  ${prefix}_REV ${${prefix}_REV} )
            LIST( LENGTH ${prefix}_REV _LEN )
            if ( _LEN GREATER 2)
                MESSAGE( FATAL_ERROR "Invalid GIT format for version returned '${_FULL_GIT_VERSION}'" )
            ENDIF()
            
            if ( _LEN EQUAL 2)
                LIST( GET ${prefix}_REV 1 ${prefix}_REV )
            ENDIF()
                      
           execute_process(
                COMMAND ${GIT_EXE_EXECUTABLE} -C "${dir}" 
                    describe --exact-match --tags
                    WORKING_DIRECTORY "${dir}"
                    OUTPUT_VARIABLE ${prefix}_TAG
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE
            )

            execute_process(
                COMMAND ${GIT_EXE_EXECUTABLE} -C "${dir}" 
                    rev-parse --abbrev-ref HEAD
                    WORKING_DIRECTORY "${dir}"
                    OUTPUT_VARIABLE ${prefix}_BRANCH
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            
            #git rev-list --count @{u}..HEAD                      
            execute_process(
                COMMAND ${GIT_EXE_EXECUTABLE} -C "${dir}" 
                    rev-list --count @{u}..HEAD
                    WORKING_DIRECTORY "${dir}"
                    OUTPUT_VARIABLE ${prefix}_AHEAD
                    ERROR_QUIET
                    OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if( "0" STREQUAL "${${prefix}_AHEAD}" )
                set( ${prefix}_AHEAD "" )
            endif()
        endif()
        SET(ENV{LC_ALL} ${_GIT_SAVED_LC_ALL})
    ENDMACRO()

    MACRO(CreateTagAndPackageTarget MAJOR MINOR )
        STRING(TIMESTAMP _CURRDATE "%d%m%Y_%H%M" UTC)
        SET( _TAGNAME ${MAJOR}.${MINOR}_${_CURRDATE} )
        #message( STATUS "MAJOR=${MAJOR}" )
        #message( STATUS "MINOR=${MINOR}" )
        #message( STATUS "_CURRDATE=${_CURRDATE}" )
        #message( STATUS "_TAGNAME=${_TAGNAME}" )
        # message( STATUS "${GIT_EXE_EXECUTABLE} tag -a v${_TAGNAME} -m 'Release ${_TAGNAME}'" )

        string( APPEND _ECHO1
            "$<IF:$<CONFIG:RelWithDebInfo>,"
                "${CMAKE_COMMAND};-E;echo;Creating Tag v${_TAGNAME},"
                "${CMAKE_COMMAND};-E;echo;****** Skipping in non-RelWithDebInfo Config ******"               
            ">"
            ) 

        string( APPEND _TAGIT
            "$<IF:$<CONFIG:RelWithDebInfo>,"
                "${GIT_EXE_EXECUTABLE};tag;-a;v${_TAGNAME};-m;\"Release ${_TAGNAME}\","
                "${CMAKE_COMMAND};-E;echo_append"               
            ">"
            ) 

        string( APPEND _ECHO2
            "$<IF:$<CONFIG:RelWithDebInfo>,"
                "${CMAKE_COMMAND};-E;echo;Running CPack -C $<CONFIG> --config ./CPackConfig.cmake,"
                "${CMAKE_COMMAND};-E;echo_append"               
            ">"
            ) 
        string( APPEND _RUNCPACK
            "$<IF:$<CONFIG:RelWithDebInfo>,"
                "${CMAKE_CPACK_COMMAND};-C;$<CONFIG>;--config;./CPackConfig.cmake,"
                "${CMAKE_COMMAND};-E;echo_append"               
            ">"
            ) 
            
        #message( STATUS    _ECHO1=${_ECHO1} )
        #message( STATUS    _TAGIT=${_TAGIT} )
        #message( STATUS    _ECHO2=${_ECHO2} )
        #message( STATUS _RUNCPACK=${_RUNCPACK} )
        add_custom_target(
          TAG_AND_PACKAGE
          COMMAND "${_ECHO1}"
          COMMAND "${_TAGIT}"
          COMMAND "${_ECHO2}"
          COMMAND "${_RUNCPACK}"
          WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
          DEPENDS PACKAGE
          COMMAND_EXPAND_LISTS
        )
        set_target_properties( TAG_AND_PACKAGE PROPERTIES FOLDER CMakePredefinedTargets )
    ENDMACRO()

ENDIF()

CheckGITExec()

