cmake_minimum_required(VERSION 3.8)

# Enable Hot Reload for MSVC compilers if supported.
if (POLICY CMP0141)
  cmake_policy(SET CMP0141 NEW)
  set(CMAKE_MSVC_DEBUG_INFORMATION_FORMAT "$<IF:$<AND:$<C_COMPILER_ID:MSVC>,$<CXX_COMPILER_ID:MSVC>>,$<$<CONFIG:Debug,RelWithDebInfo>:EditAndContinue>,$<$<CONFIG:Debug,RelWithDebInfo>:ProgramDatabase>>")
endif()

project("Baddaria")

# Create 'libraries' directory if it doesn't exist
file(MAKE_DIRECTORY "${CMAKE_SOURCE_DIR}/libraries")

# Define the URL for SFML download
set(SFML_URL "https://github.com/SFML/SFML/releases/download/3.0.0/SFML-3.0.0-windows-vc17-64-bit.zip")
set(SFML_ZIP "${CMAKE_SOURCE_DIR}/libraries/SFML-3.0.0-windows-vc17-64-bit.zip")
set(SFML_EXTRACT_DIR "${CMAKE_SOURCE_DIR}/libraries/SFML-3.0.0")

# Check if SFML folder exists
if (NOT EXISTS ${SFML_EXTRACT_DIR})
  # Download the SFML zip file if not already downloaded
  if (NOT EXISTS ${SFML_ZIP})
    message(STATUS "Downloading SFML...")
    file(DOWNLOAD ${SFML_URL} ${SFML_ZIP})
  endif()

  # Extract the SFML zip file
  message(STATUS "Extracting SFML...")
  execute_process(COMMAND ${CMAKE_COMMAND} -E tar xzf ${SFML_ZIP} WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}/libraries")

  # Delete the downloaded zip file after extraction
  if (EXISTS ${SFML_ZIP})
    message(STATUS "Deleting downloaded SFML zip...")
    file(REMOVE ${SFML_ZIP})
  endif()
endif()

# Add source to this project's executable
add_executable(Baddaria "Baddaria.cpp" "Baddaria.h")

# Include directories for dependencies
target_include_directories(Baddaria PRIVATE
  "${CMAKE_SOURCE_DIR}/libraries/SFML-3.0.0/include"
)

# Set the CMAKE_PREFIX_PATH to search in the root directory's libraries folder
set(CMAKE_PREFIX_PATH "${CMAKE_SOURCE_DIR}/libraries")

#set(SFML_STATIC_LIBRARIES ON)

# Set Ogg_DIR to the path containing OggConfig.cmake
set(Ogg_DIR "${CMAKE_SOURCE_DIR}/libraries/SFML-3.0.0/lib/cmake/Ogg")

# Example: Find SFML
find_package(SFML 3 COMPONENTS System Window Graphics Audio REQUIRED)

# Link SFML static libraries with full paths
target_link_libraries(Baddaria PRIVATE SFML::Graphics SFML::Window SFML::Audio SFML::System)

if (CMAKE_VERSION VERSION_GREATER 3.12)
  set_property(TARGET Baddaria PROPERTY CXX_STANDARD 20)
endif()

# Check if using dynamic libraries (SFML_STATIC_LIBRARIES is OFF)
if (NOT SFML_STATIC_LIBRARIES)
  message(STATUS "Using dynamic libraries. Setting up DLL copying...")

  # Define output directories for different configurations
  set(OUTPUT_DIR_DEBUG "${CMAKE_BINARY_DIR}")
  set(OUTPUT_DIR_RELEASE "${CMAKE_BINARY_DIR}")

# Define the batch script path
set(COPY_DLL_SCRIPT "${CMAKE_SOURCE_DIR}/copy_sfml_dlls.bat")

# Make the batch script executable on Windows
if (WIN32)
  execute_process(COMMAND attrib +x "${COPY_DLL_SCRIPT}")
endif()

# Add a post-build command to run the batch script
add_custom_command(TARGET Baddaria POST_BUILD
  COMMAND "${COPY_DLL_SCRIPT}" "$<CONFIG>" "\"${SFML_EXTRACT_DIR}/bin\"" "\"$<IF:$<CONFIG:Debug>,${OUTPUT_DIR_DEBUG},${OUTPUT_DIR_RELEASE}>\""
  COMMENT "Running batch script to copy SFML DLL files..."
)


endif()

# TODO: Add tests and install targets if needed.
