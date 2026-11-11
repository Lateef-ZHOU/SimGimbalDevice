include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 2a37a90543cbd8ce9d79c6dd5195b07a3ddbcc93)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
