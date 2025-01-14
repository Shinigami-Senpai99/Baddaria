cmake_minimum_required(VERSION 3.10)

project("Baddaria")

# Set the output directory for executables and libraries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release)

# For multi-configuration generators (e.g., Visual Studio)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE})

# Create 'libraries' directory if it doesn't exist
file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/libraries")

# Define URLs and file paths for SFML downloads
if (MSVC)
  set(SFML_URL "https://github.com/SFML/SFML/releases/download/3.0.0/SFML-3.0.0-windows-vc17-64-bit.zip")
else()
  set(SFML_URL "https://github.com/SFML/SFML/releases/download/3.0.0/SFML-3.0.0-windows-gcc-14.2.0-mingw-64-bit.zip")
endif()

# Extract the base filename from the URL
get_filename_component(SFML_ZIP_NAME ${SFML_URL} NAME)
set(SFML_ZIP "${CMAKE_SOURCE_DIR}/libraries/${SFML_ZIP_NAME}")
set(SFML_EXTRACT_DIR "${CMAKE_SOURCE_DIR}/libraries/SFML-3.0.0")

# Check if SFML is already extracted
if (NOT EXISTS ${SFML_EXTRACT_DIR})
  message(STATUS "SFML directory not found. Checking download status...")

  # Download the SFML zip file if it doesn't exist
  if (NOT EXISTS ${SFML_ZIP})
    message(STATUS "Downloading SFML from ${SFML_URL}...")
    file(DOWNLOAD ${SFML_URL} ${SFML_ZIP} SHOW_PROGRESS)
  else()
    message(STATUS "SFML zip file already downloaded.")
  endif()

  # Extract the SFML zip file
  message(STATUS "Extracting SFML...")
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xzf ${SFML_ZIP}
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/libraries"
  )

  # Delete the zip file after extraction
  if (EXISTS ${SFML_ZIP})
    message(STATUS "Deleting downloaded SFML zip...")
    file(REMOVE ${SFML_ZIP})
  endif()
else()
  message(STATUS "SFML is already extracted in ${SFML_EXTRACT_DIR}.")
endif()

# Add source to this project's executable
add_executable(Baddaria "Baddaria.cpp" "Baddaria.h")

# Include directories for dependencies
target_include_directories(Baddaria PRIVATE
  "${SFML_EXTRACT_DIR}/include"
)

# Set the CMAKE_PREFIX_PATH to search in the root directory's libraries folder
set(CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/libraries")

set(SFML_STATIC_LIBRARIES OFF)

# Set Ogg_DIR to the path containing OggConfig.cmake
set(Ogg_DIR "${CMAKE_SOURCE_DIR}/libraries/SFML-3.0.0/lib/cmake/Ogg")

# Find SFML package
find_package(SFML 3 COMPONENTS System Window Graphics Audio REQUIRED)

# Link SFML libraries
target_link_libraries(Baddaria PRIVATE SFML::Graphics SFML::Window SFML::Audio SFML::System)

# Set C++ standard
if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET Baddaria PROPERTY CXX_STANDARD 20)
endif()

# Check if using dynamic libraries (SFML_STATIC_LIBRARIES is OFF)
if (NOT SFML_STATIC_LIBRARIES)
  message(STATUS "Using dynamic libraries. Setting up DLL copying...")

  # Define output directories for different configurations
  set(OUTPUT_DIR_DEBUG "${CMAKE_BINARY_DIR}/Debug")
  set(OUTPUT_DIR_RELEASE "${CMAKE_BINARY_DIR}/Release")

# Define the batch script path
set(COPY_DLL_SCRIPT "${CMAKE_SOURCE_DIR}/copy_sfml_dlls.bat")

# Make the batch script executable on Windows
if (WIN32)
  execute_process(COMMAND attrib +x "${COPY_DLL_SCRIPT}")
endif()

# Add a post-build command to run the batc h script
add_custom_command(TARGET Baddaria POST_BUILD
  COMMAND "${COPY_DLL_SCRIPT}" "$<CONFIG>" "\"${SFML_EXTRACT_DIR}/bin\"" "\"$<IF:$<CONFIG:Debug>,${OUTPUT_DIR_DEBUG},${OUTPUT_DIR_RELEASE}>\""
  COMMENT "Running batch script to copy SFML DLL files..."
)
endif()

# Compiler-specific configurations
if (MSVC)
  message(STATUS "Using MSVC compiler...")
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "ProgramDatabase")
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  message(STATUS "Using MinGW compiler...")
else()
  message(STATUS "Using an unknown compiler.")
endif()
