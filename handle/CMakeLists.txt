cmake_minimum_required(VERSION 3.28)
project(SimGimbalDeviceHandle LANGUAGES CXX)
find_package(Qt6 6.8.3 REQUIRED COMPONENTS Core)
include(FetchContent)
if(NOT TARGET Lidar::HandleCore)
    FetchContent_Declare(lidar_handle_core
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/HandleCore.git
        GIT_TAG 7ad9b380fe8d58cdb00a97107e06a96f6f4ba9b0)
    FetchContent_MakeAvailable(lidar_handle_core)
endif()
add_library(HandleSimGimbal STATIC)
set_target_properties(HandleSimGimbal PROPERTIES AUTOMOC ON)
if(MSVC)
    target_compile_options(HandleSimGimbal PRIVATE /W4)
endif()
add_library(Lidar::SimGimbal ALIAS HandleSimGimbal)
target_sources(HandleSimGimbal PRIVATE
    "${CMAKE_CURRENT_LIST_DIR}/../include/SimGimbalHandle.h"
    "${CMAKE_CURRENT_LIST_DIR}/../include/SimGimbalProtocol.h"
    "${CMAKE_CURRENT_LIST_DIR}/../include/GimbalMotion.h")
target_link_libraries(HandleSimGimbal PUBLIC Lidar::HandleCore)
target_include_directories(HandleSimGimbal PUBLIC "${CMAKE_CURRENT_LIST_DIR}/../include")

if(PROJECT_IS_TOP_LEVEL)
    include(CTest)
    if(BUILD_TESTING)
        add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/../tests/handle" tests)
    endif()
endif()
