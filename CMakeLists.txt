cmake_minimum_required(VERSION 3.16)
project(MkNotes VERSION 0.1 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
find_package(Qt6 REQUIRED COMPONENTS Quick LinguistTools)
qt_standard_project_setup(REQUIRES 6.8)
qt_policy(SET QTP0004 NEW)

qt_add_executable(${CMAKE_PROJECT_NAME}
    src/main.cpp
    src/notesmanager.cpp
    include/notesmanager.h
    resources/icons/icons.qrc
)

set(QML_SINGLETONS
    qml/Singletons/Constants.qml
    qml/Singletons/Context.qml
)

set_source_files_properties(${QML_SINGLETONS}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)


qt_add_qml_module(${CMAKE_PROJECT_NAME}
    URI net.odizinne.mknotes
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/NoteEditor.qml
        qml/NotesList.qml
        qml/NotesModel.qml
        ${QML_SINGLETONS}
)

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
)

qt_add_translations(${CMAKE_PROJECT_NAME}
    TS_FILES
        i18n/MkNotes_en.ts
        i18n/MkNotes_fr.ts
    RESOURCE_PREFIX "/i18n"
    LUPDATE_OPTIONS "-no-obsolete"
)
add_dependencies(${CMAKE_PROJECT_NAME} update_translations)


# Set target properties
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)


# Link libraries
target_link_libraries(${CMAKE_PROJECT_NAME}
    PRIVATE Qt6::Quick
)

# Installation
include(GNUInstallDirs)
install(TARGETS ${CMAKE_PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
