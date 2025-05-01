import Foundation
import AudioKit
import AVFoundation
import CoreAudio
import Accelerate

class RetroEffect: ObservableObject {
    @Published var isEnabled: Bool = false
    @Published var mix: Double = 0.5
    @Published var noiseAmount: Double = 0.0
    @Published var wowAmount: Double = 0.0
    @Published var flutterAmount: Double = 0.0
    @Published var saturation: Double = 0.0
    @Published var compression: Double = 0.0
    @Published var tapeAge: Double = 0.0
    @Published var stereoWidth: Double = 1.0
    @Published var currentPreset: Preset?
    @Published var isProcessing: Bool = false
    @Published var cpuUsage: Double = 0.0
    @Published var latency: UInt32 = 0
    @Published var sampleRate: Double = 44100.0
    @Published var bufferSize: UInt32 = 1024
    
    private var noiseGenerator: AKWhiteNoise?
    private var wowGenerator: AKVariableDelay?
    private var flutterGenerator: AKVariableDelay?
    private var saturationProcessor: AKClipper?
    private var compressor: AKCompressor?
    private var stereoProcessor: AKStereoFieldLimiter?
    private var tapeAgeProcessor: TapeAgeProcessor?
    private var inputBuffer: AVAudioPCMBuffer?
    private var outputBuffer: AVAudioPCMBuffer?
    private var processingQueue: DispatchQueue
    private var processingTimer: Timer?
    private var lastProcessTime: TimeInterval = 0
    private var audioUnit: AudioUnit?
    private var midiInputPort: MIDIPortRef?
    private var midiOutputPort: MIDIPortRef?
    
    struct Preset: Identifiable, Codable {
        let id = UUID()
        var name: String
        var mix: Double
        var noiseAmount: Double
        var wowAmount: Double
        var flutterAmount: Double
        var saturation: Double
        var compression: Double
        var tapeAge: Double
        var stereoWidth: Double
        var creationDate: Date
        var modificationDate: Date
        var author: String
        var description: String
        var tags: [String]
        var rating: Double
        var isFavorite: Bool
        var isFactory: Bool
        var isProtected: Bool
        var thumbnail: Data?
        var metadata: [String: String]
    }
    
    let defaultPresets: [Preset] = [
        Preset(
            name: "Clean Tape",
            mix: 0.5,
            noiseAmount: 0.1,
            wowAmount: 0.1,
            flutterAmount: 0.1,
            saturation: 0.2,
            compression: 0.3,
            tapeAge: 0.2,
            stereoWidth: 1.0,
            creationDate: Date(),
            modificationDate: Date(),
            author: "DiveDaw",
            description: "Subtle tape warmth with minimal artifacts",
            tags: ["tape", "warm", "subtle"],
            rating: 4.5,
            isFavorite: false,
            isFactory: true,
            isProtected: false,
            thumbnail: nil,
            metadata: [:]
        ),
        Preset(
            name: "Vintage Warmth",
            mix: 0.7,
            noiseAmount: 0.3,
            wowAmount: 0.2,
            flutterAmount: 0.2,
            saturation: 0.4,
            compression: 0.5,
            tapeAge: 0.4,
            stereoWidth: 0.8,
            creationDate: Date(),
            modificationDate: Date(),
            author: "DiveDaw",
            description: "Classic tape warmth with moderate artifacts",
            tags: ["tape", "warm", "vintage"],
            rating: 4.8,
            isFavorite: false,
            isFactory: true,
            isProtected: false,
            thumbnail: nil,
            metadata: [:]
        ),
        Preset(
            name: "Lo-Fi Dreams",
            mix: 0.8,
            noiseAmount: 0.5,
            wowAmount: 0.4,
            flutterAmount: 0.4,
            saturation: 0.6,
            compression: 0.7,
            tapeAge: 0.6,
            stereoWidth: 0.6,
            creationDate: Date(),
            modificationDate: Date(),
            author: "DiveDaw",
            description: "Heavy tape saturation with pronounced artifacts",
            tags: ["tape", "lo-fi", "saturated"],
            rating: 4.2,
            isFavorite: false,
            isFactory: true,
            isProtected: false,
            thumbnail: nil,
            metadata: [:]
        ),
        Preset(
            name: "Broken Tape",
            mix: 1.0,
            noiseAmount: 0.7,
            wowAmount: 0.6,
            flutterAmount: 0.6,
            saturation: 0.8,
            compression: 0.9,
            tapeAge: 0.8,
            stereoWidth: 0.4,
            creationDate: Date(),
            modificationDate: Date(),
            author: "DiveDaw",
            description: "Extreme tape degradation with heavy artifacts",
            tags: ["tape", "broken", "extreme"],
            rating: 4.0,
            isFavorite: false,
            isFactory: true,
            isProtected: false,
            thumbnail: nil,
            metadata: [:]
        )
    ]
    
