// Prevents additional console window on Windows in release mode
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

mod process_manager;
mod config;
mod model_downloader;

use std::sync::Mutex;
use tauri::{Manager, State};
use process_manager::{ProcessManager, ServiceStatus};
use config::{AppConfig, load_config, save_config};
use model_downloader::{download_whisper_model, download_ollama_model, DownloadProgress};

// Application state
struct AppState {
    process_manager: Mutex<ProcessManager>,
    config: Mutex<AppConfig>,
}

/// Check if this is the first run of the application
#[tauri::command]
async fn is_first_run(state: State<'_, AppState>) -> Result<bool, String> {
    let config = state.config.lock().unwrap();
    Ok(!config.setup_completed)
}

/// Mark setup as completed
#[tauri::command]
async fn complete_setup(state: State<'_, AppState>) -> Result<(), String> {
    let mut config = state.config.lock().unwrap();
    config.setup_completed = true;
    save_config(&config).map_err(|e| e.to_string())?;
    Ok(())
}

/// Get current application configuration
#[tauri::command]
async fn get_config(state: State<'_, AppState>) -> Result<AppConfig, String> {
    let config = state.config.lock().unwrap();
    Ok(config.clone())
}

/// Update application configuration
#[tauri::command]
async fn update_config(
    state: State<'_, AppState>,
    new_config: AppConfig
) -> Result<(), String> {
    let mut config = state.config.lock().unwrap();
    *config = new_config;
    save_config(&config).map_err(|e| e.to_string())?;
    Ok(())
}

/// Start backend services (Ollama + Python API)
#[tauri::command]
async fn start_services(
    state: State<'_, AppState>,
    app_handle: tauri::AppHandle
) -> Result<(), String> {
    let config = state.config.lock().unwrap().clone();
    let mut manager = state.process_manager.lock().unwrap();

    // Get resource directory path
    let resource_dir = app_handle
        .path_resolver()
        .resource_dir()
        .ok_or("Failed to get resource directory")?;

    // Start services
    manager
        .start_all(&resource_dir, &config)
        .await
        .map_err(|e| e.to_string())?;

    Ok(())
}

/// Stop backend services
#[tauri::command]
async fn stop_services(state: State<'_, AppState>) -> Result<(), String> {
    let mut manager = state.process_manager.lock().unwrap();
    manager.stop_all().await.map_err(|e| e.to_string())?;
    Ok(())
}

/// Get status of all services
#[tauri::command]
async fn get_service_status(state: State<'_, AppState>) -> Result<ServiceStatus, String> {
    let manager = state.process_manager.lock().unwrap();
    Ok(manager.get_status())
}

/// Download a model with progress tracking
#[tauri::command]
async fn download_model(
    model_type: String,
    app_handle: tauri::AppHandle
) -> Result<(), String> {
    let resource_dir = app_handle
        .path_resolver()
        .resource_dir()
        .ok_or("Failed to get resource directory")?;

    let progress_callback = |progress: DownloadProgress| {
        let _ = app_handle.emit_all("download-progress", progress);
    };

    match model_type.as_str() {
        "whisper" => {
            download_whisper_model(&resource_dir, progress_callback)
                .await
                .map_err(|e| e.to_string())?;
        }
        "llama" => {
            download_ollama_model(progress_callback)
                .await
                .map_err(|e| e.to_string())?;
        }
        _ => return Err(format!("Unknown model type: {}", model_type)),
    }

    Ok(())
}

/// Check backend health
#[tauri::command]
async fn check_backend_health() -> Result<serde_json::Value, String> {
    let client = reqwest::Client::new();

    let response = client
        .get("http://localhost:8080/api/health")
        .send()
        .await
        .map_err(|e| format!("Health check failed: {}", e))?;

    let health = response
        .json::<serde_json::Value>()
        .await
        .map_err(|e| format!("Failed to parse health response: {}", e))?;

    Ok(health)
}

fn main() {
    // Load or create configuration
    let config = load_config().unwrap_or_default();

    tauri::Builder::default()
        .manage(AppState {
            process_manager: Mutex::new(ProcessManager::new()),
            config: Mutex::new(config),
        })
        .invoke_handler(tauri::generate_handler![
            is_first_run,
            complete_setup,
            get_config,
            update_config,
            start_services,
            stop_services,
            get_service_status,
            download_model,
            check_backend_health,
        ])
        .setup(|app| {
            // Perform any initial setup here
            println!("CliniScribe starting...");
            Ok(())
        })
        .on_window_event(|event| {
            if let tauri::WindowEvent::CloseRequested { .. } = event.event() {
                // Graceful shutdown handled by Tauri's lifecycle
                println!("Window closing, services will be cleaned up");
            }
        })
        .build(tauri::generate_context!())
        .expect("error while building tauri application")
        .run(|_app_handle, event| {
            if let tauri::RunEvent::ExitRequested { .. } = event {
                // Cleanup happens here
                println!("Application exiting");
            }
        });
}
