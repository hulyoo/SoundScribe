cmake_minimum_required(VERSION 3.15)
project(soundscribe LANGUAGES CXX)

set(BINARY_NAME "soundscribe")
set(APPLICATION_ID "com.soundscribe.soundscribe")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Configure build
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(flutter)

set(FLUTTER_LIBRARY "${FLUTTER_MANAGED_DIR}/flutter_windows.dll")

# Application build
add_executable(${BINARY_NAME} WIN32
  "main.cpp"
  "flutter_window.cpp"
)
apply_standard_settings(${BINARY_NAME})

target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE app)

# Install
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/bin")