    init() {
        processingQueue = DispatchQueue(label: "com.divedaw.retroeffect.processing", qos: .userInteractive)
        setupAudioUnit()
        setupMIDI()
        startProcessingTimer()
    }
    
    deinit {
        stopProcessingTimer()
        cleanup()
    }
    
    private func setupAudioUnit() {
        var componentDescription = AudioComponentDescription(
            componentType: kAudioUnitType_Effect,
            componentSubType: OSType("Retr".utf8.first!),
            componentManufacturer: OSType("Dive".utf8.first!),
            componentFlags: 0,
            componentFlagsMask: 0
        )
        
        guard let component = AudioComponentFindNext(nil, &componentDescription) else {
            print("Failed to find audio component")
            return
        }
        
        var status = AudioComponentInstanceNew(component, &audioUnit)
        guard status == noErr else {
            print("Failed to create audio unit instance")
            return
        }
        
        // Set up audio unit properties
        var streamFormat = AudioStreamBasicDescription(
            mSampleRate: sampleRate,
            mFormatID: kAudioFormatLinearPCM,
            mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
            mBytesPerPacket: 8,
            mFramesPerPacket: 1,
            mBytesPerFrame: 8,
            mChannelsPerFrame: 2,
            mBitsPerChannel: 32,
            mReserved: 0
        )
        
        status = AudioUnitSetProperty(
            audioUnit!,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Input,
            0,
            &streamFormat,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        )
        
        guard status == noErr else {
            print("Failed to set input stream format")
            return
        }
        
        status = AudioUnitSetProperty(
            audioUnit!,
            kAudioUnitProperty_StreamFormat,
            kAudioUnitScope_Output,
            0,
            &streamFormat,
            UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        )
        
        guard status == noErr else {
            print("Failed to set output stream format")
            return
        }
        
        // Initialize audio unit
        status = AudioUnitInitialize(audioUnit!)
        guard status == noErr else {
            print("Failed to initialize audio unit")
            return
        }
    }
    
    private func setupMIDI() {
        var status = MIDIClientCreate("DiveDaw Retro Effect" as CFString, nil, nil, &midiInputPort)
        guard status == noErr else {
            print("Failed to create MIDI client")
            return
        }
        
        status = MIDIOutputPortCreate(midiInputPort!, "DiveDaw Retro Effect Output" as CFString, &midiOutputPort)
        guard status == noErr else {
            print("Failed to create MIDI output port")
            return
        }
    }
    
