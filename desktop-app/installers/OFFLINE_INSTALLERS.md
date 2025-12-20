# Offline Installer Guide

This guide explains how to create "bundled" installers that include pre-downloaded AI models for completely offline installation.

## 📋 Table of Contents

- [Overview](#overview)
- [Why Offline Installers?](#why-offline-installers)
- [Creating Model Bundles](#creating-model-bundles)
- [Platform-Specific Integration](#platform-specific-integration)
  - [macOS PKG with Bundled Models](#macos-pkg-with-bundled-models)
  - [Windows NSIS with Bundled Models](#windows-nsis-with-bundled-models)
  - [Linux DEB with Bundled Models](#linux-deb-with-bundled-models)
- [Distribution Strategies](#distribution-strategies)
- [Testing Offline Installers](#testing-offline-installers)

## 🎯 Overview

**Standard Installer:**
- Size: ~50-100 MB
- Downloads 5GB of models on first run
- Requires internet connection for first use
- 5-15 minute first-run setup

**Offline Installer:**
- Size: ~5.1 GB
- Includes all AI models pre-bundled
- No internet required after download
- Immediate use after installation

## 🤔 Why Offline Installers?

Use cases for bundled offline installers:

1. **Medical Schools with Limited Internet**
   - Many students in areas with slow/unreliable internet
   - One-time download, distribute via USB drives
   - IT departments can deploy to lab computers

2. **Air-Gapped Systems**
   - Secure environments with no internet access
   - Research facilities with security requirements
   - Privacy-focused users

3. **Bulk Deployment**
   - IT administrators installing on multiple machines
   - Classroom deployments
   - Reduces network load

4. **Developing Regions**
   - Areas with metered/expensive internet
   - Intermittent connectivity
   - Low bandwidth environments

## 🏗️ Creating Model Bundles

### Step 1: Run the Bundle Script

```bash
cd installers
./bundle-models.sh
```

This will:
1. Download Whisper models (~1.5 GB)
2. Download Ollama models (~3.5 GB)
3. Create manifest and checksums
4. Optionally create compressed archive

**Output:**
```
installers/bundled-models/
├── whisper/
│   ├── ggml-base.bin      (~150 MB)
│   ├── ggml-small.bin     (~500 MB)
│   └── ggml-medium.bin    (~1.5 GB)
├── ollama/
│   └── [model files]      (~3.5 GB)
├── MANIFEST.json
└── USAGE.md
```

### Step 2: Verify the Bundle

Check the manifest:
```bash
cat installers/bundled-models/MANIFEST.json
```

Verify checksums:
```bash
cd installers/bundled-models
shasum -a 256 -c ../output/SHA256SUMS
```

## 🖥️ Platform-Specific Integration

### macOS PKG with Bundled Models

#### Method 1: Include in PKG Payload

Modify `installers/macos/build-pkg.sh`:

```bash
# After Step 3 (Create PKG structure), add:

echo -e "${BLUE}Step 3.5: Adding bundled models...${NC}"

# Create models directory in payload
mkdir -p "$PKG_DIR/payload/Applications/CliniScribe.app/Contents/Resources/models"

# Copy bundled models
if [ -d "$PROJECT_ROOT/installers/bundled-models" ]; then
    cp -R "$PROJECT_ROOT/installers/bundled-models/whisper" \
          "$PKG_DIR/payload/Applications/CliniScribe.app/Contents/Resources/models/"
    cp -R "$PROJECT_ROOT/installers/bundled-models/ollama" \
          "$PKG_DIR/payload/Applications/CliniScribe.app/Contents/Resources/models/"
    echo -e "${GREEN}✓ Bundled models included${NC}"
else
    echo -e "${YELLOW}⚠️  Bundled models not found, creating standard installer${NC}"
fi
```

Update the post-install script:

```bash
cat > "$PKG_DIR/scripts/postinstall" << 'POSTINSTALL'
#!/bin/bash
set -e

APP_PATH="/Applications/CliniScribe.app"
USER_HOME=$(eval echo ~$SUDO_USER)
USER_MODELS_DIR="$USER_HOME/Library/Application Support/com.cliniscribe.app/models"

# Copy bundled models to user directory
if [ -d "$APP_PATH/Contents/Resources/models" ]; then
    echo "Installing bundled models..."
    mkdir -p "$USER_MODELS_DIR"
    cp -R "$APP_PATH/Contents/Resources/models/"* "$USER_MODELS_DIR/"
    chown -R $SUDO_USER:staff "$USER_MODELS_DIR"
    echo "✓ Models installed (offline ready)"
fi

exit 0
POSTINSTALL
```

#### Method 2: Separate Model PKG

Create a separate installer for models:

```bash
#!/bin/bash
# build-models-pkg.sh

pkgbuild \
    --root "$PROJECT_ROOT/installers/bundled-models" \
    --identifier "com.cliniscribe.models" \
    --version "1.0.0" \
    --install-location "/Library/Application Support/CliniScribe/Models" \
    "CliniScribe-Models-1.0.0.pkg"
```

Users install both:
```bash
sudo installer -pkg CliniScribe-1.0.0-Installer.pkg -target /
sudo installer -pkg CliniScribe-Models-1.0.0.pkg -target /
```

### Windows NSIS with Bundled Models

Modify `installers/windows/cliniscribe.nsi`:

```nsis
Section "Main Application" SecMain
    SetOutPath "$INSTDIR"

    ; Copy application files
    File /r "..\..\src-tauri\target\release\bundle\msi\*"

    ; Copy bundled models if available
    IfFileExists "..\..\installers\bundled-models\*.*" 0 +3
        SetOutPath "$INSTDIR\models"
        File /r "..\..\installers\bundled-models\*.*"

    ; Create shortcuts
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortcut "$SMPROGRAMS\${APP_NAME}\${APP_NAME}.lnk" "$INSTDIR\${APP_NAME}.exe"

    ; Copy models to AppData
    IfFileExists "$INSTDIR\models\*.*" 0 +3
        CreateDirectory "$APPDATA\${APP_NAME}\models"
        CopyFiles /SILENT "$INSTDIR\models\*.*" "$APPDATA\${APP_NAME}\models\"

    WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd
```

**Result:** NSIS installer will be ~5.1 GB instead of ~100 MB.

### Linux DEB with Bundled Models

Modify `installers/linux/build-deb.sh`:

```bash
# After Step 4 (Create control file), add:

echo -e "${BLUE}Step 4.5: Adding bundled models...${NC}"

# Create models directory
mkdir -p "$DEB_DIR/usr/share/$APP_NAME/models"

# Copy bundled models
if [ -d "$PROJECT_ROOT/installers/bundled-models" ]; then
    cp -R "$PROJECT_ROOT/installers/bundled-models/whisper" \
          "$DEB_DIR/usr/share/$APP_NAME/models/"
    cp -R "$PROJECT_ROOT/installers/bundled-models/ollama" \
          "$DEB_DIR/usr/share/$APP_NAME/models/"
    echo -e "${GREEN}✓ Bundled models included${NC}"
fi
```

Update the post-install script:

```bash
cat > "$DEB_DIR/DEBIAN/postinst" << 'POSTINST'
#!/bin/bash
set -e

# Copy bundled models to user directory if available
if [ -d "/usr/share/cliniscribe/models" ]; then
    for user_home in /home/*; do
        user=$(basename "$user_home")
        if [ -d "$user_home" ]; then
            mkdir -p "$user_home/.config/cliniscribe/models"
            cp -R /usr/share/cliniscribe/models/* "$user_home/.config/cliniscribe/models/"
            chown -R "$user:$user" "$user_home/.config/cliniscribe"
        fi
    done
    echo "✓ Bundled models installed (offline ready)"
fi

exit 0
POSTINST
```

## 📦 Distribution Strategies

### Strategy 1: Two Installer Versions

Offer both standard and bundled versions:

**Standard Installer:**
- `CliniScribe-1.0.0-Setup.exe` (100 MB)
- Downloads models on first run
- Recommended for most users

**Bundled Installer:**
- `CliniScribe-1.0.0-Bundled-Setup.exe` (5.1 GB)
- Includes all models
- For offline/limited internet users

### Strategy 2: Separate Model Pack

Distribute models separately:

1. Main installer: `CliniScribe-1.0.0.exe` (100 MB)
2. Model pack: `CliniScribe-Models-1.0.0.zip` (5 GB)

**Installation:**
```bash
# Install app
sudo dpkg -i CliniScribe-1.0.0.deb

# Extract models
unzip CliniScribe-Models-1.0.0.zip
cd CliniScribe-Models-1.0.0

# Copy to user directory
cp -R whisper ~/.config/cliniscribe/models/
cp -R ollama ~/.config/cliniscribe/models/
```

### Strategy 3: USB Distribution

For medical schools/bulk deployment:

1. Create USB installer with:
   ```
   CliniScribe-USB/
   ├── installers/
   │   ├── CliniScribe-1.0.0-macOS.pkg
   │   ├── CliniScribe-1.0.0-Setup.exe
   │   └── CliniScribe-1.0.0.deb
   ├── models/
   │   ├── whisper/
   │   └── ollama/
   ├── install-macos.sh
   ├── install-windows.bat
   ├── install-linux.sh
   └── README.txt
   ```

2. Auto-install scripts detect platform and install accordingly

## 🧪 Testing Offline Installers

### Test on Clean System

**macOS:**
```bash
# 1. Install in VM or clean Mac
sudo installer -pkg CliniScribe-1.0.0-Bundled.pkg -target /

# 2. Disconnect internet
sudo ifconfig en0 down

# 3. Launch CliniScribe
open /Applications/CliniScribe.app

# 4. Verify no download happens
# Should go straight to main UI
```

**Windows:**
```cmd
REM 1. Install on clean Windows VM
CliniScribe-1.0.0-Bundled-Setup.exe

REM 2. Disconnect internet
ipconfig /release

REM 3. Launch CliniScribe
"C:\Program Files\CliniScribe\CliniScribe.exe"

REM 4. Verify offline functionality
```

**Linux:**
```bash
# 1. Install on clean Ubuntu
sudo dpkg -i CliniScribe-1.0.0-bundled.deb

# 2. Disconnect internet
sudo ip link set enp0s3 down

# 3. Launch CliniScribe
cliniscribe

# 4. Test transcription/summarization
```

### Verify Model Presence

Check models are in the correct location:

**macOS:**
```bash
ls -lh ~/Library/Application\ Support/com.cliniscribe.app/models/whisper/
ls -lh ~/Library/Application\ Support/com.cliniscribe.app/models/ollama/
```

**Windows:**
```cmd
dir %APPDATA%\cliniscribe\models\whisper
dir %APPDATA%\cliniscribe\models\ollama
```

**Linux:**
```bash
ls -lh ~/.config/cliniscribe/models/whisper/
ls -lh ~/.config/cliniscribe/models/ollama/
```

## 📊 Size Comparison

| Component | Standard | Bundled |
|-----------|----------|---------|
| Installer | ~100 MB | ~5.1 GB |
| First Run Download | 5 GB | 0 MB |
| **Total Bandwidth** | **~5.1 GB** | **~5.1 GB** |
| Install Time | 2 min | 15-30 min |
| First Run Setup | 5-15 min | Instant |
| Internet Required | Yes | No |

**Recommendation:**
- **Standard installer** for users with good internet
- **Bundled installer** for:
  - Medical schools (bulk deployment)
  - Offline environments
  - Regions with limited internet
  - IT administrators

## 🔐 Security Notes

1. **Verify Checksums**: Always provide SHA256 checksums
2. **Sign Installers**: Code-sign bundled installers
3. **Source Verification**: Document model sources (Hugging Face, Ollama)
4. **Update Process**: Bundled models can still update online if needed

## 📚 Additional Resources

- [Model Bundler Script](./bundle-models.sh)
- [Standard Installers Guide](./ONE_CLICK_INSTALLERS.md)
- [Homebrew Distribution](./macos/HOMEBREW_DISTRIBUTION.md)

---

**Quick Start:**
```bash
# 1. Create model bundle
./installers/bundle-models.sh

# 2. Modify installer script to include bundled models

# 3. Build bundled installer
./installers/build-all.sh --current

# 4. Test on clean system with no internet

# 5. Distribute!
```
