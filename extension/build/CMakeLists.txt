# RUN cmake . -G "Visual Studio 14 2015"

cmake_minimum_required (VERSION 3.2)
PROJECT (ark_stats_extension)

SET(SOURCES
    ../include/Extension.h
    ../include/IdGenerator.h
    ../src/Extension.cpp
    ../src/main.cpp
)

SET(POCO_HOME "c:/dev/c++/poco-1.7.2-all")

INCLUDE_DIRECTORIES(../include)
INCLUDE_DIRECTORIES(${POCO_HOME}/Foundation/include)
INCLUDE_DIRECTORIES(${POCO_HOME}/Data/include)
INCLUDE_DIRECTORIES(${POCO_HOME}/Data/MySQL/include)

LINK_DIRECTORIES(${POCO_HOME}/lib)

ADD_EXECUTABLE(ark_stats_extension_console ${SOURCES})
TARGET_COMPILE_DEFINITIONS(ark_stats_extension_console PRIVATE ARK_STATS_CONSOLE)

ADD_LIBRARY(ark_stats_extension SHARED ${SOURCES})
