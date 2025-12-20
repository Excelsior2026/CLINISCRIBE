#!/usr/bin/env bash
set -euo pipefail

echo "🍎 Building macOS PKG Installer for CliniScribe..."

# Configuration
APP_NAME="CliniScribe"
VERSION="1.0.0"
BUNDLE_ID="com.cliniscribe.app"
BUILD_DIR="$(pwd)/src-tauri/target/release/bundle/macos"
PKG_DIR="$(pwd)/installers/macos/pkg-build"
OUTPUT_DIR="$(pwd)/installers/output/macos"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Configuration:${NC}"
echo "  App Name: $APP_NAME"
echo "  Version: $VERSION"
echo "  Build Dir: $BUILD_DIR"
echo ""

# Step 1: Build the Tauri app first
echo -e "${BLUE}Step 1: Building Tauri application...${NC}"
cd "$(dirname "$0")/../.."
npm run tauri:build
echo -e "${GREEN}✓ Tauri build complete${NC}"

# Step 2: Verify .app exists
if [ ! -d "$BUILD_DIR/$APP_NAME.app" ]; then
    echo "❌ Error: $APP_NAME.app not found at $BUILD_DIR"
    exit 1
fi
echo -e "${GREEN}✓ Found $APP_NAME.app${NC}"

# Step 3: Create PKG structure
echo -e "${BLUE}Step 2: Creating PKG structure...${NC}"
rm -rf "$PKG_DIR"
mkdir -p "$PKG_DIR/payload/Applications"
mkdir -p "$PKG_DIR/scripts"
mkdir -p "$OUTPUT_DIR"

# Copy app to payload
cp -R "$BUILD_DIR/$APP_NAME.app" "$PKG_DIR/payload/Applications/"
echo -e "${GREEN}✓ Copied app to PKG payload${NC}"

# Step 4: Create post-install script
echo -e "${BLUE}Step 3: Creating post-install script...${NC}"
cat > "$PKG_DIR/scripts/postinstall" << 'POSTINSTALL'
#!/bin/bash

# Post-installation script for CliniScribe
APP_PATH="/Applications/CliniScribe.app"

echo "Running CliniScribe post-installation..."

# Set proper permissions
chmod -R 755 "$APP_PATH"
chown -R root:wheel "$APP_PATH"

# Remove quarantine attribute (only if not code-signed)
xattr -cr "$APP_PATH" 2>/dev/null || true

# Create application support directory
USER_HOME=$(eval echo ~$SUDO_USER)
mkdir -p "$USER_HOME/Library/Application Support/com.cliniscribe.app"
chown -R $SUDO_USER:staff "$USER_HOME/Library/Application Support/com.cliniscribe.app"

echo "CliniScribe installation complete!"
echo "You can find CliniScribe in your Applications folder."

# Optional: Open app automatically
# open -a "$APP_PATH"

exit 0
POSTINSTALL

chmod +x "$PKG_DIR/scripts/postinstall"
echo -e "${GREEN}✓ Created post-install script${NC}"

# Step 5: Build the PKG
echo -e "${BLUE}Step 4: Building PKG installer...${NC}"

pkgbuild \
    --root "$PKG_DIR/payload" \
    --identifier "$BUNDLE_ID" \
    --version "$VERSION" \
    --scripts "$PKG_DIR/scripts" \
    --install-location "/" \
    "$PKG_DIR/CliniScribe-component.pkg"

echo -e "${GREEN}✓ Built component package${NC}"

# Step 6: Create distribution XML
echo -e "${BLUE}Step 5: Creating distribution package...${NC}"
cat > "$PKG_DIR/distribution.xml" << DISTRIBUTION
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
    <title>CliniScribe</title>
    <organization>com.cliniscribe</organization>
    <domains enable_localSystem="true"/>
    <options customize="never" require-scripts="true" rootVolumeOnly="true" />

    <!-- Welcome -->
    <welcome file="welcome.html" mime-type="text/html" />

    <!-- License -->
    <license file="license.txt" mime-type="text/plain" />

    <!-- README -->
    <readme file="readme.html" mime-type="text/html" />

    <!-- Conclusion -->
    <conclusion file="conclusion.html" mime-type="text/html" />

    <!-- Background -->
    <background file="background.png" mime-type="image/png" alignment="bottomleft" scaling="proportional"/>

    <choices-outline>
        <line choice="default">
            <line choice="com.cliniscribe.app"/>
        </line>
    </choices-outline>

    <choice id="default"/>
    <choice id="com.cliniscribe.app" visible="false">
        <pkg-ref id="com.cliniscribe.app"/>
    </choice>

    <pkg-ref id="com.cliniscribe.app" version="$VERSION" onConclusion="none">CliniScribe-component.pkg</pkg-ref>
</installer-gui-script>
DISTRIBUTION

