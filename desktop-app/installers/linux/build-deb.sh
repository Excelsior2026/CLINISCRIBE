#!/usr/bin/env bash
set -euo pipefail

echo "🐧 Building Debian Package for CliniScribe..."

# Configuration
APP_NAME="cliniscribe"
VERSION="1.0.0"
ARCH="amd64"
BUILD_DIR="$(pwd)/src-tauri/target/release"
DEB_DIR="$(pwd)/installers/linux/deb-build"
OUTPUT_DIR="$(pwd)/installers/output/linux"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Build Tauri app
echo -e "${BLUE}Step 1: Building Tauri application...${NC}"
cd "$(dirname "$0")/../.."
npm run tauri:build
echo -e "${GREEN}✓ Build complete${NC}"

# Step 2: Create DEB structure
echo -e "${BLUE}Step 2: Creating DEB package structure...${NC}"
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR/DEBIAN"
mkdir -p "$DEB_DIR/usr/bin"
mkdir -p "$DEB_DIR/usr/share/applications"
mkdir -p "$DEB_DIR/usr/share/icons/hicolor/128x128/apps"
mkdir -p "$DEB_DIR/usr/share/doc/$APP_NAME"
mkdir -p "$OUTPUT_DIR"

# Step 3: Copy binary
cp "$BUILD_DIR/$APP_NAME" "$DEB_DIR/usr/bin/"
chmod +x "$DEB_DIR/usr/bin/$APP_NAME"
echo -e "${GREEN}✓ Copied binary${NC}"

# Step 4: Create control file
echo -e "${BLUE}Step 3: Creating control file...${NC}"
cat > "$DEB_DIR/DEBIAN/control" << CONTROL
Package: $APP_NAME
Version: $VERSION
Section: education
Priority: optional
Architecture: $ARCH
Maintainer: CliniScribe Team <support@cliniscribe.com>
Depends: libwebkit2gtk-4.0-37, libgtk-3-0
Description: AI-powered study notes for medical students
 CliniScribe transforms lecture recordings into structured study notes
 using AI-powered transcription and summarization.
 .
 Features:
  - High-quality audio transcription
  - AI-generated structured notes
  - Subject-specific summaries
  - 100% offline processing (after initial setup)
Homepage: https://cliniscribe.com
CONTROL
echo -e "${GREEN}✓ Created control file${NC}"

# Step 5: Create .desktop file
echo -e "${BLUE}Step 4: Creating .desktop file...${NC}"
cat > "$DEB_DIR/usr/share/applications/$APP_NAME.desktop" << DESKTOP
[Desktop Entry]
Version=1.0
Type=Application
Name=CliniScribe
Comment=AI-powered study notes for medical students
Exec=/usr/bin/$APP_NAME
Icon=$APP_NAME
Terminal=false
Categories=Education;AudioVideo;
Keywords=medical;education;transcription;notes;ai;
DESKTOP
echo -e "${GREEN}✓ Created .desktop file${NC}"

# Step 6: Create post-install script
cat > "$DEB_DIR/DEBIAN/postinst" << 'POSTINST'
#!/bin/bash
set -e

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database -q
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi

echo "CliniScribe installed successfully!"
echo "Launch from your application menu or run 'cliniscribe' in terminal."

exit 0
POSTINST

chmod +x "$DEB_DIR/DEBIAN/postinst"

# Step 7: Create pre-remove script
cat > "$DEB_DIR/DEBIAN/prerm" << 'PRERM'
#!/bin/bash
set -e

# Stop any running instances
pkill -f cliniscribe || true

exit 0
PRERM

chmod +x "$DEB_DIR/DEBIAN/prerm"

# Step 8: Create post-remove script
cat > "$DEB_DIR/DEBIAN/postrm" << 'POSTRM'
#!/bin/bash
set -e

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database -q
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -q -t -f /usr/share/icons/hicolor || true
fi

exit 0
POSTRM

chmod +x "$DEB_DIR/DEBIAN/postrm"

# Step 9: Create copyright file
cat > "$DEB_DIR/usr/share/doc/$APP_NAME/copyright" << 'COPYRIGHT'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: CliniScribe
Source: https://cliniscribe.com

Files: *
Copyright: 2024 CliniScribe Team
License: Educational-Use

License: Educational-Use
 This software is provided for educational use by medical and nursing students.
 .
 Permission is granted to use this software for personal educational purposes only.
 .
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
COPYRIGHT

# Step 10: Create changelog
cat > "$DEB_DIR/usr/share/doc/$APP_NAME/changelog" << CHANGELOG
cliniscribe ($VERSION) stable; urgency=medium

  * Initial release
  * Audio transcription with Whisper
  * AI-generated study notes with Llama
  * Desktop application with Tauri
  * First-run setup wizard
  * Settings management

 -- CliniScribe Team <support@cliniscribe.com>  $(date -R)
CHANGELOG

gzip -9 "$DEB_DIR/usr/share/doc/$APP_NAME/changelog"

# Step 11: Build the DEB package
echo -e "${BLUE}Step 5: Building DEB package...${NC}"
fakeroot dpkg-deb --build "$DEB_DIR" "$OUTPUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb"
echo -e "${GREEN}✓ DEB package built${NC}"

# Step 12: Get file size
DEB_SIZE=$(du -h "$OUTPUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb" | cut -f1)

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ DEB Package created successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "  📦 Location: $OUTPUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb"
echo "  📊 Size: $DEB_SIZE"
echo ""
echo "To install:"
echo "  sudo dpkg -i \"$OUTPUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb\""
echo "  sudo apt-get install -f  # If dependencies missing"
echo ""
echo "To test:"
echo "  dpkg -c \"$OUTPUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb\"  # List contents"
echo "  lintian \"$OUTPUT_DIR/${APP_NAME}_${VERSION}_${ARCH}.deb\"  # Check quality"
echo ""
