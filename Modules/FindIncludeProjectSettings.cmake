MACRO(IncludeProjectSettings)
    set( options  )
    set( oneValueArgs QT )
    set( multiValueArgs )

    cmake_parse_arguments( _INCLUDE_PROJECT_SETTINGS "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN} )

    if ( "${_INCLUDE_PROJECT_SETTINGS_QT}" STREQUAL "" )
        if( DEFINED T42_GLOBAL_USE_QT )
            SET( _INCLUDE_PROJECT_SETTINGS_QT ${T42_GLOBAL_USE_QT} )
        endif()
    endif()
    #MESSAGE( STATUS "IncludeProjectSettings CMAKE_CURRENT_LIST_DIR=${CMAKE_CURRENT_LIST_DIR}" )
    #MESSAGE( STATUS "IncludeProjectSettings _INCLUDE_PROJECT_SETTINGS_QT=${_INCLUDE_PROJECT_SETTINGS_QT}" )

    SET( CURR_DIR ${CMAKE_CURRENT_LIST_DIR} )
    get_filename_component(STOP_DIR ${CMAKE_SOURCE_DIR} DIRECTORY)
    #MESSAGE( STATUS "CURR_DIR=${CURR_DIR}" )
    #MESSAGE( STATUS "STOP_DIR=${STOP_DIR}" )

    if ( _INCLUDE_PROJECT_SETTINGS_QT )
        SET( _PROJECT_BASE_FILE "QtProject.cmake" )
    else()
        SET( _PROJECT_BASE_FILE "Project.cmake" )
    endif()

    while( NOT ${CURR_DIR} STREQUAL ${STOP_DIR} )
        #MESSAGE( STATUS "Checking ${CURR_DIR} for ${_PROJECT_BASE_FILE}" )

        if ( EXISTS "${CURR_DIR}/${_PROJECT_BASE_FILE}" )
            #MESSAGE( STATUS "Found ${CURR_DIR}/${_PROJECT_BASE_FILE}" )
            set( _PROJECT_FILE ${CURR_DIR}/${_PROJECT_BASE_FILE} )
            break()
        endif()
        
        get_filename_component(CURR_DIR ${CURR_DIR} DIRECTORY)
    endwhile()
    UNSET( CURR_DIR )
    UNSET( STOP_DIR )
    
    if ( NOT EXISTS "${_PROJECT_FILE}" )
        SET( _PROJECT_FILE "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/../${_PROJECT_BASE_FILE}" )
        
        #MESSAGE( STATUS "Checking ${_PROJECT_FILE}" )
        if ( EXISTS "${_PROJECT_FILE}" )
            #MESSAGE( STATUS "Found ${_PROJECT_FILE}" )
            SET( _PROJECT_FILE ${_PROJECT_FILE} )
        endif()
    endif()
        
    if ( NOT EXISTS "${_PROJECT_FILE}" )
        MESSAGE( FATAL_ERROR "No ${_PROJECT_BASE_FILE} file found" )
    endif()
    
    #MESSAGE( STATUS "Found ${_PROJECT_FILE}" )
    include( "${_PROJECT_FILE}" )
    UNSET( _PROJECT_BASE_FILE )
    UNSET( _PROJECT_FILE )
ENDMACRO()
