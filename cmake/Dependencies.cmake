include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 2878a9fbbaf7683462dacd8620ddd497ab5f2ed1)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
