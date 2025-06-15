#!/bin/sh
set -e

echo "Shell: $SHELL"
echo "User: $USER"
echo "Current directory: $(pwd)"
echo "Running pre-commit hook from: ${BASH_SOURCE[0]}"

# === CONFIG ===
BUILD_DIR="build"
CMAKE_FLAGS="-DCMAKE_BUILD_TYPE=Debug"
SRC_DIRS=("src" "qml")  # Only format-check C++/QML related files
CLANG_FORMAT_EXEC="clang-format"
FORMAT_EXTENSIONS=("*.cpp" "*.c" "*.h")  # Extend if needed

echo "Checking formatting with clang-format..."

UNFORMATTED_FILES=()

for dir in "${SRC_DIRS[@]}"; do
    for ext in "${FORMAT_EXTENSIONS[@]}"; do
        for file in $(find "$dir" -type f -name "$ext"); do
            diff_output=$($CLANG_FORMAT_EXEC -style=file "$file" | diff -u "$file" - || true)
            if [ -n "$diff_output" ]; then
                echo "File not formatted: $file"
                UNFORMATTED_FILES+=("$file")
            fi
        done
    done
done

if [ ${#UNFORMATTED_FILES[@]} -ne 0 ]; then
    echo "Commit aborted: some files are not clang-formatted."
    echo "Please run: clang-format -i <file>"
    exit 1
fi

echo "Formatting OK."

# # === BUILD CHECK ===
# echo "Building project to verify..."

# # Optional: clean build folder
# rm -rf "$BUILD_DIR"
# mkdir "$BUILD_DIR"
# cd "$BUILD_DIR"

# if ! cmake $CMAKE_FLAGS ..; then
#     echo "CMake configuration failed"
#     exit 1
# fi

# if ! cmake --build .; then
#     echo "Build failed"
#     exit 1
# fi

# echo "Build succeeded."

# === TESTS (Optional) ===
echo "Running tests (if defined)..."
if ctest --output-on-failure; then
    echo "All tests passed."
else
    echo "Some tests failed."
    exit 1
fi

echo "All pre-commit checks passed."
exit 0
