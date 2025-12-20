#!/usr/bin/env bash
set -euo pipefail

# CliniScribe Model Bundler
# Pre-downloads AI models for offline installation
# This creates a "bundled" installer that includes ~5GB of AI models

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUNDLE_DIR="$PROJECT_ROOT/installers/bundled-models"
WHISPER_DIR="$BUNDLE_DIR/whisper"
OLLAMA_DIR="$BUNDLE_DIR/ollama"

# Model URLs (Hugging Face)
WHISPER_BASE_URL="https://huggingface.co/ggerganov/whisper.cpp/resolve/main"

# Models to download
WHISPER_MODELS=("ggml-base.bin" "ggml-small.bin" "ggml-medium.bin")
OLLAMA_MODELS=("llama3.2:3b")

print_header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}║         ${GREEN}CliniScribe Model Bundler${CYAN}                        ║${NC}"
    echo -e "${CYAN}║                                                           ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

format_bytes() {
    local bytes=$1
    if [ $bytes -lt 1024 ]; then
        echo "${bytes}B"
    elif [ $bytes -lt 1048576 ]; then
        echo "$((bytes / 1024))KB"
    elif [ $bytes -lt 1073741824 ]; then
        echo "$((bytes / 1048576))MB"
    else
        echo "$((bytes / 1073741824))GB"
    fi
}

# Function to download Whisper models
download_whisper_models() {
    print_section "Downloading Whisper Models"

    mkdir -p "$WHISPER_DIR"

    for model in "${WHISPER_MODELS[@]}"; do
        echo -e "${BLUE}Downloading $model...${NC}"

        local url="$WHISPER_BASE_URL/$model"
        local output="$WHISPER_DIR/$model"

        if [ -f "$output" ]; then
            echo -e "${YELLOW}  ⚠️  $model already exists, skipping${NC}"
            continue
        fi

        # Download with progress bar
        if command -v curl >/dev/null 2>&1; then
            curl -L -o "$output" --progress-bar "$url"
        elif command -v wget >/dev/null 2>&1; then
            wget -O "$output" --show-progress "$url"
        else
            echo -e "${RED}  ✗ Error: Neither curl nor wget found${NC}"
            exit 1
        fi

        # Get file size
        if [ -f "$output" ]; then
            local size=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null)
            echo -e "${GREEN}  ✓ Downloaded $model ($(format_bytes $size))${NC}"
        else
            echo -e "${RED}  ✗ Failed to download $model${NC}"
            exit 1
        fi
    done
}

