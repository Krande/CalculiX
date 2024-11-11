cmake_minimum_required(VERSION 3.16)
project(CalculiX LANGUAGES C Fortran)

# Set project root and source directories
set(PROJECT_ROOT_DIR ${CMAKE_SOURCE_DIR}/..)
set(SRC_DIR ${PROJECT_ROOT_DIR}/src)


# Set the C and Fortran compilers (adjust if needed for Windows)
if(WIN32)
    set(CMAKE_C_COMPILER cl.exe)
    set(CMAKE_Fortran_COMPILER ifx.exe)
else()
    set(CMAKE_C_COMPILER cc)
    set(CMAKE_Fortran_COMPILER gfortran)
endif()

# Compiler and linker flags for Unix
if(UNIX)
    set(CMAKE_C_FLAGS "-Wall -g -DARCH=\\\"Linux\\\" -DSPOOLES -DARPACK -DMATRIXSTORAGE -DNETWORKOUT")
    set(CMAKE_Fortran_FLAGS "-Wall -g")
    set(LIBS pthread m c)
endif()

# Compiler and linker flags for Windows
if(WIN32)
    string(APPEND CMAKE_C_FLAGS " /nologo /W3 /DARCH=5 /DSPOOLES /DARPACK /DMATRIXSTORAGE /DNETWORKOUT")
    string(APPEND CMAKE_Fortran_FLAGS " /nologo")
    set(LIBS kernel32 user32 gdi32 winspool comdlg32 advapi32 shell32 ole32 oleaut32 uuid odbc32 odbccp32)
endif()

# Define variables for external paths (can be set externally)
set(SPOOLES_INCLUDE_DIR "" CACHE PATH "Path to SPOOLES include directory")
set(LIB_DIR "" CACHE PATH "Path to additional library directory")

# Include directoriesc
include_directories(${SPOOLES_INCLUDE_DIR})

# Source files
set(SCCXMAIN ${SRC_DIR}/CalculiX.c)

file(GLOB SCCXF "${SRC_DIR}/*.f")
file(GLOB SCCXC "${SRC_DIR}/*.c")
file(GLOB SCCXCXX "${SRC_DIR}/*.cpp")

# Convert source files to object files
add_library(OCCXF OBJECT ${SCCXF})
add_library(OCCXC OBJECT ${SCCXC})
add_library(OCCXMAIN OBJECT ${SCCXMAIN})

# Linker flags and libraries
if(UNIX)
    list(APPEND LIBS
            ${LIB_DIR}/spooles.a
            ${LIB_DIR}/libarpack_INTEL.a
    )
elseif(WIN32)
    list(APPEND LIBS
            ${LIB_DIR}/spooles.a
            ${LIB_DIR}/libarpack.dll.a
    )
endif()

# Executable target
add_executable(CalculiX $<TARGET_OBJECTS:OCCXF> $<TARGET_OBJECTS:OCCXC> $<TARGET_OBJECTS:OCCXMAIN>)
target_link_libraries(CalculiX PRIVATE ${LIBS})
if(UNIX)
    target_compile_options(CalculiX PRIVATE -fopenmp)
endif()

# Copy necessary files
add_custom_command(
        TARGET CalculiX
        PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy ${PROJECT_ROOT_DIR}/date.pl ${CMAKE_BINARY_DIR}
)

# Archiving Static Library (Optional: to create CalculiX.a)
add_library(CalculiX_static STATIC $<TARGET_OBJECTS:OCCXF> $<TARGET_OBJECTS:OCCXC>)

# Optional: On Windows, rename the executable to .exe
if(WIN32)
    set_target_properties(CalculiX PROPERTIES SUFFIX ".exe")
endif()