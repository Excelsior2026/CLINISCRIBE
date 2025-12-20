interface CompletionStepProps {
  onNext: () => void;
}

function CompletionStep({ onNext }: CompletionStepProps) {
  return (
    <div className="flex flex-col items-center justify-center min-h-screen p-8">
      <div className="max-w-2xl text-center">
        <div className="bg-white rounded-2xl shadow-xl p-8">
          {/* Success Icon */}
          <div className="mb-6">
            <div className="w-24 h-24 bg-gradient-to-r from-green-400 to-teal-400 rounded-full flex items-center justify-center mx-auto animate-bounce-once">
              <svg className="w-12 h-12 text-white" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd"/>
              </svg>
            </div>
          </div>

          <h2 className="text-4xl font-bold text-gray-800 mb-4">
            All Set! 🎉
          </h2>

          <p className="text-xl text-gray-600 mb-8">
            CliniScribe is ready to transform your lecture recordings into study notes.
          </p>

          {/* Quick Start Guide */}
          <div className="bg-gradient-to-r from-blue-50 to-teal-50 rounded-xl p-6 mb-8 text-left">
            <h3 className="text-lg font-semibold text-gray-800 mb-4">
              Quick Start Guide:
            </h3>
            <ol className="space-y-3">
              <li className="flex items-start gap-3">
                <span className="flex-shrink-0 w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-semibold">
                  1
                </span>
                <span className="text-gray-700">
                  <strong>Upload</strong> your lecture recording (MP3, WAV, M4A, etc.)
                </span>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex-shrink-0 w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-semibold">
                  2
                </span>
                <span className="text-gray-700">
                  <strong>Choose</strong> your subject (anatomy, pharmacology, etc.)
                </span>
              </li>
              <li className="flex items-start gap-3">
                <span className="flex-shrink-0 w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center text-sm font-semibold">
                  3
                </span>
                <span className="text-gray-700">
                  <strong>Process</strong> and get your structured study notes!
                </span>
              </li>
            </ol>
          </div>

          {/* Features Reminder */}
          <div className="grid grid-cols-3 gap-4 mb-8">
            <div className="p-3 bg-white border border-gray-200 rounded-lg">
              <div className="text-2xl mb-1">⚡</div>
              <div className="text-xs font-semibold text-gray-700">Fast Processing</div>
            </div>
            <div className="p-3 bg-white border border-gray-200 rounded-lg">
              <div className="text-2xl mb-1">🔒</div>
              <div className="text-xs font-semibold text-gray-700">100% Private</div>
            </div>
            <div className="p-3 bg-white border border-gray-200 rounded-lg">
              <div className="text-2xl mb-1">📱</div>
              <div className="text-xs font-semibold text-gray-700">Works Offline</div>
            </div>
          </div>

          {/* Launch Button */}
          <button
            onClick={onNext}
            className="bg-gradient-to-r from-blue-600 to-teal-600 text-white font-semibold py-4 px-16 rounded-xl hover:from-blue-700 hover:to-teal-700 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-0.5 text-lg mb-4"
          >
            Launch CliniScribe
          </button>

          <p className="text-sm text-gray-500">
            Happy studying! 🎓
          </p>
        </div>
      </div>
    </div>
  );
}

export default CompletionStep;