    private func startProcessingTimer() {
        processingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateProcessingStats()
        }
    }
    
    private func stopProcessingTimer() {
        processingTimer?.invalidate()
        processingTimer = nil
    }
    
    private func updateProcessingStats() {
        let currentTime = Date().timeIntervalSince1970
        let timeDiff = currentTime - lastProcessTime
        
        if timeDiff > 0 {
            cpuUsage = min(100.0, (timeDiff / 0.1) * 100.0)
        }
        
        lastProcessTime = currentTime
    }
    
    func setup(input: AKNode) {
        // Noise generator
        noiseGenerator = AKWhiteNoise()
        noiseGenerator?.amplitude = 0.0
        
        // Wow effect (slow pitch variation)
        wowGenerator = AKVariableDelay(input)
        wowGenerator?.time = 0.0
        wowGenerator?.feedback = 0.0
        
        // Flutter effect (fast pitch variation)
        flutterGenerator = AKVariableDelay(input)
        flutterGenerator?.time = 0.0
        flutterGenerator?.feedback = 0.0
        
        // Saturation
        saturationProcessor = AKClipper(input)
        saturationProcessor?.limit = 1.0
        
        // Compression
        compressor = AKCompressor(input)
        compressor?.threshold = -20.0
        compressor?.headRoom = 5.0
        compressor?.attackTime = 0.001
        compressor?.releaseTime = 0.05
        
        // Stereo width
        stereoProcessor = AKStereoFieldLimiter(input)
        stereoProcessor?.amount = 1.0
        
        // Tape age simulation
        tapeAgeProcessor = TapeAgeProcessor()
        tapeAgeProcessor?.setup(input: input)
        
        // Allocate buffers
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        )!
        
        inputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize)
        outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: bufferSize)
        
        updateParameters()
    }
    
    func updateParameters() {
        processingQueue.async { [weak self] in
            guard let self = self else { return }
            
            // Update noise
            self.noiseGenerator?.amplitude = self.noiseAmount * 0.1
            
            // Update wow effect
            let wowRate = 0.1 + (self.wowAmount * 0.4)
            let wowDepth = self.wowAmount * 0.02
            self.wowGenerator?.time = wowDepth * sin(2 * .pi * wowRate * Date().timeIntervalSince1970)
            
            // Update flutter effect
            let flutterRate = 5.0 + (self.flutterAmount * 15.0)
            let flutterDepth = self.flutterAmount * 0.005
            self.flutterGenerator?.time = flutterDepth * sin(2 * .pi * flutterRate * Date().timeIntervalSince1970)
            
            // Update saturation
            self.saturationProcessor?.limit = 1.0 - (self.saturation * 0.5)
            
            // Update compression
            self.compressor?.threshold = -20.0 - (self.compression * 20.0)
            self.compressor?.headRoom = 5.0 - (self.compression * 4.0)
            
            // Update stereo width
            self.stereoProcessor?.amount = self.stereoWidth
            
            // Update tape age
            self.tapeAgeProcessor?.updateParameters(age: self.tapeAge)
        }
    }
    
    func applyPreset(_ preset: Preset) {
        mix = preset.mix
        noiseAmount = preset.noiseAmount
        wowAmount = preset.wowAmount
        flutterAmount = preset.flutterAmount
        saturation = preset.saturation
        compression = preset.compression
        tapeAge = preset.tapeAge
        stereoWidth = preset.stereoWidth
        currentPreset = preset
        
        updateParameters()
    }
    
    func savePreset(name: String) -> Preset {
        let preset = Preset(
            name: name,
            mix: mix,
            noiseAmount: noiseAmount,
            wowAmount: wowAmount,
            flutterAmount: flutterAmount,
            saturation: saturation,
            compression: compression,
            tapeAge: tapeAge,
            stereoWidth: stereoWidth,
            creationDate: Date(),
            modificationDate: Date(),
            author: "User",
            description: "",
            tags: [],
            rating: 0.0,
            isFavorite: false,
            isFactory: false,
            isProtected: false,
            thumbnail: nil,
            metadata: [:]
        )
        
        currentPreset = preset
        return preset
    }
    
    func process(_ input: AKNode) -> AKNode {
        guard isEnabled else { return input }
        
        var processed = input
        
        // Apply noise
        if let noise = noiseGenerator {
            processed = AKMixer(processed, noise)
        }
        
        // Apply wow effect
        if let wow = wowGenerator {
            processed = wow
        }
        
        // Apply flutter effect
        if let flutter = flutterGenerator {
            processed = flutter
        }
        
        // Apply saturation
        if let saturation = saturationProcessor {
            processed = saturation
        }
        
        // Apply compression
        if let compression = compressor {
            processed = compression
        }
        
        // Apply tape age
        if let tapeAge = tapeAgeProcessor {
            processed = tapeAge.process(processed)
        }
        
        // Apply stereo width
        if let stereo = stereoProcessor {
            processed = stereo
        }
        
        // Mix with dry signal
        let dryWetMixer = AKMixer(input, processed)
        dryWetMixer.balance = mix
        
        return dryWetMixer
    }
    
    private func cleanup() {
        if let audioUnit = audioUnit {
            AudioUnitUninitialize(audioUnit)
            AudioComponentInstanceDispose(audioUnit)
        }
        
        if let midiInputPort = midiInputPort {
            MIDIPortDispose(midiInputPort)
        }
        
        if let midiOutputPort = midiOutputPort {
            MIDIPortDispose(midiOutputPort)
        }
    }
}

