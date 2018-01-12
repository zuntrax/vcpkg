function(install_qt)
    cmake_parse_arguments(_bc "DISABLE_PARALLEL" "" "" ${ARGN})

    if (_bc_DISABLE_PARALLEL)
        set(JOBS "1")
    else()
        set(JOBS "$ENV{NUMBER_OF_PROCESSORS}")
    endif()

    vcpkg_find_acquire_program(JOM)
    vcpkg_find_acquire_program(PYTHON3)
    get_filename_component(PYTHON3_EXE_PATH ${PYTHON3} DIRECTORY)

    set(ENV{PATH} "${PYTHON3_EXE_PATH};$ENV{PATH}")
    set(_path "$ENV{PATH}")

    foreach(BUILDTYPE "release" "debug")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)

            if(BUILDTYPE STREQUAL "debug")
                set(SHORT_BUILDTYPE "dbg")
                set(CURRENT_INSTALLED_BINARY_DIR "${CURRENT_INSTALLED_DIR}/debug/bin")
            else()
                set(SHORT_BUILDTYPE "rel")
                set(CURRENT_INSTALLED_BINARY_DIR "${CURRENT_INSTALLED_DIR}/bin")
            endif()

            set(ENV{PATH} "${CURRENT_INSTALLED_BINARY_DIR};${_path}")
            message(STATUS "Build ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")
            vcpkg_execute_required_process(
                COMMAND ${JOM} /J ${JOBS}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
                LOGNAME build-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
            )
            message(STATUS "Build ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} done")

            message(STATUS "Package ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")
            vcpkg_execute_required_process(
                COMMAND ${JOM} /J ${JOBS} install
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
                LOGNAME package-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
            )
            message(STATUS "Package ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} done")

        endif()
    endforeach()

    set(ENV{PATH} "${_path}")
endfunction()
