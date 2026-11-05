include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 22448ba3e19db5f151b4a51153b312b65fb9b0fa)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
