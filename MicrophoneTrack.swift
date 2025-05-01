import Foundation
import AudioKit

class MicrophoneTrack: AudioTrack {
    // Audio input components
    private var mic: AudioEngine.InputNode?
    private var autotuneNode: AutotuneProcessor
    
    // Autotune parameters
    @Published var autotuneEnabled: Bool = false {
        didSet { updateSignalChain() }
    }
    @Published var autotuneIntensity: Float = 0.5 {
        didSet { autotuneNode.intensity = autotuneIntensity }
    }
    @Published var autotuneSpeed: Float = 0.1 {
        didSet { autotuneNode.speed = autotuneSpeed }
    }
    @Published var selectedScale: Scale = .chromatic {
        didSet { autotuneNode.scale = selectedScale }
    }
    
    // Recording state
    @Published private(set) var isRecording = false
    private var recordingBuffer: AVAudioPCMBuffer?
    private var recordingStartTime: TimeInterval = 0
    
    override init() {
        autotuneNode = AutotuneProcessor()
        super.init()
        name = "Microphone"
        setupMicrophoneInput()
    }
    
    private func setupMicrophoneInput() {
        do {
            mic = try AudioEngine.InputNode()
            updateSignalChain()
        } catch {
            print("Error setting up microphone input: \(error)")
        }
    }
    
    private func updateSignalChain() {
        mixer.removeAllInputs()
        
        guard let mic = mic else { return }
        
        if autotuneEnabled {
            mic >>> autotuneNode >>> mixer
        } else {
            mic >>> mixer
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        do {
            let format = mic?.outputFormat(forBus: 0)
            recordingBuffer = try AVAudioPCMBuffer(maximumDuration: 3600, format: format!) // 1 hour max
            recordingStartTime = AVAudioTime.now().timeIntervalSince1970
            isRecording = true
            
            mic?.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak self] buffer, time in
                self?.processMicrophoneBuffer(buffer)
            }
        } catch {
            print("Error starting recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        mic?.removeTap(onBus: 0)
        isRecording = false
        
        // Process and save the recording
        if let buffer = recordingBuffer {
            saveRecording(buffer)
        }
        
        recordingBuffer = nil
    }
    
    private func processMicrophoneBuffer(_ buffer: AVAudioPCMBuffer) {
        guard isRecording, let recordingBuffer = recordingBuffer else { return }
        
        // Append the new audio data to our recording buffer
        let frameCount = AVAudioFrameCount(buffer.frameLength)
        if let channelData = buffer.floatChannelData?[0] {
            recordingBuffer.append(channelData, frameCount: frameCount)
        }
    }
    
    private func saveRecording(_ buffer: AVAudioPCMBuffer) {
        // Here we would save the recording to disk or process it further
        // This will be implemented based on the project's audio file handling system
    }
}

// MARK: - Autotune Processor

class AutotuneProcessor: Node {
    var intensity: Float = 0.5
    var speed: Float = 0.1
    var scale: Scale = .chromatic
    
    private var pitchNode: PitchTap?
    private var previousPitch: Float = 0
    
    override func makeAudioUnit() throws -> AudioUnit {
        let au = try AVAudioUnitEffect(preset: .pitchCorrection)
        
        // Configure autotune parameters
        try au.auAudioUnit.setValue(intensity, forParameter: .intensity)
        try au.auAudioUnit.setValue(speed, forParameter: .speed)
        try au.auAudioUnit.setValue(scale.rawValue, forParameter: .scale)
        
        return au
    }
}

// MARK: - Scale Enum

enum Scale: Int {
    case chromatic = 0
    case major = 1
    case minor = 2
    case pentatonic = 3
}