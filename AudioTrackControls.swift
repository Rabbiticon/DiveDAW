import Foundation
import AudioKit

class AudioTrackControls: ObservableObject {
    // MARK: - Properties
    
    @Published var isMuted: Bool = false {
        didSet {
            updateVolume()
        }
    }
    
    @Published var decibelValue: Float = 0.0 {
        didSet {
            // Convert decibel to amplitude (0 dB = 1.0 amplitude)
            volume = pow(10.0, decibelValue / 20.0)
            updateVolume()
        }
    }
    
    @Published var isFlexModeEnabled: Bool = false {
        didSet {
            updateFlexMode()
        }
    }
    
    @Published var slicePoints: [TimeInterval] = [] {
        didSet {
            updateSlicing()
        }
    }
    
    // Internal properties
    private var volume: Float = 1.0
    private weak var track: AudioTrack?
    private var originalTempo: Double?
    private var timeStretchRatio: Double = 1.0
    
    // MARK: - Initialization
    
    init(track: AudioTrack) {
        self.track = track
    }
    
    // MARK: - Volume Control
    
    private func updateVolume() {
        guard let track = track else { return }
        track.mixer.volume = isMuted ? 0.0 : volume
    }
    
    // MARK: - Flex Mode
    
    func updateTempoStretch(newTempo: Double) {
        guard isFlexModeEnabled else { return }
        
        if originalTempo == nil {
            originalTempo = newTempo
        }
        
        guard let originalTempo = originalTempo else { return }
        
        // Calculate time stretch ratio
        timeStretchRatio = originalTempo / newTempo
        
        // Apply time stretching to audio
        applyTimeStretch()
    }
    
    private func updateFlexMode() {
        if !isFlexModeEnabled {
            // Reset time stretching when flex mode is disabled
            timeStretchRatio = 1.0
            applyTimeStretch()
            originalTempo = nil
        }
    }
    
    private func applyTimeStretch() {
        // Implementation will use AudioKit's time stretching capabilities
        // This will be implemented when adding audio file support
    }
    
    // MARK: - Slicing
    
    func addSlicePoint(at time: TimeInterval) {
        if !slicePoints.contains(time) {
            slicePoints.append(time)
            slicePoints.sort()
            updateSlicing()
        }
    }
    
    func removeSlicePoint(at time: TimeInterval) {
        if let index = slicePoints.firstIndex(of: time) {
            slicePoints.remove(at: index)
            updateSlicing()
        }
    }
    
    private func updateSlicing() {
        guard let track = track else { return }
        
        // Stop any existing playback
        track.mixer.removeAllInputs()
        
        // Iterate over slice points and create segments
        var previousTime: TimeInterval = 0.0
        for slicePoint in slicePoints {
            let segmentDuration = slicePoint - previousTime
            let segmentNode = AudioPlayerNode()
            segmentNode.scheduleSegment(from: previousTime, duration: segmentDuration)
            track.mixer.addInput(segmentNode)
            previousTime = slicePoint
        }
        
        // Handle the last segment
        let lastSegmentNode = AudioPlayerNode()
        lastSegmentNode.scheduleSegment(from: previousTime, duration: track.duration - previousTime)
        track.mixer.addInput(lastSegmentNode)
        
        // Start playback
        track.mixer.start()
    }
}