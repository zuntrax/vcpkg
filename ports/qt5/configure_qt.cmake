function(configure_qt)
    cmake_parse_arguments(_csc "" "SOURCE_PATH;PLATFORM" "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE" ${ARGN})

    if (_csc_PLATFORM)
        set(PLATFORM ${_csc_PLATFORM})
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v140")
        set(PLATFORM "win32-msvc2015")
    elseif(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(PLATFORM "win32-msvc2017")
    endif()

    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    set(ENV{PATH} "$ENV{PATH};${PERL_EXE_PATH}")

    if(DEFINED VCPKG_CRT_LINKAGE AND VCPKG_CRT_LINKAGE STREQUAL static)
        list(APPEND _csc_OPTIONS
            "-static"
            "-static-runtime"
        )
    endif()

    foreach(BUILDTYPE "release" "debug")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL BUILDTYPE)

            if(BUILDTYPE STREQUAL "debug")
                set(SHORT_BUILDTYPE "dbg")
                set(CURRENT_PACKAGES_BUILDTYPE_DIR "${CURRENT_PACKAGES_DIR}/debug")
                set(BUILDTYPE_csc_OPTIONS ${_csc_OPTIONS_DEBUG})
            else()
                set(SHORT_BUILDTYPE "rel")
                set(CURRENT_PACKAGES_BUILDTYPE_DIR "${CURRENT_PACKAGES_DIR}")
                set(BUILDTYPE_csc_OPTIONS ${_csc_OPTIONS_RELEASE})
            endif()

            message(STATUS "Configuring ${TARGET_TRIPLET}-${SHORT_BUILDTYPE}")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE})
            vcpkg_execute_required_process(
                COMMAND "${_csc_SOURCE_PATH}/configure.bat" ${_csc_OPTIONS} ${BUILDTYPE_csc_OPTIONS}
                    -${BUILDTYPE}
                    -prefix ${CURRENT_PACKAGES_BUILDTYPE_DIR}
                    -hostbindir ${CURRENT_PACKAGES_BUILDTYPE_DIR}/tools/qt5
                    -archdatadir ${CURRENT_PACKAGES_BUILDTYPE_DIR}/share/qt5
                    -datadir ${CURRENT_PACKAGES_BUILDTYPE_DIR}/share/qt5
                    -plugindir ${CURRENT_PACKAGES_BUILDTYPE_DIR}/plugins
                    -qmldir ${CURRENT_PACKAGES_BUILDTYPE_DIR}/qml
                    -I ${CURRENT_INSTALLED_DIR}/include
                    -L ${CURRENT_INSTALLED_DIR}/lib
                    -platform ${PLATFORM}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
                LOGNAME config-${TARGET_TRIPLET}-${SHORT_BUILDTYPE}
            )
            message(STATUS "Configuring ${TARGET_TRIPLET}-${SHORT_BUILDTYPE} done")

        endif()
    endforeach()
endfunction()
