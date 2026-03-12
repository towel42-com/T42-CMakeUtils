find_package(InstallFile REQUIRED)

FUNCTION(CreateVersionInfoFile)
    if ( NOT APP_NAME )
        MESSAGE( FATAL_ERROR "APP_NAME must be set" )
    endif()
    
    if ( NOT MAIN_EXE_PROJECT_NAME )
        MESSAGE( FATAL_ERROR "MAIN_EXE_PROJECT_NAME must be set" )
    endif()

    if ( NOT VERSIONINFO_FILE )
        MESSAGE( FATAL_ERROR "VERSIONINFO_FILE must be set" )
    endif()

    if ( "${MAJOR_VERSION}" STREQUAL "" )
        MESSAGE( FATAL_ERROR "MAJOR_VERSION must be set" )
    endif()

    if ( "${MINOR_VERSION}" STREQUAL "" )
        MESSAGE( FATAL_ERROR "MINOR_VERSION must be set" )
    endif()

    SET( TMP_FILE ${VERSIONINFO_FILE}.bak )
    SET( OUTFILE ${VERSIONINFO_FILE} )
    set( TEMPLATE_FILE ${CMAKE_CURRENT_FUNCTION_LIST_DIR}/VersionInfo.cmake.in )

    if ( NOT VENDOR )
        SET( VENDOR "Towel 42 Development, LLC" )
    endif()

    if ( NOT HOMEPAGE )
        SET( HOMEPAGE "https://github.com/towel42-com" )
    endif()

    if ( NOT PRODUCT_HOMEPAGE )
        SET( PRODUCT_HOMEPAGE "https://github.com/towel42-com/${MAIN_EXE_PROJECT_NAME}" )
    endif()

    if ( NOT EMAIL )
        SET( EMAIL "support@towel42.com" )
    endif()

    #MESSAGE( STATUS "T42-CMakeUtils:         APP_NAME- ${APP_NAME}" )
    #MESSAGE( STATUS "T42-CMakeUtils:    MAJOR_VERSION- ${MAJOR_VERSION}" )
    #MESSAGE( STATUS "T42-CMakeUtils:    MINOR_VERSION- ${MINOR_VERSION}" )
    #MESSAGE( STATUS "T42-CMakeUtils:           VENDOR- ${VENDOR}" )
    #MESSAGE( STATUS "T42-CMakeUtils:         HOMEPAGE- ${HOMEPAGE}" )
    #MESSAGE( STATUS "T42-CMakeUtils: PRODUCT_HOMEPAGE- ${PRODUCT_HOMEPAGE}" )
    #MESSAGE( STATUS "T42-CMakeUtils:            EMAIL- ${EMAIL}" )
    #MESSAGE( STATUS "T42-CMakeUtils:    TEMPLATE_FILE- ${TEMPLATE_FILE}" )
    #MESSAGE( STATUS "T42-CMakeUtils: VERSIONINFO_FILE- ${VERSIONINFO_FILE}" )
    message( CHECK_START "Generating/Updating VersionInfo.cmake" )

    configure_file( 
        ${TEMPLATE_FILE}
        ${TMP_FILE}
        @ONLY
        NEWLINE_STYLE WIN32
    )

    InstallFile( ${TMP_FILE} ${OUTFILE} REMOVE_ORIG ) # creates a dependency on TMP_OUTFILE
    message( CHECK_PASS "Generated/Updated" )
endfunction()

function(LoadVersionInfoFile)
    set( VERSIONINFO_FILE ${CMAKE_BINARY_DIR}/VersionInfo.cmake)

    CreateVersionInfoFile()

    include( ${VERSIONINFO_FILE} OPTIONAL RESULT_VARIABLE VAR)
    
    if ( ${VAR} STREQUAL "NOTFOUND" )
        message( FATAL_ERROR "Error reading ${VERSIONINFO_FILE}, file not found" )
    endif()
endfunction()