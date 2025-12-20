use anyhow::{Context, Result};
use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppConfig {
    // Setup status
    pub setup_completed: bool,

    // Model settings
    pub whisper_model: String,
    pub ollama_model: String,
    pub use_gpu: bool,

    // Processing defaults
    pub default_ratio: f32,
    pub default_subject: String,

    // Storage settings
    pub data_directory: PathBuf,
    pub auto_delete_days: u32,

    // UI preferences
    pub theme: String,
    pub auto_updates: bool,
}

impl Default for AppConfig {
    fn default() -> Self {
        Self {
            setup_completed: false,
            whisper_model: "base".to_string(),
            ollama_model: "llama3.1:8b".to_string(),
            use_gpu: false,
            default_ratio: 0.15,
            default_subject: String::new(),
            data_directory: get_default_data_dir(),
            auto_delete_days: 7,
            theme: "light".to_string(),
            auto_updates: true,
        }
    }
}

/// Get platform-specific config directory
pub fn get_config_dir() -> PathBuf {
    dirs::config_dir()
        .expect("Failed to get config directory")
        .join("cliniscribe")
}

/// Get default data directory for storing audio files
fn get_default_data_dir() -> PathBuf {
    dirs::data_local_dir()
        .expect("Failed to get data directory")
        .join("cliniscribe")
        .join("audio_storage")
}

/// Get config file path
fn get_config_file() -> PathBuf {
    get_config_dir().join("config.json")
}

/// Load configuration from disk
pub fn load_config() -> Result<AppConfig> {
    let config_file = get_config_file();

    if !config_file.exists() {
        // Create default config
        let config = AppConfig::default();
        save_config(&config)?;
        return Ok(config);
    }

    let contents = fs::read_to_string(&config_file)
        .context("Failed to read config file")?;

    let config: AppConfig = serde_json::from_str(&contents)
        .context("Failed to parse config file")?;

    Ok(config)
}

/// Save configuration to disk
pub fn save_config(config: &AppConfig) -> Result<()> {
    let config_dir = get_config_dir();

    // Create config directory if it doesn't exist
    fs::create_dir_all(&config_dir)
        .context("Failed to create config directory")?;

    let config_file = config_dir.join("config.json");

    let contents = serde_json::to_string_pretty(config)
        .context("Failed to serialize config")?;

    fs::write(&config_file, contents)
        .context("Failed to write config file")?;

    Ok(())
}

/// Ensure data directories exist
pub fn ensure_data_directories(config: &AppConfig) -> Result<()> {
    fs::create_dir_all(&config.data_directory)
        .context("Failed to create data directory")?;

    Ok(())
}
