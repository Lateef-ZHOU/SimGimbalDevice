include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 5e2decd9188671f9029be8134fc0637f5de89636)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
