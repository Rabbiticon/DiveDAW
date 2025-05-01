import Foundation
import AudioKit

class SampleLibrary {
    enum SampleCategory {
        case acoustic
        case electronic
        case orchestral
        case percussion
        case synthesizer
    }
    
    struct Sample {
        let name: String
        let category: SampleCategory
        let velocityLayers: [Int: Node] // Maps velocity (0-127) to sample
        let loopPoints: (start: Int, end: Int)?
        var baseNote: MIDIByte
        var rootFrequency: Float
    }
    
    private var samples: [String: Sample] = [:]
    private let sampleRate: Double = 44100
    private let bitsPerSample: Int = 24
    
    // Singleton instance
    static let shared = SampleLibrary()
    
    private init() {
        loadDefaultSamples()
    }
    
    private func loadDefaultSamples() {
        // Load built-in high-quality samples
        loadPianoSamples()
        loadBassInstruments()
        loadGuitarSamples()
        loadSynthesizerSamples()
    }
    
    private func loadPianoSamples() {
        // Grand Piano with 4 velocity layers
        let pianoLayers: [Int: Node] = [
            32: createSampleNode("piano_pp"), // pianissimo
            64: createSampleNode("piano_mp"), // mezzo-piano
            96: createSampleNode("piano_mf"), // mezzo-forte
            127: createSampleNode("piano_ff") // fortissimo
        ]
        
        let grandPiano = Sample(
            name: "Concert Grand Piano",
            category: .acoustic,
            velocityLayers: pianoLayers,
            loopPoints: nil,
            baseNote: 60, // Middle C
            rootFrequency: 261.63 // C4 frequency
        )
        
        samples["grand_piano"] = grandPiano
    }
    
    private func loadBassInstruments() {
        // Electric Bass with 3 velocity layers
        let bassLayers: [Int: Node] = [
            42: createSampleNode("bass_soft"),
            84: createSampleNode("bass_medium"),
            127: createSampleNode("bass_hard")
        ]
        
        let electricBass = Sample(
            name: "Electric Bass",
            category: .electronic,
            velocityLayers: bassLayers,
            loopPoints: nil,
            baseNote: 48, // C3
            rootFrequency: 130.81
        )
        
        samples["electric_bass"] = electricBass
    }
    
    private func loadGuitarSamples() {
        // Acoustic Guitar with 3 velocity layers
        let guitarLayers: [Int: Node] = [
            42: createSampleNode("guitar_soft"),
            84: createSampleNode("guitar_medium"),
            127: createSampleNode("guitar_hard")
        ]
        
        let acousticGuitar = Sample(
            name: "Acoustic Guitar",
            category: .acoustic,
            velocityLayers: guitarLayers,
            loopPoints: nil,
            baseNote: 55, // G3
            rootFrequency: 196.00
        )
        
        samples["acoustic_guitar"] = acousticGuitar
    }
    
    private func loadSynthesizerSamples() {
        // Synthesizer with 2 velocity layers
        let synthLayers: [Int: Node] = [
            64: createSampleNode("synth_soft"),
            127: createSampleNode("synth_hard")
        ]
        
        let synthPad = Sample(
            name: "Synth Pad",
            category: .synthesizer,
            velocityLayers: synthLayers,
            loopPoints: (start: 0, end: 44100), // 1 second loop
            baseNote: 60,
            rootFrequency: 261.63
        )
        
        samples["synth_pad"] = synthPad
    }
    
    private func createSampleNode(_ name: String) -> Node {
        // In a real implementation, this would load actual audio files
        // For now, create a complex oscillator system as a placeholder
        let mainOscillator = Oscillator(waveform: .sawtooth)
        mainOscillator.amplitude = 0.4
        mainOscillator.frequency = 440.0
        
        // Add a second oscillator for richness
        let subOscillator = Oscillator(waveform: .square)
        subOscillator.amplitude = 0.3
        subOscillator.frequency = 220.0 // One octave below
        
        // Add a noise component for texture
        let noiseOscillator = Oscillator(waveform: .noise)
        noiseOscillator.amplitude = 0.1
        
        // Create a mixer to combine all oscillators
        let mixer = Mixer([mainOscillator, subOscillator, noiseOscillator])
        
        // Add filter with envelope
        let filter = LowPassFilter(mixer)
        filter.cutoffFrequency = 2000
        filter.resonance = 0.3
        
        // Add envelope for amplitude and filter
        mainOscillator.modulateAmplitude(amount: 1.0, attackTime: 0.02, decayTime: 0.1, sustainLevel: 0.7, releaseTime: 0.5)
        subOscillator.modulateAmplitude(amount: 1.0, attackTime: 0.03, decayTime: 0.15, sustainLevel: 0.6, releaseTime: 0.6)
        
        // Add some modulation
        mainOscillator.modulateFrequency(amount: 5.0, rate: 5.0)
        
        return filter
    }

    func getSample(name: String) -> Sample? {
        return samples[name]
    }
    
    func getVelocityLayer(for sample: Sample, velocity: MIDIByte) -> Node? {
        // Find the appropriate velocity layer
        let velocityKeys = sample.velocityLayers.keys.sorted()
        guard let layerIndex = velocityKeys.firstIndex(where: { $0 >= velocity }) else {
            return sample.velocityLayers[velocityKeys.last!]
        }
        return sample.velocityLayers[velocityKeys[layerIndex]]
    }
    
    func calculatePitchRatio(from sample: Sample, to midiNote: MIDIByte) -> Float {
        let targetFreq = Float(midiNote).midiNoteToFrequency()
        return targetFreq / sample.rootFrequency
    }
}