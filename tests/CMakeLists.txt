add_executable(tests
    testassetsload.cpp
)

find_package(Qt6 REQUIRED COMPONENTS Core Test)

file(GLOB_RECURSE ASSET_FILES RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} CONFIGURE_DEPENDS assets/*)
qt_add_qml_module(tests
    URI FullScreen3DView
    VERSION 1.0
    QML_FILES
        ../qml/FullScreen3DWindow.qml
        ../qml/Mainscreen.qml
    RESOURCES
        ${ASSET_FILES}
    RESOURCE_PREFIX /
)

target_link_libraries(tests PRIVATE Qt6::Core Qt6::Test)

add_test(NAME TestAssetsLoad COMMAND tests)