// MARK: - Tape Age Processor

class TapeAgeProcessor {
    private var inputBuffer: AVAudioPCMBuffer?
    private var outputBuffer: AVAudioPCMBuffer?
    private var delayLine: [Float]
    private var writeIndex: Int
    private var readIndex: Int
    private var bufferSize: Int
    private var sampleRate: Double
    private var age: Double
    private var noiseLevel: Double
    private var dropoutProbability: Double
    private var wowAmount: Double
    private var flutterAmount: Double
    private var saturation: Double
    private var highFrequencyLoss: Double
    private var lowFrequencyBoost: Double
    
    init() {
        bufferSize = 44100 // 1 second at 44.1kHz
        delayLine = Array(repeating: 0.0, count: bufferSize)
        writeIndex = 0
        readIndex = 0
        sampleRate = 44100.0
        age = 0.0
        noiseLevel = 0.0
        dropoutProbability = 0.0
        wowAmount = 0.0
        flutterAmount = 0.0
        saturation = 0.0
        highFrequencyLoss = 0.0
        lowFrequencyBoost = 0.0
    }
    
    func setup(input: AKNode) {
        let format = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 2,
            interleaved: false
        )!
        
        inputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(bufferSize))
        outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(bufferSize))
    }
    
    func updateParameters(age: Double) {
        self.age = age
        
        // Calculate effect parameters based on age
        noiseLevel = age * 0.3
        dropoutProbability = age * 0.2
        wowAmount = age * 0.4
        flutterAmount = age * 0.6
        saturation = age * 0.5
        highFrequencyLoss = age * 0.7
        lowFrequencyBoost = age * 0.3
    }
    
    func process(_ input: AKNode) -> AKNode {
        guard let inputBuffer = inputBuffer,
              let outputBuffer = outputBuffer else {
            return input
        }
        
        // Process audio in blocks
        let blockSize = 1024
        let numBlocks = bufferSize / blockSize
        
        for block in 0..<numBlocks {
            let startIndex = block * blockSize
            let endIndex = min(startIndex + blockSize, bufferSize)
            
            // Apply tape age effects
            for i in startIndex..<endIndex {
                // Get input sample
                let inputSample = inputBuffer.floatChannelData?[0][i] ?? 0.0
                
                // Apply wow and flutter
                let wowOffset = sin(2 * .pi * 0.1 * Double(i) / sampleRate) * wowAmount
                let flutterOffset = sin(2 * .pi * 5.0 * Double(i) / sampleRate) * flutterAmount
                let timeOffset = wowOffset + flutterOffset
                
                // Apply delay line
                writeIndex = (writeIndex + 1) % bufferSize
                delayLine[writeIndex] = inputSample
                
                // Calculate read position with time offset
                let readPosition = Double(readIndex) + timeOffset * sampleRate
                readIndex = Int(readPosition) % bufferSize
                
                // Get delayed sample
                var delayedSample = delayLine[readIndex]
                
                // Apply dropout
                if Double.random(in: 0...1) < dropoutProbability {
                    delayedSample = 0.0
                }
                
                // Apply noise
                let noise = (Double.random(in: -1...1) * noiseLevel)
                delayedSample += Float(noise)
                
                // Apply saturation
                delayedSample = tanh(delayedSample * Float(1.0 + saturation))
                
                // Apply frequency response
                delayedSample = applyFrequencyResponse(delayedSample)
                
                // Write to output buffer
                outputBuffer.floatChannelData?[0][i] = delayedSample
                outputBuffer.floatChannelData?[1][i] = delayedSample
            }
        }
        
        // Update frame length
        outputBuffer.frameLength = inputBuffer.frameLength
        
        return AKPlayer(audioFile: try! AVAudioFile(forWriting: outputBuffer))
    }
    
    private func applyFrequencyResponse(_ sample: Float) -> Float {
        // Apply high frequency loss
        var processed = sample * Float(1.0 - highFrequencyLoss)
        
        // Apply low frequency boost
        processed = processed * Float(1.0 + lowFrequencyBoost)
        
        return processed
    }
} 