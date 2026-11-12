include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 8e0b9e1781960df0d25748ef4838f5b47e763d90)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
