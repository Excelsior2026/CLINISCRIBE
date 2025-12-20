# CliniScribe User Guide

**For Medical & Nursing Students - No Technical Knowledge Required!**

---

## Table of Contents
1. [Installation](#installation)
2. [First-Time Setup](#first-time-setup)
3. [Daily Use](#daily-use)
4. [Tips & Tricks](#tips--tricks)
5. [Troubleshooting](#troubleshooting)

---

## Installation

### Windows

1. **Download** the installer
   - Visit: https://cliniscribe.com/download
   - Click "Download for Windows"
   - File: `CliniScribe-Setup.msi` (~650 MB)

2. **Install**
   - Double-click the downloaded file
   - Click "Yes" when Windows asks for permission
   - Follow the wizard:
     - Click "Next"
     - Choose install location (default is fine)
     - Click "Install"
     - Wait 1-2 minutes
   - Click "Finish"

3. **Launch**
   - Find "CliniScribe" in your Start Menu
   - Or double-click the desktop shortcut

### macOS

1. **Download** the installer
   - Visit: https://cliniscribe.com/download
   - Click "Download for Mac"
   - File: `CliniScribe.dmg` (~600 MB)

2. **Install**
   - Double-click the downloaded `.dmg` file
   - Drag the CliniScribe icon to your Applications folder
   - Eject the DMG (right-click → Eject)

3. **Launch**
   - Open Applications folder
   - Find CliniScribe
   - Right-click → Open (first time only, to bypass Gatekeeper)
   - Click "Open" when warned about unidentified developer

### Linux

1. **Download** the installer
   - Visit: https://cliniscribe.com/download
   - Click "Download for Linux"
   - File: `CliniScribe.AppImage` (~600 MB)

2. **Install**
   ```bash
   # Make executable
   chmod +x CliniScribe.AppImage

   # Optional: Move to /usr/local/bin for easy access
   sudo mv CliniScribe.AppImage /usr/local/bin/cliniscribe
   ```

3. **Launch**
   ```bash
   ./CliniScribe.AppImage
   # or if you moved it:
   cliniscribe
   ```

---

## First-Time Setup

The first time you open CliniScribe, you'll see a setup wizard. This only happens once!

### Step 1: Welcome Screen

You'll see:
- Welcome message
- What CliniScribe does
- Info about the AI models we'll download

**Click "Get Started"**

### Step 2: Download AI Models

CliniScribe will automatically download two AI models:

1. **Whisper** (~150 MB) - For transcribing audio to text
2. **Llama 3.1** (~4.7 GB) - For creating study notes

**What you'll see:**
- Progress bar showing download percentage
- Current download speed
- Estimated time remaining

**How long it takes:**
- **Fast internet** (100 Mbps): 5-8 minutes
- **Medium internet** (50 Mbps): 10-15 minutes
- **Slow internet** (10 Mbps): 20-30 minutes

**💡 Tip:** You can minimize CliniScribe and do other things. We'll notify you when it's done!

### Step 3: All Set!

Once downloads finish, you'll see:
- Success message 🎉
- Quick start guide
- "Launch CliniScribe" button

**Click "Launch CliniScribe"**

---

## Daily Use

### Step 1: Record Your Lecture

**During Class:**
- Use your phone's voice recorder app
- Or use a dedicated audio recorder
- Aim for clear audio (sit near the front!)

**Supported formats:**
- MP3 (most common)
- WAV
- M4A (iPhone default)
- FLAC, OGG, AAC, WMA

### Step 2: Upload to CliniScribe

1. **Open CliniScribe** (if not already open)

2. **Upload your recording:**
   - Click the upload area
   - Or drag-and-drop your audio file

3. **Choose options:**
   - **Subject**: Pick your subject from the dropdown
     - Anatomy
     - Physiology
     - Pharmacology
     - Pathophysiology
     - Clinical Skills
     - Nursing Fundamentals
     - Or leave as "General"

   - **Summary Length**: Slide the slider
     - **Quick**: Brief bullet points (good for review)
     - **Balanced**: Default, best for most uses
     - **Thorough**: Detailed notes with examples

4. **Click "Generate Study Notes"**

### Step 3: Wait for Processing

**Processing time depends on lecture length:**
- 30-minute lecture: ~2-3 minutes
- 60-minute lecture: ~5-7 minutes
- 90-minute lecture: ~8-12 minutes

**What's happening:**
1. **Cleaning audio** (reducing background noise)
2. **Transcribing** (converting speech to text)
3. **Summarizing** (AI creates structured notes)

**You'll see:**
- Loading spinner
- "Processing your lecture..." message
- Bouncing dots animation

**💡 Tip:** You can minimize CliniScribe and study other material while it processes!

### Step 4: Get Your Study Notes

When processing finishes, you'll see:

**1. Study Notes** (formatted beautifully):
- 📚 **Learning Objectives** - What you should learn
- 💡 **Core Concepts** - Main ideas and theories
- 📖 **Clinical Terms** - Important medical vocabulary with definitions
- 🏥 **Procedures** - Any clinical procedures discussed
- 📝 **Summary** - Concise overview connecting everything

**2. Full Transcript**:
- Word-for-word transcription of the lecture
- With timestamps
- Searchable (Ctrl+F / Cmd+F)

### Step 5: Export Your Notes

You have several options:

**📋 Copy to Clipboard**
- Click "Copy" button
- Paste into OneNote, Notion, Google Docs, etc.

**💾 Download as Markdown**
- Click "Export as Markdown"
- Opens in any text editor
- Great for Obsidian users!

**📄 Export to PDF** (coming soon)
**📱 Sync to Mobile** (coming soon)

---

## Tips & Tricks

### Getting Better Transcriptions

✅ **DO:**
- Record from the front of the room
- Use an external microphone if possible
- Test your recorder before important lectures
- Keep recordings under 2 hours (split long lectures)

❌ **DON'T:**
- Record in noisy environments (cafeterias, hallways)
- Use low-quality recorders
- Set recording quality to "voice memo" mode (use "high quality")
- Forget to charge your recording device!

### Getting Better Study Notes

**Choose the right subject:**
- Helps AI use relevant medical terminology
- Focuses on subject-specific concepts
- Better organization of notes

**Adjust summary length:**
- **Quick**: Perfect for lectures you already understand well
- **Balanced**: Best for most lectures
- **Thorough**: For complex topics or exam prep

**Review soon after class:**
- Use notes within 24 hours for best retention
- Add your own annotations
- Highlight key points

### Organizing Your Notes

**Create a folder structure:**
```
My Notes/
├── Semester 1/
│   ├── Anatomy/
│   ├── Physiology/
│   └── Biochemistry/
├── Semester 2/
│   ├── Pharmacology/
│   └── Pathophysiology/
```

**File naming convention:**
```
2024-01-15_Anatomy_CardiacCycle.md
YYYY-MM-DD_Subject_Topic.md
```

### Keyboard Shortcuts

- **Upload**: `Ctrl+O` / `Cmd+O`
- **Settings**: `Ctrl+,` / `Cmd+,`
- **Copy Notes**: `Ctrl+C` / `Cmd+C` (when focused)
- **Search**: `Ctrl+F` / `Cmd+F`

---

## Troubleshooting

### "Services failed to start"

**Problem**: Backend isn't running

**Solutions:**
1. Restart CliniScribe
2. Check if another instance is running (close it)
3. On Mac: System Preferences → Security → Allow CliniScribe
4. On Windows: Windows Defender may have blocked it - allow it

### Processing is very slow

**Possible causes:**
1. **Large file** - Lectures over 2 hours take longer
   - Solution: Split into smaller chunks

2. **Low memory** - Other programs using RAM
   - Solution: Close unnecessary programs

3. **Old computer** - Processing is CPU-intensive
   - Solution: Let it run overnight for long lectures

### Poor transcription quality

**Common issues:**

**Lots of "[inaudible]" tags**
- Audio quality too low
- Try re-recording closer to speaker
- Use an external microphone

**Wrong words**
- Specialized medical terms may be misheard
- Manually correct key terms
- Future updates will improve medical vocabulary

**Missing sections**
- Long pauses or silence in recording
- Check original audio file

### Out of disk space

**CliniScribe uses:**
- ~5 GB for AI models (one-time)
- ~100-200 MB per hour of audio (temporary)
- Auto-deletes audio after 7 days (configurable)

**To free space:**
1. Open Settings
2. Reduce "Keep audio files for" to fewer days
3. Click "Delete old files now"

### Update available but won't install

1. Close CliniScribe completely
2. Download new installer from website
3. Install over existing version
4. Reopen CliniScribe

---

## Privacy & Data

### What stays on your computer:
- ✅ All audio files
- ✅ All transcripts
- ✅ All study notes
- ✅ AI models (Whisper & Llama)

### What goes to the internet:
- ❌ Nothing! (except updates check)

CliniScribe works **100% offline** after setup. Your lecture recordings and study materials never leave your computer.

---

## Getting Help

### In-App Help
- Click the "?" icon in the top-right
- Access tutorials and FAQs

### Email Support
- support@cliniscribe.com
- We usually respond within 24 hours

### Community
- Discord: https://discord.gg/cliniscribe
- Reddit: r/CliniScribe
- Share tips with fellow students!

### Report a Bug
- GitHub Issues: https://github.com/yourusername/Cliniscribe/issues
- Include:
  - What you were doing
  - What happened vs. what you expected
  - Screenshots if possible

---

## Uninstalling

### Windows
1. Settings → Apps → Apps & features
2. Find "CliniScribe"
3. Click → Uninstall

### macOS
1. Open Applications folder
2. Drag CliniScribe to Trash
3. Empty Trash

### Linux
```bash
rm /usr/local/bin/cliniscribe  # or wherever you put it
```

**Data cleanup:**
- Windows: Delete `%APPDATA%\CliniScribe`
- macOS: Delete `~/Library/Application Support/com.cliniscribe.app`
- Linux: Delete `~/.config/cliniscribe`

---

## Frequently Asked Questions

**Q: Do I need internet to use CliniScribe?**
A: Only for the first-time setup (downloading models). After that, it works 100% offline!

**Q: Can I use this for languages other than English?**
A: Whisper supports 90+ languages! Select your language in Settings.

**Q: How accurate is the transcription?**
A: Typically 90-95% accurate with clear audio. Medical terminology may need review.

**Q: Can I edit the notes after generation?**
A: Yes! Copy them to your preferred note-taking app and edit freely.

**Q: Is this free?**
A: Yes! CliniScribe is free for educational use.

**Q: Can professors tell I used AI for notes?**
A: These are YOUR notes from YOUR recordings. Using AI to organize your study materials is like using a calculator for math - it's a tool to help you learn.

**Q: Will this work on my old laptop?**
A: Minimum requirements:
  - 8 GB RAM (16 GB recommended)
  - 10 GB free disk space
  - Processor: Intel i5 or equivalent (2015 or newer)

**Q: Can I batch-process multiple lectures?**
A: Not yet, but coming in v1.1! For now, process them one at a time.

---

**Happy studying! 🎓💙**

*Remember: These notes are study aids. Always review the original material and your own notes too!*
