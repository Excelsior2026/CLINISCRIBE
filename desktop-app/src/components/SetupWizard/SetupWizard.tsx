import { useState } from 'react';
import { invoke } from '@tauri-apps/api/tauri';
import { listen } from '@tauri-apps/api/event';
import WelcomeStep from './WelcomeStep';
import ModelDownloadStep from './ModelDownloadStep';
import CompletionStep from './CompletionStep';

interface SetupWizardProps {
  onComplete: () => void;
}

type SetupStep = 'welcome' | 'download' | 'complete';

function SetupWizard({ onComplete }: SetupWizardProps) {
  const [currentStep, setCurrentStep] = useState<SetupStep>('welcome');
  const [downloadProgress, setDownloadProgress] = useState<any>(null);

  const handleNext = () => {
    if (currentStep === 'welcome') {
      setCurrentStep('download');
      startModelDownloads();
    } else if (currentStep === 'download') {
      setCurrentStep('complete');
    } else if (currentStep === 'complete') {
      onComplete();
    }
  };

  const startModelDownloads = async () => {
    // Listen for download progress
    await listen('download-progress', (event: any) => {
      setDownloadProgress(event.payload);
    });

    try {
      // Download Whisper model
      await invoke('download_model', { modelType: 'whisper' });

      // Download Llama model
      await invoke('download_model', { modelType: 'llama' });

      // Both downloads complete
      setTimeout(() => {
        setCurrentStep('complete');
      }, 1000);
    } catch (err) {
      console.error('Model download failed:', err);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-teal-50">
      {currentStep === 'welcome' && <WelcomeStep onNext={handleNext} />}
      {currentStep === 'download' && (
        <ModelDownloadStep
          progress={downloadProgress}
          onNext={handleNext}
        />
      )}
      {currentStep === 'complete' && <CompletionStep onNext={handleNext} />}
    </div>
  );
}

export default SetupWizard;
