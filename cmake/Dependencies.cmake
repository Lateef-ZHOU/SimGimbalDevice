include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 8ba73dda2080f5d59a5ca710b31dcb3c8f479aed)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
