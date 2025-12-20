# Homebrew Distribution Guide

This guide explains how to distribute CliniScribe via Homebrew, the package manager for macOS.

## 📋 Table of Contents

- [Overview](#overview)
- [Distribution Options](#distribution-options)
- [Creating Your Own Tap](#creating-your-own-tap)
- [Getting into Official Homebrew](#getting-into-official-homebrew)
- [Testing the Formula](#testing-the-formula)
- [Updating the Formula](#updating-the-formula)

## 🎯 Overview

Homebrew Casks provide a simple way to install GUI applications on macOS:

```bash
brew install --cask cliniscribe
```

This is ideal for developers and power users who prefer command-line installation.

**User Experience:**
- ✅ Simple one-line installation
- ✅ Easy updates: `brew upgrade cliniscribe`
- ✅ Clean uninstall: `brew uninstall --cask cliniscribe`
- ✅ Automatic dependency management
- ✅ Version tracking and rollback support

## 🚀 Distribution Options

### Option 1: Your Own Tap (Recommended for Start)

Create your own Homebrew tap repository. This gives you full control and is easier to set up.

**Advantages:**
- Complete control over releases
- No approval process
- Can update anytime
- Good for beta testing

**How users install:**
```bash
brew tap YOUR_USERNAME/cliniscribe
brew install --cask cliniscribe
```

### Option 2: Official Homebrew Cask Repository

Submit to the official `homebrew/cask` repository for wider distribution.

**Advantages:**
- Wider audience reach
- Built-in trust (official repo)
- Better discoverability
- No custom tap needed

**How users install:**
```bash
brew install --cask cliniscribe
```

**Requirements:**
- Stable releases only (no beta/alpha)
- Code-signed application
- Public download URL
- Active maintenance commitment

## 🏗️ Creating Your Own Tap

### Step 1: Create a GitHub Repository

Create a new repository named `homebrew-cliniscribe`:

```bash
# Create the repo on GitHub, then:
mkdir homebrew-cliniscribe
cd homebrew-cliniscribe
git init
```

### Step 2: Add the Cask Formula

```bash
mkdir -p Casks
cp /path/to/cliniscribe.rb Casks/cliniscribe.rb
```

### Step 3: Update the Formula

Edit `Casks/cliniscribe.rb` and update:

1. **URL**: Point to your GitHub release:
   ```ruby
   url "https://github.com/YOUR_USERNAME/cliniscribe/releases/download/v#{version}/CliniScribe-#{version}.dmg"
   ```

2. **SHA256**: Generate after building the DMG:
   ```bash
   shasum -a 256 CliniScribe-1.0.0.dmg
   ```

   Then update:
   ```ruby
   sha256 "abc123..."  # Replace with actual hash
   ```

### Step 4: Push to GitHub

```bash
git add Casks/cliniscribe.rb
git commit -m "Add CliniScribe cask formula"
git push origin main
```

### Step 5: Users Can Now Install

```bash
brew tap YOUR_USERNAME/cliniscribe
brew install --cask cliniscribe
```

## 🎓 Getting into Official Homebrew

### Prerequisites

1. **Stable Release**: Version 1.0.0 or higher
2. **Code Signing**: App must be signed with Apple Developer ID
3. **Notarization**: App must be notarized by Apple
4. **Public URL**: Stable download URL (GitHub Releases recommended)
5. **License**: Open source or clear license terms

### Submission Process

1. **Test Your Formula Locally**:
   ```bash
   brew install --cask --debug --verbose ./cliniscribe.rb
   ```

2. **Fork the Repository**:
   ```bash
   # Fork https://github.com/Homebrew/homebrew-cask
   ```

3. **Add Your Cask**:
   ```bash
   git clone https://github.com/YOUR_USERNAME/homebrew-cask
   cd homebrew-cask
   git checkout -b cliniscribe

   cp /path/to/cliniscribe.rb Casks/c/cliniscribe.rb
   ```

4. **Test with Brew Audit**:
   ```bash
   brew audit --cask --new-cask cliniscribe
   brew style --fix cliniscribe
   ```

5. **Create Pull Request**:
   ```bash
   git add Casks/c/cliniscribe.rb
   git commit -m "Add CliniScribe 1.0.0"
   git push origin cliniscribe
   ```

   Then create a PR on GitHub.

6. **Wait for Review**:
   - Maintainers will review your submission
   - They may request changes
   - Once approved, it's merged and available to all users

### Approval Criteria

Homebrew maintainers check for:

- ✅ Cask follows [naming conventions](https://docs.brew.sh/Acceptable-Casks)
- ✅ App is signed and notarized
- ✅ Download URL is stable and permanent
- ✅ SHA256 hash is correct
- ✅ App is installable and works correctly
- ✅ No trademark issues
- ✅ Clear licensing

## 🧪 Testing the Formula

### Local Testing

Test your formula before distribution:

```bash
# Test installation
brew install --cask --debug --verbose cliniscribe.rb

# Verify it works
open /Applications/CliniScribe.app

# Test uninstall
brew uninstall --cask cliniscribe

# Test audit
brew audit --cask cliniscribe

# Test style
brew style --fix cliniscribe
```

### Common Issues

**Issue: SHA256 mismatch**
```bash
# Regenerate the hash
shasum -a 256 CliniScribe-1.0.0.dmg
# Update in formula
```

**Issue: App not signed**
```bash
# Check signing
codesign -dvv /Applications/CliniScribe.app
# Should show Developer ID
```

**Issue: Gatekeeper blocks app**
```bash
# Check notarization
spctl -a -vv /Applications/CliniScribe.app
# Should show "accepted"
```

## 🔄 Updating the Formula

When you release a new version:

### For Your Own Tap

1. Build the new DMG
2. Generate new SHA256
3. Update `cliniscribe.rb`:
   ```ruby
   version "1.1.0"
   sha256 "new_hash_here"
   ```
4. Commit and push

Users update with:
```bash
brew update
brew upgrade --cask cliniscribe
```

### For Official Homebrew

1. Fork and clone `homebrew-cask` again
2. Create a new branch: `cliniscribe-1.1.0`
3. Update `Casks/c/cliniscribe.rb` with new version and SHA256
4. Create PR with title: "cliniscribe 1.1.0"
5. Wait for review and merge

## 📊 Analytics

Track installation metrics (optional):

Homebrew provides anonymous analytics. View your cask stats:
```bash
brew analytics cask-install --days 30 cliniscribe
```

## 🔐 Security Best Practices

1. **Always Sign Your App**: Use Apple Developer ID
2. **Always Notarize**: Submit to Apple's notary service
3. **Use HTTPS**: For download URLs
4. **Verify Integrity**: Always include SHA256 hash
5. **Keep URLs Stable**: Never change download URLs for released versions

## 📚 Additional Resources

- [Homebrew Cask Documentation](https://docs.brew.sh/Cask-Cookbook)
- [Acceptable Casks Policy](https://docs.brew.sh/Acceptable-Casks)
- [Contributing to Homebrew](https://docs.brew.sh/How-To-Open-a-Homebrew-Pull-Request)
- [Cask Formula Reference](https://docs.brew.sh/Cask-Cookbook#formula-for-a-cask)

## 🎯 Recommended Approach

**For CliniScribe 1.0.0:**

1. **Start with your own tap** (easiest, full control)
   ```bash
   brew tap YOUR_USERNAME/cliniscribe
   brew install --cask cliniscribe
   ```

2. **Get code signing and notarization** (required for wider distribution)

3. **Gather feedback** from early users (1-2 months)

4. **Submit to official Homebrew** once stable (version 1.1.0+)
   ```bash
   brew install --cask cliniscribe
   ```

This approach minimizes friction early on while building toward official distribution.

## 🚦 Quick Start Checklist

- [ ] Build DMG installer
- [ ] Calculate SHA256 hash
- [ ] Update `cliniscribe.rb` with real URL and hash
- [ ] Test formula locally
- [ ] Create `homebrew-cliniscribe` repository
- [ ] Push formula to GitHub
- [ ] Add installation instructions to main README
- [ ] (Optional) Apply for code signing certificate
- [ ] (Optional) Submit to official Homebrew

---

**Next Steps**: Once you have a stable DMG and GitHub release, update the formula and test it locally!
