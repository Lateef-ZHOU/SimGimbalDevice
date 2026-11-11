include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG e6c06b8c05d1e83d2102c07c94ed7ccba2e3c1bc)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
