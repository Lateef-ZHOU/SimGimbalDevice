include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 6b4258092042f7e655e26109a5bc1140ddbbc983)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
