include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG 89f1511f0982b8ed7a51348e629e4fa5482c31ca)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
