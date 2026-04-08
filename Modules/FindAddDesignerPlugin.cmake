# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

cmake_minimum_required(VERSION 3.31)
FUNCTION( AddDesignerPlugin )
    set( options "")
    set( oneValueArgs NAME BASENAME )
    set( multiValueArgs FILES INCLUDE_DIRECTORIES LINK_LIBS COMPILER_DEFINES)
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}"
    )

    if ( NOT arg_NAME AND NOT arg_BASENAME)
        MESSAGE( FATAL_ERROR "NAME or BASENAME must be set" )
    endif()
    
    if ( NOT arg_NAME AND arg_BASENAME)
        set( arg_NAME ${arg_BASENAME}DesignerPlugin )
    endif()

    if ( NOT arg_FILES )
        if ( NOT arg_BASENAME )
            MESSAGE( FATAL_ERROR "BASENAME must be set when not setting FILES" )
        else()
            SET( arg_FILES ../${arg_BASENAME}.cpp ../${arg_BASENAME}.h ${arg_BASENAME}DesignerPlugin.h ${arg_BASENAME}DesignerPlugin.cpp )
        endif()
    endif()
    
    MESSAGE( STATUS "Creating Designer Plugin ${arg_NAME} using ${arg_FILES}" )
    if ( arg_LINK_LIBS )
        MESSAGE( STATUS "    LINK_LIBS=${arg_LINK_LIBS}" )
    endif()
    if ( arg_INCLUDE_DIRECTORIES )
        MESSAGE( STATUS "    INCLUDE_DIRECTORIES=${arg_INCLUDE_DIRECTORIES}" )
    endif()
    if ( arg_COMPILER_DEFINES )
        MESSAGE( STATUS "    COMPILER_DEFINES=${arg_COMPILER_DEFINES}" )
    endif()
    project(${arg_NAME} LANGUAGES CXX)
    
    set(CMAKE_AUTOMOC ON)
    set(CMAKE_AUTOUIC ON)
    find_package(Qt6 REQUIRED COMPONENTS Core Gui UiPlugin Widgets)
    qt_add_plugin(${PROJECT_NAME})

    target_sources(${PROJECT_NAME} PRIVATE ${arg_FILES} )

    set_target_properties(${PROJECT_NAME} PROPERTIES
        WIN32_EXECUTABLE TRUE
        MACOSX_BUNDLE TRUE
    )
    target_link_libraries(${PROJECT_NAME} PUBLIC
        Qt::Core
        Qt::Gui
        Qt::UiPlugin
        Qt::Widgets
        ${arg_LINK_LIBS}
    )
    target_compile_definitions( ${PROJECT_NAME} PRIVATE ${arg_COMPILER_DEFINES} )

    set(INSTALL_PLUGINS_DIR "${QT6_INSTALL_PREFIX}/${QT6_INSTALL_PLUGINS}/designer")
    
    install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION "${INSTALL_PLUGINS_DIR}"
        BUNDLE DESTINATION "${INSTALL_PLUGINS_DIR}"
        LIBRARY DESTINATION "${INSTALL_PLUGINS_DIR}"
    )
    if ( arg_INCLUDE_DIRECTORIES )
        target_include_directories( ${PROJECT_NAME} PRIVATE ${arg_INCLUDE_DIRECTORIES} )
    endif()
    set_target_properties( ${PROJECT_NAME} PROPERTIES FOLDER DesignerPlugins )
ENDFUNCTION()
