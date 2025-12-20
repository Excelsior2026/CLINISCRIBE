#!/usr/bin/env bash
set -euo pipefail

# CliniScribe Unified Installer Build Script
# Builds installers for all platforms from a single command

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
VERSION="1.0.0"

# Detect current platform
PLATFORM="$(uname -s)"
case "${PLATFORM}" in
    Linux*)     CURRENT_PLATFORM="linux";;
    Darwin*)    CURRENT_PLATFORM="macos";;
    MINGW*|MSYS*|CYGWIN*)    CURRENT_PLATFORM="windows";;
    *)          CURRENT_PLATFORM="unknown";;
esac

# Function to print header
print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                        ║${NC}"
    echo -e "${CYAN}║         ${GREEN}CliniScribe Installer Builder${CYAN}                ║${NC}"
    echo -e "${CYAN}║                                                        ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to print section
print_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to build macOS installers
build_macos() {
    print_section "Building macOS Installers"

    if [ "$CURRENT_PLATFORM" != "macos" ]; then
        echo -e "${YELLOW}⚠️  Warning: Building macOS installers from non-macOS platform${NC}"
        echo -e "${YELLOW}   This may not work correctly. Recommended to build on macOS.${NC}"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping macOS build."
            return
        fi
    fi

    # Build PKG installer
    echo -e "${BLUE}Building .pkg installer...${NC}"
    if [ -f "$SCRIPT_DIR/macos/build-pkg.sh" ]; then
        cd "$PROJECT_ROOT"
        bash "$SCRIPT_DIR/macos/build-pkg.sh"
        echo -e "${GREEN}✓ PKG installer built${NC}"
    else
        echo -e "${RED}✗ build-pkg.sh not found${NC}"
    fi

    # Build DMG
    echo ""
    echo -e "${BLUE}Building .dmg installer...${NC}"
    if [ -f "$SCRIPT_DIR/macos/build-dmg.sh" ]; then
        cd "$PROJECT_ROOT"
        bash "$SCRIPT_DIR/macos/build-dmg.sh"
        echo -e "${GREEN}✓ DMG installer built${NC}"
    else
        echo -e "${RED}✗ build-dmg.sh not found${NC}"
    fi
}

# Function to build Windows installers
build_windows() {
    print_section "Building Windows Installer"

    if [ "$CURRENT_PLATFORM" != "windows" ]; then
        echo -e "${YELLOW}⚠️  Note: Building Windows installer from non-Windows platform${NC}"
        echo -e "${YELLOW}   Ensure NSIS is installed and accessible${NC}"
        echo ""
    fi

    # Check for NSIS
    if ! command_exists makensis && [ "$CURRENT_PLATFORM" = "windows" ]; then
        echo -e "${RED}✗ NSIS not found. Install from: https://nsis.sourceforge.io/${NC}"
        return 1
    fi

    echo -e "${BLUE}Building NSIS installer...${NC}"
    if [ -f "$SCRIPT_DIR/windows/build.bat" ]; then
        cd "$PROJECT_ROOT"
        if [ "$CURRENT_PLATFORM" = "windows" ]; then
            cmd.exe /c "installers\\windows\\build.bat"
        else
            echo -e "${YELLOW}  Skipping Windows build (not on Windows)${NC}"
            echo -e "${YELLOW}  To build on Windows, run: installers\\windows\\build.bat${NC}"
        fi
        echo -e "${GREEN}✓ Windows installer ready${NC}"
    else
        echo -e "${RED}✗ build.bat not found${NC}"
    fi
}

# Function to build Linux installers
build_linux() {
    print_section "Building Linux Installers"

    if [ "$CURRENT_PLATFORM" != "linux" ]; then
        echo -e "${YELLOW}⚠️  Warning: Building Linux installers from non-Linux platform${NC}"
        echo -e "${YELLOW}   This may not work correctly. Recommended to build on Linux.${NC}"
        echo ""
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping Linux build."
            return
        fi
    fi

    # Check for required tools
    if ! command_exists dpkg-deb && [ "$CURRENT_PLATFORM" = "linux" ]; then
        echo -e "${RED}✗ dpkg-deb not found. Install with: sudo apt-get install dpkg${NC}"
        return 1
    fi

    # Build DEB package
    echo -e "${BLUE}Building .deb package...${NC}"
    if [ -f "$SCRIPT_DIR/linux/build-deb.sh" ]; then
        cd "$PROJECT_ROOT"
        bash "$SCRIPT_DIR/linux/build-deb.sh"
        echo -e "${GREEN}✓ DEB package built${NC}"
    else
        echo -e "${RED}✗ build-deb.sh not found${NC}"
    fi
}

