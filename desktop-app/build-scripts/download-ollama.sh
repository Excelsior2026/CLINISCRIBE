#!/usr/bin/env bash
set -euo pipefail

echo "🦙 Downloading Ollama binary..."

# Detect platform and architecture
PLATFORM=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

# Map architecture names
case "$ARCH" in
    x86_64)
        ARCH="amd64"
        ;;
    aarch64|arm64)
        ARCH="arm64"
        ;;
    *)
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Set download URL based on platform
case "$PLATFORM" in
    darwin)
        OLLAMA_URL="https://github.com/ollama/ollama/releases/latest/download/ollama-darwin"
        BINARY_NAME="ollama"
        ;;
    linux)
        OLLAMA_URL="https://github.com/ollama/ollama/releases/latest/download/ollama-linux-${ARCH}"
        BINARY_NAME="ollama"
        ;;
    mingw*|msys*|cygwin*)
        OLLAMA_URL="https://github.com/ollama/ollama/releases/latest/download/ollama-windows-${ARCH}.exe"
        BINARY_NAME="ollama.exe"
        ;;
    *)
        echo "❌ Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

# Create destination directory
DEST_DIR="$(dirname "$0")/../src-tauri/resources/ollama"
mkdir -p "$DEST_DIR"

# Download Ollama
echo "Downloading from: $OLLAMA_URL"
echo "Platform: $PLATFORM, Architecture: $ARCH"

if command -v curl &> /dev/null; then
    curl -L --progress-bar "$OLLAMA_URL" -o "$DEST_DIR/$BINARY_NAME"
elif command -v wget &> /dev/null; then
    wget --show-progress "$OLLAMA_URL" -O "$DEST_DIR/$BINARY_NAME"
else
    echo "❌ Neither curl nor wget found. Please install one of them."
    exit 1
fi

# Make executable (not needed on Windows)
if [ "$PLATFORM" != "mingw" ] && [ "$PLATFORM" != "msys" ] && [ "$PLATFORM" != "cygwin" ]; then
    chmod +x "$DEST_DIR/$BINARY_NAME"
fi

echo "✅ Ollama binary downloaded successfully"
echo "   Location: $DEST_DIR/$BINARY_NAME"
echo "   Size: $(du -sh "$DEST_DIR/$BINARY_NAME" | cut -f1)"

echo ""
echo "Test Ollama:"
echo "  $DEST_DIR/$BINARY_NAME --version"
