include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG fd02f360ed6a9146851720e9ed77bb6f62e51b31)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
