cmake_minimum_required(VERSION 3.19)

project(kitana-quickshell-cava VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(KITANA_QML_INSTALL_DIR "lib/kitana/qml" CACHE STRING "Kitana QML module install directory relative to CMAKE_INSTALL_PREFIX")

find_package(Qt6 REQUIRED COMPONENTS Core Qml)
find_package(PkgConfig REQUIRED)

pkg_check_modules(Cava IMPORTED_TARGET libcava QUIET)
if(NOT Cava_FOUND)
  pkg_check_modules(Cava IMPORTED_TARGET cava REQUIRED)
endif()

pkg_check_modules(PipeWire IMPORTED_TARGET libpipewire-0.3 REQUIRED)

qt_standard_project_setup(REQUIRES 6.9)
set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml")

qt_add_qml_module(kitana_cava
  URI Kitana.Cava
  VERSION 1.0
  SOURCES
    src/audiocollector.cpp
    src/audiocollector.hpp
    src/cavaprovider.cpp
    src/cavaprovider.hpp
)

target_link_libraries(kitana_cava
  PRIVATE
    Qt6::Core
    Qt6::Qml
    PkgConfig::Cava
    PkgConfig::PipeWire
)

target_include_directories(kitana_cava
  PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/src"
)

qt_query_qml_module(kitana_cava
  TARGET_PATH module_target_path
  PLUGIN_TARGET module_plugin_target
  QMLDIR module_qmldir
  TYPEINFO module_typeinfo
)

set(module_install_dir "${KITANA_QML_INSTALL_DIR}/${module_target_path}")

install(TARGETS kitana_cava "${module_plugin_target}"
  LIBRARY DESTINATION "${module_install_dir}"
  RUNTIME DESTINATION "${module_install_dir}"
)

install(FILES "${module_qmldir}" "${module_typeinfo}"
  DESTINATION "${module_install_dir}"
)

set_property(TARGET kitana_cava APPEND PROPERTY INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
set_property(TARGET "${module_plugin_target}" APPEND PROPERTY INSTALL_RPATH "$ORIGIN;${CMAKE_INSTALL_PREFIX}/lib")