# Function to show summary
show_summary() {
    print_section "Build Summary"

    echo -e "${CYAN}Built installers:${NC}"
    echo ""

    # Check macOS outputs
    if [ -d "$PROJECT_ROOT/installers/output/macos" ]; then
        echo -e "${GREEN}macOS:${NC}"
        ls -lh "$PROJECT_ROOT/installers/output/macos/" 2>/dev/null | grep -E '\.(pkg|dmg)$' | awk '{printf "  📦 %-40s %8s\n", $9, $5}' || echo "  (none)"
        echo ""
    fi

    # Check Windows outputs
    if [ -d "$PROJECT_ROOT/installers/output/windows" ]; then
        echo -e "${GREEN}Windows:${NC}"
        ls -lh "$PROJECT_ROOT/installers/output/windows/" 2>/dev/null | grep -E '\.exe$' | awk '{printf "  📦 %-40s %8s\n", $9, $5}' || echo "  (none)"
        echo ""
    fi

    # Check Linux outputs
    if [ -d "$PROJECT_ROOT/installers/output/linux" ]; then
        echo -e "${GREEN}Linux:${NC}"
        ls -lh "$PROJECT_ROOT/installers/output/linux/" 2>/dev/null | grep -E '\.(deb|rpm|AppImage)$' | awk '{printf "  📦 %-40s %8s\n", $9, $5}' || echo "  (none)"
        echo ""
    fi

    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Test each installer on a clean system"
    echo "  2. Generate SHA256 checksums: sha256sum installers/output/*/*/*"
    echo "  3. Create GitHub release and upload installers"
    echo "  4. Update download links on website"
    echo ""
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all              Build installers for all platforms"
    echo "  --macos            Build macOS installers only (.pkg and .dmg)"
    echo "  --windows          Build Windows installer only (.exe)"
    echo "  --linux            Build Linux installers only (.deb)"
    echo "  --current          Build for current platform only"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --all           # Build all installers"
    echo "  $0 --macos         # Build only macOS installers"
    echo "  $0 --current       # Build for detected platform: $CURRENT_PLATFORM"
    echo ""
}

# Main function
main() {
    print_header

    echo -e "${CYAN}Detected platform:${NC} $CURRENT_PLATFORM"
    echo -e "${CYAN}Project root:${NC} $PROJECT_ROOT"
    echo -e "${CYAN}Version:${NC} $VERSION"

    # Parse arguments
    if [ $# -eq 0 ]; then
        echo ""
        echo -e "${YELLOW}No arguments provided. Use --help for usage information.${NC}"
        echo ""
        show_usage
        exit 1
    fi

    BUILD_MACOS=false
    BUILD_WINDOWS=false
    BUILD_LINUX=false

    while [ $# -gt 0 ]; do
        case "$1" in
            --all)
                BUILD_MACOS=true
                BUILD_WINDOWS=true
                BUILD_LINUX=true
                shift
                ;;
            --macos)
                BUILD_MACOS=true
                shift
                ;;
            --windows)
                BUILD_WINDOWS=true
                shift
                ;;
            --linux)
                BUILD_LINUX=true
                shift
                ;;
            --current)
                case "$CURRENT_PLATFORM" in
                    macos) BUILD_MACOS=true;;
                    windows) BUILD_WINDOWS=true;;
                    linux) BUILD_LINUX=true;;
                    *)
                        echo -e "${RED}Unknown platform: $CURRENT_PLATFORM${NC}"
                        exit 1
                        ;;
                esac
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                show_usage
                exit 1
                ;;
        esac
    done

    # Build installers based on flags
    if [ "$BUILD_MACOS" = true ]; then
        build_macos
    fi

    if [ "$BUILD_WINDOWS" = true ]; then
        build_windows
    fi

    if [ "$BUILD_LINUX" = true ]; then
        build_linux
    fi

    # Show summary
    show_summary

    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}║                 Build Complete! 🎉                     ║${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Run main function
main "$@"
