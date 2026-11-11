include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG db8e54b99f4141b82e1dfec82209d42b2c12d756)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