# Step 7: Create welcome HTML
cat > "$PKG_DIR/welcome.html" << 'WELCOME'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; padding: 20px; }
        h1 { color: #2563eb; }
        .highlight { background: linear-gradient(to right, #2563eb, #0d9488); -webkit-background-clip: text; -webkit-text-fill-color: transparent; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Welcome to <span class="highlight">CliniScribe</span></h1>
    <p>This installer will guide you through installing CliniScribe on your Mac.</p>
    <p><strong>CliniScribe</strong> is an AI-powered tool that transforms lecture recordings into structured study notes for medical and nursing students.</p>
    <h3>What you'll get:</h3>
    <ul>
        <li>🎙️ High-quality audio transcription</li>
        <li>📝 AI-generated study notes</li>
        <li>🔒 100% private - everything runs locally</li>
        <li>⚡ Fast and easy to use</li>
    </ul>
    <p><strong>Installation size:</strong> ~600 MB</p>
    <p><strong>First run:</strong> Will download AI models (~5 GB, one-time only)</p>
</body>
</html>
WELCOME

# Step 8: Create license
cat > "$PKG_DIR/license.txt" << 'LICENSE'
CliniScribe License Agreement

Copyright (c) 2024 CliniScribe

Educational Use License

This software is provided for educational use by medical and nursing students.

Permission is granted to use this software for personal educational purposes only.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
LICENSE

# Step 9: Create README
cat > "$PKG_DIR/readme.html" << 'README'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; padding: 20px; }
        h2 { color: #2563eb; }
        code { background: #f3f4f6; padding: 2px 6px; border-radius: 4px; }
    </style>
</head>
<body>
    <h2>System Requirements</h2>
    <ul>
        <li>macOS 10.15 (Catalina) or later</li>
        <li>8 GB RAM (16 GB recommended)</li>
        <li>10 GB free disk space (for AI models)</li>
        <li>Internet connection (for first-time setup)</li>
    </ul>

    <h2>What happens during installation?</h2>
    <p>CliniScribe will be installed to your <code>/Applications</code> folder.</p>

    <h2>After installation</h2>
    <ol>
        <li>Open CliniScribe from your Applications folder or Launchpad</li>
        <li>Complete the first-run setup wizard</li>
        <li>AI models will download automatically (5-15 minutes)</li>
        <li>Start processing your lecture recordings!</li>
    </ol>

    <h2>Need help?</h2>
    <p>Visit <a href="https://cliniscribe.com/docs">cliniscribe.com/docs</a></p>
</body>
</html>
README

# Step 10: Create conclusion
cat > "$PKG_DIR/conclusion.html" << 'CONCLUSION'
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; padding: 20px; }
        h1 { color: #10b981; }
    </style>
</head>
<body>
    <h1>Installation Complete! 🎉</h1>
    <p>CliniScribe has been successfully installed.</p>

    <h3>Next steps:</h3>
    <ol>
        <li>Open <strong>CliniScribe</strong> from your Applications folder</li>
        <li>Follow the setup wizard to download AI models</li>
        <li>Start transforming your lectures into study notes!</li>
    </ol>

    <p><strong>Tip:</strong> The first run will download ~5 GB of AI models. This is a one-time process and takes 5-15 minutes depending on your internet speed.</p>

    <p>Happy studying! 🎓💙</p>
</body>
</html>
CONCLUSION

echo -e "${GREEN}✓ Created installer resources${NC}"

# Step 11: Build final PKG
productbuild \
    --distribution "$PKG_DIR/distribution.xml" \
    --package-path "$PKG_DIR" \
    --resources "$PKG_DIR" \
    "$OUTPUT_DIR/$APP_NAME-$VERSION-Installer.pkg"

echo -e "${GREEN}✓ Built distribution package${NC}"

# Step 12: Sign the PKG (optional, requires Developer ID)
if [ -n "${DEVELOPER_ID_INSTALLER:-}" ]; then
    echo -e "${BLUE}Step 6: Signing PKG...${NC}"
    productsign \
        --sign "$DEVELOPER_ID_INSTALLER" \
        "$OUTPUT_DIR/$APP_NAME-$VERSION-Installer.pkg" \
        "$OUTPUT_DIR/$APP_NAME-$VERSION-Installer-Signed.pkg"
    mv "$OUTPUT_DIR/$APP_NAME-$VERSION-Installer-Signed.pkg" "$OUTPUT_DIR/$APP_NAME-$VERSION-Installer.pkg"
    echo -e "${GREEN}✓ PKG signed${NC}"
else
    echo -e "${BLUE}Skipping code signing (DEVELOPER_ID_INSTALLER not set)${NC}"
fi

# Step 13: Get file size
PKG_SIZE=$(du -h "$OUTPUT_DIR/$APP_NAME-$VERSION-Installer.pkg" | cut -f1)

echo ""
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ PKG Installer created successfully!${NC}"
echo -e "${GREEN}════════════════════════════════════════${NC}"
echo ""
echo "  📦 Location: $OUTPUT_DIR/$APP_NAME-$VERSION-Installer.pkg"
echo "  📊 Size: $PKG_SIZE"
echo ""
echo "Next steps:"
echo "  1. Test: sudo installer -pkg \"$OUTPUT_DIR/$APP_NAME-$VERSION-Installer.pkg\" -target /"
echo "  2. Verify: ls /Applications/CliniScribe.app"
echo "  3. Launch: open /Applications/CliniScribe.app"
echo ""
echo "For distribution:"
echo "  - Upload to GitHub Releases"
echo "  - Or notarize with: xcrun notarytool submit ..."
echo ""