# Function to download Ollama models
download_ollama_models() {
    print_section "Downloading Ollama Models"

    # Check if Ollama is installed
    if ! command -v ollama >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Ollama not found. Installing...${NC}"

        # Download and install Ollama
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "  Downloading Ollama for macOS..."
            curl -fsSL https://ollama.com/install.sh | sh
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "  Downloading Ollama for Linux..."
            curl -fsSL https://ollama.com/install.sh | sh
        else
            echo -e "${RED}  ✗ Unsupported platform for automatic Ollama installation${NC}"
            echo "  Please install Ollama manually: https://ollama.com/download"
            exit 1
        fi
    fi

    # Start Ollama server in background
    echo -e "${BLUE}Starting Ollama server...${NC}"
    ollama serve >/dev/null 2>&1 &
    local OLLAMA_PID=$!
    sleep 3  # Wait for server to start

    mkdir -p "$OLLAMA_DIR"

    # Download each model
    for model in "${OLLAMA_MODELS[@]}"; do
        echo -e "${BLUE}Downloading $model...${NC}"
        echo -e "${YELLOW}  (This may take 5-15 minutes depending on your connection)${NC}"

        # Pull the model
        ollama pull "$model"

        echo -e "${GREEN}  ✓ Downloaded $model${NC}"
    done

    # Export models to files
    echo ""
    echo -e "${BLUE}Exporting Ollama models...${NC}"

    # Get Ollama model directory
    local OLLAMA_MODELS_DIR=""
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OLLAMA_MODELS_DIR="$HOME/.ollama/models"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OLLAMA_MODELS_DIR="$HOME/.ollama/models"
    fi

    # Copy model files
    if [ -d "$OLLAMA_MODELS_DIR" ]; then
        cp -r "$OLLAMA_MODELS_DIR"/* "$OLLAMA_DIR/" 2>/dev/null || true
        echo -e "${GREEN}  ✓ Exported models to bundle directory${NC}"
    else
        echo -e "${YELLOW}  ⚠️  Could not find Ollama models directory${NC}"
        echo -e "${YELLOW}  Models are downloaded but may need manual export${NC}"
    fi

    # Stop Ollama server
    kill $OLLAMA_PID 2>/dev/null || true
}

# Function to create bundle manifest
create_manifest() {
    print_section "Creating Bundle Manifest"

    local manifest_file="$BUNDLE_DIR/MANIFEST.json"

    # Calculate total size
    local total_size=0
    if [ -d "$WHISPER_DIR" ]; then
        total_size=$((total_size + $(du -sb "$WHISPER_DIR" 2>/dev/null | cut -f1 || echo 0)))
    fi
    if [ -d "$OLLAMA_DIR" ]; then
        total_size=$((total_size + $(du -sb "$OLLAMA_DIR" 2>/dev/null | cut -f1 || echo 0)))
    fi

    # Create manifest
    cat > "$manifest_file" << EOF
{
  "version": "1.0.0",
  "created": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "total_size_bytes": $total_size,
  "total_size_human": "$(format_bytes $total_size)",
  "models": {
    "whisper": [
EOF

    # Add Whisper models
    local first=true
    for model in "${WHISPER_MODELS[@]}"; do
        if [ -f "$WHISPER_DIR/$model" ]; then
            local size=$(stat -f%z "$WHISPER_DIR/$model" 2>/dev/null || stat -c%s "$WHISPER_DIR/$model" 2>/dev/null)
            local sha256=$(shasum -a 256 "$WHISPER_DIR/$model" | cut -d' ' -f1)

            if [ "$first" = false ]; then
                echo "," >> "$manifest_file"
            fi
            first=false

            cat >> "$manifest_file" << EOF
      {
        "name": "$model",
        "size_bytes": $size,
        "size_human": "$(format_bytes $size)",
        "sha256": "$sha256"
      }
EOF
        fi
    done

    cat >> "$manifest_file" << EOF

    ],
    "ollama": [
EOF

    # Add Ollama models
    first=true
    for model in "${OLLAMA_MODELS[@]}"; do
        if [ "$first" = false ]; then
            echo "," >> "$manifest_file"
        fi
        first=false

        cat >> "$manifest_file" << EOF
      {
        "name": "$model",
        "status": "downloaded"
      }
EOF
    done

    cat >> "$manifest_file" << EOF

    ]
  }
}
EOF

    echo -e "${GREEN}✓ Created manifest: $manifest_file${NC}"
}

# Function to create bundle archive
create_bundle_archive() {
    print_section "Creating Bundle Archive"

    local archive_name="cliniscribe-models-bundle-1.0.0.tar.gz"
    local archive_path="$PROJECT_ROOT/installers/output/$archive_name"

    mkdir -p "$PROJECT_ROOT/installers/output"

    echo -e "${BLUE}Compressing models...${NC}"
    echo -e "${YELLOW}  (This may take several minutes)${NC}"

    cd "$BUNDLE_DIR"
    tar -czf "$archive_path" ./*

    local archive_size=$(stat -f%z "$archive_path" 2>/dev/null || stat -c%s "$archive_path" 2>/dev/null)
    local sha256=$(shasum -a 256 "$archive_path" | cut -d' ' -f1)

    echo -e "${GREEN}✓ Created archive: $archive_path${NC}"
    echo -e "${GREEN}  Size: $(format_bytes $archive_size)${NC}"
    echo -e "${GREEN}  SHA256: $sha256${NC}"

    # Create checksums file
    echo "$sha256  $archive_name" > "$PROJECT_ROOT/installers/output/SHA256SUMS"
    echo -e "${GREEN}✓ Created checksums file${NC}"
}

# Function to create usage instructions
create_instructions() {
    local instructions_file="$BUNDLE_DIR/USAGE.md"

    cat > "$instructions_file" << 'EOF'
# CliniScribe Bundled Models Usage

This bundle contains pre-downloaded AI models for offline CliniScribe installation.

## Contents

- **Whisper Models**: Speech-to-text models (base, small, medium)
- **Ollama Models**: Llama 3.2 3B for text generation

Total size: ~5GB

## Using the Bundled Models

### During Installation

1. Extract this bundle to your system:
   ```bash
   tar -xzf cliniscribe-models-bundle-1.0.0.tar.gz
   ```

2. Place models in the correct locations:

   **macOS:**
   ```bash
   mkdir -p ~/Library/Application\ Support/com.cliniscribe.app/models
   cp -r whisper/* ~/Library/Application\ Support/com.cliniscribe.app/models/whisper/
   cp -r ollama/* ~/Library/Application\ Support/com.cliniscribe.app/models/ollama/
   ```

   **Linux:**
   ```bash
   mkdir -p ~/.config/cliniscribe/models
   cp -r whisper/* ~/.config/cliniscribe/models/whisper/
   cp -r ollama/* ~/.config/cliniscribe/models/ollama/
   ```

   **Windows:**
   ```cmd
   mkdir %APPDATA%\cliniscribe\models
   xcopy /E /I whisper %APPDATA%\cliniscribe\models\whisper
   xcopy /E /I ollama %APPDATA%\cliniscribe\models\ollama
   ```

3. Install CliniScribe normally. It will detect the pre-installed models and skip downloading.

## For Offline Systems

If installing on a computer without internet:

1. Download this bundle on a computer with internet
2. Transfer via USB drive to the offline computer
3. Extract and place models as shown above
4. Install CliniScribe from the installer
5. Run CliniScribe - it will use the bundled models

## Verification

To verify the models were installed correctly, check:

- Whisper models should be in: `models/whisper/ggml-*.bin`
- Ollama models should be in: `models/ollama/`

CliniScribe will display "✓ Models found" during first run if successful.

## SHA256 Checksums

See MANIFEST.json for individual file checksums.

## Support

For issues with bundled models:
- Check file permissions (should be readable)
- Verify SHA256 checksums match
- Visit: https://cliniscribe.com/docs/offline-installation
EOF

    echo -e "${GREEN}✓ Created usage instructions: $instructions_file${NC}"
}

# Function to show summary
show_summary() {
    print_section "Bundle Summary"

    echo -e "${CYAN}Bundled Models:${NC}"
    echo ""

    if [ -d "$WHISPER_DIR" ]; then
        echo -e "${GREEN}Whisper Models:${NC}"
        for model in "$WHISPER_DIR"/*.bin; do
            if [ -f "$model" ]; then
                local size=$(stat -f%z "$model" 2>/dev/null || stat -c%s "$model" 2>/dev/null)
                local name=$(basename "$model")
                printf "  ✓ %-25s %10s\n" "$name" "$(format_bytes $size)"
            fi
        done
        echo ""
    fi

    if [ -d "$OLLAMA_DIR" ]; then
        echo -e "${GREEN}Ollama Models:${NC}"
        for model in "${OLLAMA_MODELS[@]}"; do
            echo "  ✓ $model"
        done
        echo ""
    fi

    local total_size=$(du -sh "$BUNDLE_DIR" 2>/dev/null | cut -f1 || echo "unknown")
    echo -e "${CYAN}Total bundle size:${NC} $total_size"
    echo ""

    echo -e "${CYAN}Bundle location:${NC} $BUNDLE_DIR"
    echo ""

    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Create bundle archive (optional):"
    echo "     cd $BUNDLE_DIR && tar -czf ../cliniscribe-models-bundle.tar.gz ./*"
    echo ""
    echo "  2. Include with installers or distribute separately"
    echo ""
    echo "  3. See USAGE.md for installation instructions"
    echo ""
}

# Main function
main() {
    print_header

    echo -e "${CYAN}This script will download ~5GB of AI models${NC}"
    echo -e "${CYAN}Estimated time: 15-30 minutes${NC}"
    echo ""
    echo -e "${YELLOW}Make sure you have:${NC}"
    echo "  • Stable internet connection"
    echo "  • At least 10 GB free disk space"
    echo "  • curl or wget installed"
    echo ""

    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Cancelled."
        exit 0
    fi

    # Download models
    download_whisper_models
    download_ollama_models

    # Create manifest and instructions
    create_manifest
    create_instructions

    # Optionally create archive
    echo ""
    read -p "Create compressed archive? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        create_bundle_archive
    fi

    # Show summary
    show_summary

    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}║              Model Bundling Complete! 🎉                  ║${NC}"
    echo -e "${GREEN}║                                                           ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Run main
main "$@"
