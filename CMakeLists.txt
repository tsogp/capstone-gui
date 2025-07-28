cmake_minimum_required(VERSION 3.16)
project(FullScreen3DView VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(WIN32)
    set(CMAKE_PREFIX_PATH "C:/Qt/6.9.0/mingw_64/lib/cmake") # Adjust this path to your Qt installation
endif()

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Quick3D Test)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appFullScreen3DView
    src/main.cpp
    src/fullscreen3dwindow.cpp
    src/mainwindow.cpp
    src/3d.cpp
    src/boxdata.cpp
)

file(GLOB_RECURSE ASSET_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS assets/*)

qt_add_qml_module(appFullScreen3DView
    URI FullScreen3DView
    VERSION 1.0
    QML_FILES
    qml/FullScreen3DWindow.qml
    qml/Mainscreen.qml
    qml/ThreeDView.qml
    qml/PreviewWindow.qml
    RESOURCES
    ${ASSET_FILES}
    data/pallet.json
    RESOURCE_PREFIX /
)

set_target_properties(appFullScreen3DView PROPERTIES
    MACOSX_BUNDLE TRUE

    # WIN32_EXECUTABLE TRUE
)

target_link_libraries(appFullScreen3DView PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Quick3D
    Qt6::Test
)

target_compile_definitions(appFullScreen3DView PRIVATE
    APP_ORGANIZATION_NAME="Unemployed"
    APP_NAME="ABBQ"
)

include(GNUInstallDirs)
install(TARGETS appFullScreen3DView
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# enable_testing()
# add_subdirectory(tests)