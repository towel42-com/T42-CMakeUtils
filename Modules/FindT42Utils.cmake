function (PrintList listVar)
    MESSAGE( STATUS "List -> ${listVar}:" )
    foreach(curr ${${listVar}})
        MESSAGE( STATUS "    ${curr}" )
    endforeach()
endfunction()

function(PrintAllVars)
    set( options "")
    set( oneValueArgs PATTERN )
    set( multiValueArgs )
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "${options}" "${oneValueArgs}" "${multiValueArgs}"
    )

    message(STATUS "--- Start of CMake Variables Dump ---")
    get_cmake_property(_variableNames VARIABLES)
    list(SORT _variableNames)
    foreach (_variableName ${_variableNames})
        SET( showVar TRUE )
        if ( arg_PATTERN )
            string( REGEX MATCH ${arg_PATTERN} showVar ${_variableName} )
        endif()
        if ( ${showVar} )
            message(STATUS "${_variableName}=${${_variableName}}")
        endif()
    endforeach()
    message(STATUS "--- End of CMake Variables Dump ---")
endfunction()


## https://stackoverflow.com/questions/32183975/how-to-print-all-the-properties-of-a-target-in-cmake/56738858#56738858
## https://stackoverflow.com/a/56738858/3743145

## Get all properties that cmake supports
function(print_target_properties tgt)
    execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE __CMAKE_PROPERTY_LIST)
    ## Convert command output into a CMake list
    STRING(REGEX REPLACE ";" "\\\\;" __CMAKE_PROPERTY_LIST "${__CMAKE_PROPERTY_LIST}")
    STRING(REGEX REPLACE "\n" ";" __CMAKE_PROPERTY_LIST "${__CMAKE_PROPERTY_LIST}")

    list(REMOVE_DUPLICATES __CMAKE_PROPERTY_LIST)

    if(NOT TARGET ${tgt})
      message("There is no target named '${tgt}'")
      return()
    endif()

    foreach (prop ${__CMAKE_PROPERTY_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
        get_target_property(propval ${tgt} ${prop})
        if (propval)
            message ("${tgt} ${prop} = ${propval}")
        endif()
    endforeach(prop)
endfunction()
