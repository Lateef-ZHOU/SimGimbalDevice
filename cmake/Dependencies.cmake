include(FetchContent)
set(HANDLECORE_WITH_SIM_GIMBAL ON)
if(NOT TARGET Lidar::HandleCore)
    FetchContent_Declare(lidar_handle_core
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/HandleCore.git
        GIT_TAG 113523f3a40ad2dc7c417d01326688b5bd79a51b)
    FetchContent_MakeAvailable(lidar_handle_core)
endif()
if(NOT TARGET Lidar::SimGimbal)
    message(FATAL_ERROR "Enable HANDLECORE_WITH_SIM_GIMBAL before the first HandleCore configuration")
endif()
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG b836db07c17a5b16d32e7af33758f747a69a8587)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
