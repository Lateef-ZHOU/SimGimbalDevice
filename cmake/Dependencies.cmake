include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG ad721fabdaa68375eb58fcdcae9c6c1ffa1c66e4)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
