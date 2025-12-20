import { useState, useEffect } from 'react';
import { invoke } from '@tauri-apps/api/tauri';
import { open } from '@tauri-apps/api/dialog';

interface AppConfig {
  setup_completed: boolean;
  whisper_model: string;
  ollama_model: string;
  use_gpu: boolean;
  default_ratio: number;
  default_subject: string;
  data_directory: string;
  auto_delete_days: number;
  theme: string;
  auto_updates: boolean;
}

interface SettingsModalProps {
  onClose: () => void;
}

function SettingsModal({ onClose }: SettingsModalProps) {
  const [config, setConfig] = useState<AppConfig | null>(null);
  const [isSaving, setIsSaving] = useState(false);
  const [saveMessage, setSaveMessage] = useState('');

  useEffect(() => {
    loadConfig();
  }, []);

  const loadConfig = async () => {
    try {
      const cfg = await invoke<AppConfig>('get_config');
      setConfig(cfg);
    } catch (err) {
      console.error('Failed to load config:', err);
    }
  };

  const handleSave = async () => {
    if (!config) return;

    setIsSaving(true);
    setSaveMessage('');

    try {
      await invoke('update_config', { newConfig: config });
      setSaveMessage('Settings saved successfully!');
      setTimeout(() => {
        setSaveMessage('');
        onClose();
      }, 1500);
    } catch (err) {
      setSaveMessage(`Failed to save: ${err}`);
    } finally {
      setIsSaving(false);
    }
  };

  const selectDataDirectory = async () => {
    try {
      const selected = await open({
        directory: true,
        multiple: false,
      });

      if (selected && typeof selected === 'string' && config) {
        setConfig({ ...config, data_directory: selected });
      }
    } catch (err) {
      console.error('Failed to select directory:', err);
    }
  };

  if (!config) {
    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-2xl p-8">
          <div className="animate-spin h-12 w-12 border-4 border-blue-500 border-t-transparent rounded-full mx-auto"></div>
          <p className="text-gray-600 mt-4">Loading settings...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-white border-b border-gray-200 px-6 py-4 rounded-t-2xl">
          <div className="flex items-center justify-between">
            <h2 className="text-2xl font-bold text-gray-800">Settings</h2>
            <button
              onClick={onClose}
              className="text-gray-500 hover:text-gray-700 p-2 rounded-lg hover:bg-gray-100"
            >
              <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Model Settings */}
          <section>
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Model Settings</h3>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Whisper Model Size
                </label>
                <select
                  value={config.whisper_model}
                  onChange={(e) => setConfig({ ...config, whisper_model: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="tiny">Tiny (fastest, least accurate)</option>
                  <option value="base">Base (balanced - recommended)</option>
                  <option value="small">Small (slower, more accurate)</option>
                  <option value="medium">Medium (slow, very accurate)</option>
                  <option value="large-v3">Large (slowest, most accurate)</option>
                </select>
                <p className="text-xs text-gray-500 mt-1">
                  Larger models are more accurate but require more memory and processing time
                </p>
              </div>

              <div>
                <label className="flex items-center gap-3 cursor-pointer">
                  <input
                    type="checkbox"
                    checked={config.use_gpu}
                    onChange={(e) => setConfig({ ...config, use_gpu: e.target.checked })}
                    className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                  />
                  <div>
                    <span className="text-sm font-medium text-gray-700">Use GPU Acceleration</span>
                    <p className="text-xs text-gray-500">Requires NVIDIA GPU with CUDA</p>
                  </div>
                </label>
              </div>
            </div>
          </section>

          {/* Processing Defaults */}
          <section className="border-t border-gray-200 pt-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Processing Defaults</h3>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Default Summary Length: {config.default_ratio === 0.05 ? 'Very Brief' : config.default_ratio === 0.1 ? 'Brief' : config.default_ratio === 0.15 ? 'Balanced' : config.default_ratio === 0.2 ? 'Detailed' : 'Comprehensive'}
                </label>
                <input
                  type="range"
                  min="0.05"
                  max="0.30"
                  step="0.05"
                  value={config.default_ratio}
                  onChange={(e) => setConfig({ ...config, default_ratio: parseFloat(e.target.value) })}
                  className="w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer"
                />
                <div className="flex justify-between text-xs text-gray-500 mt-1">
                  <span>Quick</span>
                  <span>Balanced</span>
                  <span>Thorough</span>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Default Subject
                </label>
                <select
                  value={config.default_subject}
                  onChange={(e) => setConfig({ ...config, default_subject: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="">General</option>
                  <option value="anatomy">Anatomy</option>
                  <option value="physiology">Physiology</option>
                  <option value="pharmacology">Pharmacology</option>
                  <option value="pathophysiology">Pathophysiology</option>
                  <option value="clinical skills">Clinical Skills</option>
                  <option value="nursing fundamentals">Nursing Fundamentals</option>
                </select>
              </div>
            </div>
          </section>

          {/* Storage Settings */}
          <section className="border-t border-gray-200 pt-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">Storage Settings</h3>

            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Data Directory
                </label>
                <div className="flex gap-2">
                  <input
                    type="text"
                    value={config.data_directory}
                    readOnly
                    className="flex-1 px-4 py-2 border border-gray-300 rounded-lg bg-gray-50 text-gray-700 text-sm"
                  />
                  <button
                    onClick={selectDataDirectory}
                    className="px-4 py-2 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors text-sm font-medium"
                  >
                    Browse
                  </button>
                </div>
                <p className="text-xs text-gray-500 mt-1">
                  Where audio files and processing data are stored
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Auto-delete audio files after (days)
                </label>
                <input
                  type="number"
                  min="0"
                  max="365"
                  value={config.auto_delete_days}
                  onChange={(e) => setConfig({ ...config, auto_delete_days: parseInt(e.target.value) || 0 })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <p className="text-xs text-gray-500 mt-1">
                  Set to 0 to never auto-delete (manual cleanup only)
                </p>
              </div>
            </div>
          </section>

          {/* App Preferences */}
          <section className="border-t border-gray-200 pt-6">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">App Preferences</h3>

            <div className="space-y-3">
              <label className="flex items-center gap-3 cursor-pointer">
                <input
                  type="checkbox"
                  checked={config.auto_updates}
                  onChange={(e) => setConfig({ ...config, auto_updates: e.target.checked })}
                  className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
                />
                <span className="text-sm text-gray-700">
                  Automatically check for updates
                </span>
              </label>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">
                  Theme
                </label>
                <select
                  value={config.theme}
                  onChange={(e) => setConfig({ ...config, theme: e.target.value })}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                >
                  <option value="light">Light</option>
                  <option value="dark">Dark (coming soon)</option>
                  <option value="auto">Auto (coming soon)</option>
                </select>
              </div>
            </div>
          </section>

          {/* Save Message */}
          {saveMessage && (
            <div className={`p-4 rounded-lg ${
              saveMessage.includes('success')
                ? 'bg-green-50 text-green-700 border border-green-200'
                : 'bg-red-50 text-red-700 border border-red-200'
            }`}>
              {saveMessage}
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="sticky bottom-0 bg-gray-50 border-t border-gray-200 px-6 py-4 rounded-b-2xl flex justify-end gap-3">
          <button
            onClick={onClose}
            className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-100 transition-colors font-medium"
          >
            Cancel
          </button>
          <button
            onClick={handleSave}
            disabled={isSaving}
            className="px-6 py-2 bg-gradient-to-r from-blue-600 to-teal-600 text-white rounded-lg hover:from-blue-700 hover:to-teal-700 transition-all shadow-lg hover:shadow-xl disabled:opacity-50 disabled:cursor-not-allowed font-medium"
          >
            {isSaving ? 'Saving...' : 'Save Changes'}
          </button>
        </div>
      </div>
    </div>
  );
}

export default SettingsModal;
