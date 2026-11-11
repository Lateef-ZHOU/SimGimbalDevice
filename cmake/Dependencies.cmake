include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG d2555b638e80278b831540ef90efe922db38101f)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
