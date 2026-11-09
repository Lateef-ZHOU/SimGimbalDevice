include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG fa52571d2576c96270ea472ebf00feb38de0acbc)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
