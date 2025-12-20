import { useState } from 'react';
import { writeText } from '@tauri-apps/api/clipboard';
import { save } from '@tauri-apps/api/dialog';
import { writeTextFile } from '@tauri-apps/api/fs';

interface ResultsPanelProps {
  data: any;
}

function ResultsPanel({ data }: ResultsPanelProps) {
  const [copiedSection, setCopiedSection] = useState<string | null>(null);
  const [showTranscript, setShowTranscript] = useState(false);

  const { transcript, summary, metadata } = data;

  const copyToClipboard = async (text: string, section: string) => {
    try {
      await writeText(text);
      setCopiedSection(section);
      setTimeout(() => setCopiedSection(null), 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
    }
  };

  const exportAsMarkdown = async () => {
    const markdown = `# Study Notes

**Source**: ${metadata.filename}
**Duration**: ${metadata.duration} seconds
**Language**: ${metadata.language}
**Subject**: ${metadata.subject || 'General'}
**Date**: ${new Date().toLocaleDateString()}

---

${summary}

---

## Full Transcript

${transcript.text}
`;

    try {
      const filePath = await save({
        defaultPath: `${metadata.filename}_notes.md`,
        filters: [{
          name: 'Markdown',
          extensions: ['md']
        }]
      });

      if (filePath) {
        await writeTextFile(filePath, markdown);
        alert('Notes exported successfully!');
      }
    } catch (err) {
      console.error('Failed to export:', err);
      alert('Failed to export notes');
    }
  };

  return (
    <div className="bg-white rounded-2xl shadow-lg p-8 space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between border-b border-gray-200 pb-4">
        <div>
          <h2 className="text-2xl font-bold text-gray-800">Study Notes</h2>
          <p className="text-sm text-gray-500 mt-1">
            {metadata.filename} • {Math.floor(metadata.duration / 60)} min {Math.floor(metadata.duration % 60)} sec
          </p>
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => copyToClipboard(summary, 'notes')}
            className="px-4 py-2 bg-blue-100 text-blue-700 rounded-lg hover:bg-blue-200 transition-colors text-sm font-medium flex items-center gap-2"
          >
            {copiedSection === 'notes' ? (
              <>
                <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                  <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd"/>
                </svg>
                Copied!
              </>
            ) : (
              <>
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z" />
                </svg>
                Copy
              </>
            )}
          </button>

          <button
            onClick={exportAsMarkdown}
            className="px-4 py-2 bg-teal-100 text-teal-700 rounded-lg hover:bg-teal-200 transition-colors text-sm font-medium flex items-center gap-2"
          >
            <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
            Export
          </button>
        </div>
      </div>

      {/* Summary */}
      <div className="prose max-w-none">
        <div className="bg-gradient-to-r from-blue-50 to-teal-50 rounded-xl p-6">
          <pre className="whitespace-pre-wrap font-sans text-gray-800 leading-relaxed">
            {summary}
          </pre>
        </div>
      </div>

      {/* Transcript Toggle */}
      <div>
        <button
          onClick={() => setShowTranscript(!showTranscript)}
          className="flex items-center gap-2 text-gray-700 hover:text-gray-900 font-medium"
        >
          <svg
            className={`w-5 h-5 transition-transform ${showTranscript ? 'rotate-90' : ''}`}
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
          </svg>
          {showTranscript ? 'Hide' : 'Show'} Full Transcript ({transcript.segments.length} segments)
        </button>

        {showTranscript && (
          <div className="mt-4">
            <div className="flex justify-end mb-2">
              <button
                onClick={() => copyToClipboard(transcript.text, 'transcript')}
                className="px-3 py-1 bg-gray-100 text-gray-700 rounded-lg hover:bg-gray-200 transition-colors text-sm flex items-center gap-2"
              >
                {copiedSection === 'transcript' ? (
                  <>
                    <svg className="w-4 h-4" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd"/>
                    </svg>
                    Copied!
                  </>
                ) : (
                  'Copy Transcript'
                )}
              </button>
            </div>

            <div className="bg-gray-50 rounded-xl p-6 max-h-96 overflow-y-auto border border-gray-200">
              <div className="space-y-3">
                {transcript.segments.map((segment: any, index: number) => (
                  <div key={index} className="flex gap-3">
                    <span className="text-xs text-gray-500 font-mono flex-shrink-0">
                      {formatTime(segment.start)}
                    </span>
                    <p className="text-sm text-gray-800 leading-relaxed">
                      {segment.text}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

function formatTime(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = Math.floor(seconds % 60);
  return `${mins}:${secs.toString().padStart(2, '0')}`;
}

export default ResultsPanel;
