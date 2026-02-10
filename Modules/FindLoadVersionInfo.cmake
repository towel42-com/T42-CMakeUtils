
FUNCTION(CreateVersionInfoFile)
    if ( NOT APP_NAME )
        MESSAGE( FATAL_ERROR "APP_NAME must be set" )
    endif()

    if ( NOT VERSIONINFO_FILE )
        MESSAGE( FATAL_ERROR "VERSIONINFO_FILE must be set" )
    endif()

    set( TEMPLATE_FILE ${CMAKE_SOURCE_DIR}/T42-CMakeUtils/Modules/VersionInfo.cmake.in )

    if ( NOT START_YEAR )
        STRING(TIMESTAMP START_YEAR "%Y" UTC)
    endif()

    if ( NOT MAJOR_VERSION )
        SET( MAJOR_VERSION 0)
    endif()

    if ( NOT MINOR_VERSION )
        SET( MINOR_VERSION 1)
    endif()

    if ( NOT VENDOR )
        SET( VENDOR "Towel 42 Development, LLC" )
    endif()

    if ( NOT HOMEPAGE )
        SET( HOMEPAGE "https://github.com/towel42-com" )
    endif()

    if ( NOT PRODUCT_HOMEPAGE )
        get_filename_component(PROJ_NAME ${CMAKE_CURRENT_SOURCE_DIR} NAME )
        SET( PRODUCT_HOMEPAGE "https://github.com/towel42-com/${PROJ_NAME}" )
    endif()

    if ( NOT EMAIL )
        SET( EMAIL "support@towel42.com" )
    endif()

    MESSAGE( STATUS "T42-CMakeUtils:         APP_NAME- ${APP_NAME}" )
    MESSAGE( STATUS "T42-CMakeUtils:       START_YEAR- ${START_YEAR}" )
    MESSAGE( STATUS "T42-CMakeUtils:    MAJOR_VERSION- ${MAJOR_VERSION}" )
    MESSAGE( STATUS "T42-CMakeUtils:    MINOR_VERSION- ${MINOR_VERSION}" )
    MESSAGE( STATUS "T42-CMakeUtils:           VENDOR- ${VENDOR}" )
    MESSAGE( STATUS "T42-CMakeUtils:         HOMEPAGE- ${HOMEPAGE}" )
    MESSAGE( STATUS "T42-CMakeUtils: PRODUCT_HOMEPAGE- ${PRODUCT_HOMEPAGE}" )
    MESSAGE( STATUS "T42-CMakeUtils:            EMAIL- ${EMAIL}" )
    MESSAGE( STATUS "T42-CMakeUtils:            EMAIL- ${EMAIL}" )
    MESSAGE( STATUS "T42-CMakeUtils:    TEMPLATE_FILE- ${TEMPLATE_FILE}" )
    MESSAGE( STATUS "T42-CMakeUtils: VERSIONINFO_FILE- ${VERSIONINFO_FILE}" )
    
    configure_file( 
        ${TEMPLATE_FILE}
        ${VERSIONINFO_FILE}
        @ONLY
        NEWLINE_STYLE WIN32
    )
endfunction()

function(LoadVersionInfoFile)
    set( VERSIONINFO_FILE ${CMAKE_SOURCE_DIR}/VersionInfo.cmake)

    if ( NOT EXISTS "${VERSIONINFO_FILE}" )
        message( STATUS "${VERSIONINFO_FILE} NOT exist, generating" )
        
        CreateVersionInfoFile()

        if ( NOT EXISTS "${VERSIONINFO_FILE}" )
            message( FATAL_ERROR "Error generating ${VERSIONINFO_FILE}" )
        endif()
    endif()

    include( ${VERSIONINFO_FILE} OPTIONAL RESULT_VARIABLE VAR)
    
    if ( ${VAR} STREQUAL "NOTFOUND" )
        message( FATAL_ERROR "Error reading ${VERSIONINFO_FILE}, file not found" )
    endif()
endfunction()