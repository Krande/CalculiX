# Define the path to your activation batch file
set(ACTIVATION_SCRIPT "${CMAKE_SOURCE_DIR}/activate_intel.bat")
# Define the list of environment variables to update
set(ENV_VARS_TO_UPDATE PATH INCLUDE LIB)

# Check if the batch file exists
if(EXISTS ${ACTIVATION_SCRIPT})
    # Run the activation script and capture the environment setup
    execute_process(
            COMMAND cmd /c call ${ACTIVATION_SCRIPT} && set
            OUTPUT_VARIABLE ENV_VARS
    )

    # Parse environment variables from the script
    string(REGEX MATCHALL "^[A-Za-z_][A-Za-z0-9_]*=.*" ENV_LINES "${ENV_VARS}")

    foreach(ENV_LINE ${ENV_LINES})
        string(REPLACE "=" ";" ENV_PAIR ${ENV_LINE})
        list(GET ENV_PAIR 0 ENV_VAR_NAME)
        # Skip processing for variables in the skip list
        list(FIND ENV_VARS_TO_SKIP ${ENV_VAR_NAME} ENV_VAR_SKIP_INDEX)
        if(ENV_VAR_SKIP_INDEX GREATER -1)
            continue()
        endif()
        list(GET ENV_PAIR 1 ENV_VAR_VALUE)

        # Check if this environment variable is in the update list
        list(FIND ENV_VARS_TO_UPDATE ${ENV_VAR_NAME} ENV_VAR_INDEX)

        if(ENV_VAR_INDEX GREATER -1)
            # If the environment variable is already set, append the new value
            if(DEFINED ENV{${ENV_VAR_NAME}})
                set(ENV{${ENV_VAR_NAME}} "$ENV{${ENV_VAR_NAME}};${ENV_VAR_VALUE}")
            else()
                # Otherwise, set it to the new value
                set(ENV{${ENV_VAR_NAME}} "${ENV_VAR_VALUE}")
            endif()
        endif()
    endforeach()
else()
    message(FATAL_ERROR "Activation script not found: ${ACTIVATION_SCRIPT}")
endif()

# Set additional compiler options if needed
if(WIN32)
    set(CMAKE_C_COMPILER gcc)
    set(CMAKE_Fortran_COMPILER gfortran)
endif()