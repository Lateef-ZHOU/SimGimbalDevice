include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG c554c7bc934712a5cfd14fe03bb13ff2456367c5)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
