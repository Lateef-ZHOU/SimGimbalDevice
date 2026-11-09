include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG e5cb34d5526c17fd751c3e2960e24ab2e994def6)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
