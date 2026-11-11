include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 35d6a739f21b9c7b134b31f455948554873dc059)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
