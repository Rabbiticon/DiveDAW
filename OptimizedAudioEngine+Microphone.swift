import Foundation
import AudioKit

extension OptimizedAudioEngine {
    // MARK: - Microphone Track Management
    
    func createMicrophoneTrack() -> MicrophoneTrack {
        let track = MicrophoneTrack()
        let processor = TrackProcessor(simdProcessor: simdProcessor,
                                     effectsProcessor: effectsProcessor)
        
        tracks.append(track)
        trackProcessors[track.id] = processor
        mainMixer.addInput(track.mixer)
        
        // Configure audio session for microphone input if needed
        configureMicrophonePermissions()
        
        return track
    }
    
    private func configureMicrophonePermissions() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord,
                                       options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try audioSession.setActive(true)
            
            // Request microphone permissions
            switch audioSession.recordPermission {
            case .undetermined:
                audioSession.requestRecordPermission { granted in
                    if !granted {
                        print("Microphone access denied")
                    }
                }
            case .denied:
                print("Microphone access denied")
            case .granted:
                break
            @unknown default:
                break
            }
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
    
    // MARK: - Recording Management
    
    func startRecording(track: MicrophoneTrack) {
        // Ensure optimal buffer size for recording
        if currentBufferSize > 512 {
            updateBufferSize(512) // Use smaller buffer size for lower latency during recording
        }
        
        track.startRecording()
    }
    
    func stopRecording(track: MicrophoneTrack) {
        track.stopRecording()
        
        // Restore original buffer size optimization
        optimizeBufferSize()
    }
}