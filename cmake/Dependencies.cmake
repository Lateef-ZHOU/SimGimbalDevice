include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG c86f5a3550303736426b0f75c31293e82eaa6698)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
