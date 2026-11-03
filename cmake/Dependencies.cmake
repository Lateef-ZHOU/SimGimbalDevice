include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 21214a4e639e213e99d678265628e1c89b98aab3)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
