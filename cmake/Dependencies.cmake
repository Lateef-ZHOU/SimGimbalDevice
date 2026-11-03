include(FetchContent)
set(HANDLECORE_WITH_SIM_GIMBAL ON)
if(NOT TARGET Lidar::HandleCore)
    FetchContent_Declare(lidar_handle_core
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/HandleCore.git
        GIT_TAG a7278031d226a96748a9646a5399b4f8be1ce9d7)
    FetchContent_MakeAvailable(lidar_handle_core)
endif()
if(NOT TARGET Lidar::SimGimbal)
    message(FATAL_ERROR "Enable HANDLECORE_WITH_SIM_GIMBAL before the first HandleCore configuration")
endif()
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG cdc46f67b84e37f77e954131ac56270e798b64a5)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
