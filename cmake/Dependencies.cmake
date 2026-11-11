include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 114e28efd9bbc698da530b55c7c56fdf600f71f4)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
