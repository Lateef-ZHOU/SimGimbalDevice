include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 1ded68f0e365bba642695ac0584ea4a107ee5a72)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
