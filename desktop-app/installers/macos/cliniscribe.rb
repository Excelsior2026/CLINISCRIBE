cask "cliniscribe" do
  version "1.0.0"
  sha256 :no_check  # Update with actual SHA256 after building DMG

  url "https://github.com/YOUR_USERNAME/cliniscribe/releases/download/v#{version}/CliniScribe-#{version}.dmg"
  name "CliniScribe"
  desc "AI-powered study notes for medical students"
  homepage "https://cliniscribe.com"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Minimum macOS version
  depends_on macos: ">= :catalina"

  app "CliniScribe.app"

  # Post-install message
  postflight do
    puts <<~EOS
      ┌─────────────────────────────────────────────────────────────┐
      │                                                             │
      │  🎉 CliniScribe has been installed successfully!           │
      │                                                             │
      │  Next steps:                                               │
      │    1. Open CliniScribe from your Applications folder       │
      │    2. Complete the first-run setup wizard                  │
      │    3. AI models will download (~5 GB, 5-15 minutes)        │
      │    4. Start transforming lectures into study notes!        │
      │                                                             │
      │  System Requirements:                                      │
      │    • macOS 10.15 (Catalina) or later                       │
      │    • 8 GB RAM (16 GB recommended)                          │
      │    • 10 GB free disk space for AI models                   │
      │    • Internet connection for first-time setup              │
      │                                                             │
      │  Need help? Visit https://cliniscribe.com/docs             │
      │                                                             │
      └─────────────────────────────────────────────────────────────┘
    EOS
  end

  # Uninstall script
  uninstall quit: "com.cliniscribe.app"

  # Optional: Clean up user data (ask first in GUI)
  zap trash: [
    "~/Library/Application Support/com.cliniscribe.app",
    "~/Library/Caches/com.cliniscribe.app",
    "~/Library/Preferences/com.cliniscribe.app.plist",
    "~/Library/Saved Application State/com.cliniscribe.app.savedState",
    "~/Library/Logs/CliniScribe",
  ]
end
