cmake_minimum_required(VERSION 3.10)
project(SaveAliasOld CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(AviUtl2SdkRoot "${CMAKE_CURRENT_SOURCE_DIR}/external/aviutl2-plugin-sdk")
set(AviUtl2SdkIncludeDir "${AviUtl2SdkRoot}/include")
if(NOT EXISTS "${AviUtl2SdkIncludeDir}/aviutl2_sdk/plugin2.h")
    message(FATAL_ERROR
        "AviUtl2 SDK mirror not found. Expected external/aviutl2-plugin-sdk/include/aviutl2_sdk/plugin2.h.")
endif()

if(MSVC)
    add_compile_options(/source-charset:utf-8 /wd4828)
endif()

add_compile_definitions(UNICODE _UNICODE)

add_library(SaveAliasOld SHARED
    src/SaveAliasOld.cpp
)

target_include_directories(SaveAliasOld PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${AviUtl2SdkIncludeDir}
)

target_link_libraries(SaveAliasOld PRIVATE
    shlwapi user32 comdlg32
)

set_target_properties(SaveAliasOld PROPERTIES SUFFIX ".aux2")
set_target_properties(SaveAliasOld PROPERTIES VS_CHARACTER_SET "Unicode")

set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
