# One-Click Installers for CliniScribe

## Overview

Professional installers for each platform that handle **everything** automatically:
- ✅ App installation
- ✅ Python backend bundling
- ✅ Ollama installation
- ✅ Desktop shortcuts
- ✅ File associations
- ✅ Uninstallers

**User experience:** Download → Double-click → Wait for setup → Use!

---

## Installation Methods by Platform

### macOS (.pkg + .dmg)

**Option 1: PKG Installer** (Recommended)
```
CliniScribe-1.0.0-Installer.pkg
├── Pre-install: Check system requirements
├── Install: Copy app to /Applications
├── Post-install: Download models (optional)
└── Launch: Open CliniScribe automatically
```

**Option 2: DMG Disk Image** (Simple)
```
CliniScribe-1.0.0.dmg
└── Drag CliniScribe.app to Applications
```

**Option 3: Homebrew** (For developers)
```bash
brew install --cask cliniscribe
```

### Windows (.exe)

**NSIS Installer**
```
CliniScribe-Setup-1.0.0.exe
├── Welcome screen
├── License agreement
├── Install location
├── Create shortcuts (Desktop + Start Menu)
├── Install files
├── Download models (optional)
├── Create uninstaller
└── Launch CliniScribe
```

### Linux (.deb, .rpm, AppImage)

**Option 1: DEB Package** (Ubuntu/Debian)
```bash
sudo dpkg -i cliniscribe_1.0.0_amd64.deb
```

**Option 2: RPM Package** (Fedora/RHEL)
```bash
sudo rpm -i cliniscribe-1.0.0.x86_64.rpm
```

**Option 3: AppImage** (Universal)
```bash
chmod +x CliniScribe-1.0.0.AppImage
./CliniScribe-1.0.0.AppImage
```

---

## Installer Sizes

### Without Pre-Downloaded Models
- **macOS**: ~600 MB
- **Windows**: ~650 MB
- **Linux**: ~600 MB

**Download time:** 2-5 minutes on typical internet

### With Pre-Downloaded Models (Optional)
- **macOS**: ~5.5 GB
- **Windows**: ~5.6 GB
- **Linux**: ~5.5 GB

**Download time:** 10-30 minutes on typical internet

**Trade-off:** Larger download but truly offline after install

---

## Build Process

### Prerequisites
- macOS: Xcode Command Line Tools
- Windows: NSIS or Inno Setup
- Linux: dpkg-deb, rpmbuild

### Build All Installers

```bash
cd desktop-app
npm run installers:build
```

This creates:
```
installers/output/
├── macos/
│   ├── CliniScribe-1.0.0.dmg
│   └── CliniScribe-1.0.0.pkg
├── windows/
│   └── CliniScribe-Setup-1.0.0.exe
└── linux/
    ├── cliniscribe_1.0.0_amd64.deb
    ├── cliniscribe-1.0.0.x86_64.rpm
    └── CliniScribe-1.0.0.AppImage
```

---

## Features

### All Platforms
- ✅ One-click installation
- ✅ No terminal commands required
- ✅ Automatic dependency handling
- ✅ Desktop shortcuts created
- ✅ Proper uninstaller included
- ✅ Code-signed (production builds)

### macOS Specific
- ✅ Installs to /Applications
- ✅ Creates Launchpad entry
- ✅ Notarized by Apple
- ✅ Gatekeeper approved
- ✅ Can run without "Open Anyway" dialog

### Windows Specific
- ✅ Start Menu entry
- ✅ Desktop shortcut (optional)
- ✅ Quick Launch icon (optional)
- ✅ Add to PATH (optional)
- ✅ Control Panel uninstaller
- ✅ Windows Defender SmartScreen approved

### Linux Specific
- ✅ .desktop file created
- ✅ Application menu entry
- ✅ MIME type associations
- ✅ Icon in correct theme directory
- ✅ Follows FreeDesktop standards

---

## Installation Flow

### User Experience

**Step 1: Download**
- User visits cliniscribe.com/download
- OS is auto-detected
- Download button for their platform

**Step 2: Install**

*macOS:*
```
1. Open CliniScribe-1.0.0.pkg
2. Click "Continue" through welcome
3. Accept license
4. Click "Install"
5. Enter password (for /Applications)
6. Wait ~1 minute
7. App opens automatically
```

*Windows:*
```
1. Double-click CliniScribe-Setup-1.0.0.exe
2. Click "Yes" to UAC prompt
3. Click "Next" through wizard
4. Choose install location (optional)
5. Select "Create desktop shortcut" (optional)
6. Click "Install"
7. Wait ~1 minute
8. Click "Finish" (launches app)
```

*Linux:*
```
1. Open downloaded file
2. Click "Install" in Software Center
   OR
1. chmod +x CliniScribe-1.0.0.AppImage
2. Double-click to run
```

**Step 3: First Run**
- App opens
- Setup wizard appears
- Models download automatically
- 5-15 minutes depending on internet
- Dashboard appears when complete

**Total time:** 10-20 minutes from download to first use

---

## Advanced: Offline Installation

For institutions or users without reliable internet:

### Create Offline Installer

```bash
cd desktop-app
npm run installers:build-offline
```

