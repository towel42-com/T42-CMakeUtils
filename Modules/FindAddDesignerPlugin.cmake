# Copyright (C) 2022 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

cmake_minimum_required(VERSION 3.31)
FUNCTION( AddDesignerPlugin )
    set( options "")
    set( oneValueArgs NAME BASENAME)
    set( multiValueArgs FILES )
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
    
    project(${arg_NAME} LANGUAGES CXX)
    
    set(CMAKE_AUTOMOC ON)
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
        Towel42Utils
    )

    set(INSTALL_PLUGINS_DIR "${QT6_INSTALL_PREFIX}/${QT6_INSTALL_PLUGINS}/designer")
    
    install(TARGETS ${PROJECT_NAME}
        RUNTIME DESTINATION "${INSTALL_PLUGINS_DIR}"
        BUNDLE DESTINATION "${INSTALL_PLUGINS_DIR}"
        LIBRARY DESTINATION "${INSTALL_PLUGINS_DIR}"
    )

    set_target_properties( ${PROJECT_NAME} PROPERTIES FOLDER DesignerPlugins )
    #set_target_properties( ${PROJECT_NAME}_autogen PROPERTIES FOLDER DesignerPlugins )
    #set_target_properties( ${PROJECT_NAME}_automoc_json_extraction PROPERTIES FOLDER DesignerPlugins )
ENDFUNCTION()
