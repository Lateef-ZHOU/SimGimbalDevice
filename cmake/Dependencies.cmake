include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG ebb865f1b57f5c4d7bcba2af1fc7f69747adfe8d)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