This creates a larger installer (~5.5 GB) with:
- ✅ Whisper base model pre-bundled
- ✅ Llama 3.1 8B pre-bundled
- ✅ No internet required after download

**Use case:** Medical schools can download once and distribute via USB drives

---

## Customization

### Installer Branding

Edit `installers/config.json`:
```json
{
  "appName": "CliniScribe",
  "version": "1.0.0",
  "publisher": "Your Organization",
  "website": "https://cliniscribe.com",
  "supportEmail": "support@cliniscribe.com",
  "bundleModels": false,
  "shortcuts": {
    "desktop": true,
    "startMenu": true,
    "launchpad": true
  }
}
```

### Custom Welcome Screen

Replace `installers/macos/welcome.rtf` or `installers/windows/welcome.txt`

### Custom License

Replace `installers/LICENSE.txt`

---

## Code Signing

### macOS

**Requirements:**
- Apple Developer Account ($99/year)
- Developer ID Application certificate

**Sign the app:**
```bash
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  --options runtime \
  CliniScribe.app
```

**Notarize:**
```bash
xcrun notarytool submit CliniScribe-1.0.0.dmg \
  --apple-id "your@email.com" \
  --password "app-specific-password" \
  --team-id "TEAM_ID" \
  --wait

xcrun stapler staple CliniScribe-1.0.0.dmg
```

### Windows

**Requirements:**
- Code signing certificate (~$100-400/year)

**Sign the installer:**
```bash
signtool sign /f certificate.pfx /p password \
  /t http://timestamp.digicert.com \
  CliniScribe-Setup-1.0.0.exe
```

### Linux

**Not required**, but recommended:
- Sign DEB/RPM packages with GPG
- Publish to verified repositories

---

## Distribution

### Direct Download (Simple)

Host installers on:
- **GitHub Releases** (free, unlimited bandwidth)
- **CloudFlare R2** ($0.015/GB)
- **AWS S3** ($0.023/GB)
- **Your own server**

### Package Managers

**macOS - Homebrew:**
```bash
brew tap yourorg/cliniscribe
brew install --cask cliniscribe
```

**Windows - Chocolatey:**
```bash
choco install cliniscribe
```

**Windows - Winget:**
```bash
winget install CliniScribe
```

**Linux - APT Repository:**
```bash
sudo add-apt-repository ppa:yourorg/cliniscribe
sudo apt update
sudo apt install cliniscribe
```

---

## Testing Installers

### Automated Tests

```bash
# Test macOS installer
npm run test:installer:macos

# Test Windows installer (on Windows VM)
npm run test:installer:windows

# Test Linux installer (on Linux VM)
npm run test:installer:linux
```

### Manual Testing Checklist

**Fresh System Testing:**
- [ ] Download installer
- [ ] Run installer
- [ ] Verify app appears in Applications/Programs
- [ ] Launch app from shortcut
- [ ] Complete first-run wizard
- [ ] Process a test audio file
- [ ] Verify export works
- [ ] Close and reopen (settings persist?)
- [ ] Run uninstaller
- [ ] Verify all files removed

---

## Troubleshooting

### "App is damaged and can't be opened" (macOS)

**Cause:** App not code-signed

**Fix:**
```bash
xattr -cr /Applications/CliniScribe.app
```

### "Windows Defender blocked this app" (Windows)

**Cause:** Installer not code-signed

**Fix for users:**
1. Click "More info"
2. Click "Run anyway"

**Fix for developers:** Get code signing certificate

### "Permission denied" (Linux)

**Fix:**
```bash
chmod +x CliniScribe-1.0.0.AppImage
```

---

## Maintenance

### Update Process

When releasing version 1.1.0:

1. Update version in:
   - `package.json`
   - `tauri.conf.json`
   - `installers/config.json`

2. Rebuild installers:
   ```bash
   npm run installers:build
   ```

3. Test installers

4. Upload to distribution:
   - GitHub Releases
   - Update server (for auto-updates)
   - Package managers

5. Announce update:
   - In-app notification (if auto-update enabled)
   - Email to users
   - Social media

---

## Cost Analysis

### Self-Hosting
- **Storage**: Free (GitHub Releases)
- **Bandwidth**: Free (GitHub)
- **CDN**: Optional ($10-20/month)

**Total: $0-20/month**

### With Package Managers
- **Homebrew**: Free
- **Chocolatey**: Free
- **APT/YUM repository**: $5-10/month (server)

**Total: $5-30/month**

### With Code Signing
- **macOS**: $99/year
- **Windows**: $100-400/year
- **Total**: $200-500/year

---

## Metrics to Track

After release, monitor:
- **Download count** by platform
- **Installation success rate**
- **First-run completion rate**
- **Uninstall rate**
- **Support tickets** per installer type
- **Crash reports** during installation

**Goal:** >95% successful installations

---

## Future Enhancements

- [ ] Auto-updater integration
- [ ] Silent install mode (for IT departments)
- [ ] Custom install options (portable mode)
- [ ] Multi-language installers
- [ ] Enterprise deployment (MSI for Windows, PKG for macOS)
- [ ] Chocolatey/Homebrew auto-updates

---

**Next:** See platform-specific guides in this directory:
- `macos/BUILD.md`
- `windows/BUILD.md`
- `linux/BUILD.md`
