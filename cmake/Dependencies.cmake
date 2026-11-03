include(FetchContent)
set(TASKCORE_WITH_QML ON)
if(NOT TARGET Lidar::TaskUI)
    FetchContent_Declare(lidar_taskcore
        GIT_REPOSITORY https://github.com/Lateef-ZHOU/TaskCore.git
        GIT_TAG eb5c41cf6261df659bfd012acdc1481e22168abf)
    FetchContent_MakeAvailable(lidar_taskcore)
endif()
