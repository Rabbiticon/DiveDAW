import Foundation
import AudioKit

enum InstrumentType: String, Codable {
    case piano
    case electricPiano
    case bass
    case electricBass
    case guitar
    case electricGuitar
    
    var displayName: String {
        switch self {
        case .piano: return "Grand Piano"
        case .electricPiano: return "Electric Piano"
        case .bass: return "Acoustic Bass"
        case .electricBass: return "Electric Bass"
        case .guitar: return "Acoustic Guitar"
        case .electricGuitar: return "Electric Guitar"
        }
    }
}

class VirtualInstrument {
    let type: InstrumentType
    private var oscillators: [Oscillator] = []
    private var filter: Filter
    private var envelope: Envelope
    private var effects: [AudioEffect] = []
    private var mixer = Mixer()
    
    var isEnabled: Bool = true
    var volume: Float = 1.0 {
        didSet {
            mixer.volume = volume
        }
    }
    var pan: Float = 0.0 {
        didSet {
            mixer.pan = pan
        }
    }
    
    init(type: InstrumentType) {
        self.type = type
        self.filter = Filter()
        self.envelope = Envelope()
        
        setupOscillators()
        setupEffects()
        setupSignalChain()
    }
    
    private func setupOscillators() {
        switch type {
        case .piano:
            oscillators.append(Oscillator(waveform: .sine))
        case .electricPiano:
            oscillators.append(Oscillator(waveform: .triangle))
            oscillators.append(Oscillator(waveform: .sine))
        case .bass:
            oscillators.append(Oscillator(waveform: .sawtooth))
        case .electricBass:
            oscillators.append(Oscillator(waveform: .square))
            oscillators.append(Oscillator(waveform: .sawtooth))
        case .guitar:
            oscillators.append(Oscillator(waveform: .triangle))
        case .electricGuitar:
            oscillators.append(Oscillator(waveform: .sawtooth))
            oscillators.append(Oscillator(waveform: .square))
        }
    }
    
    private func setupEffects() {
        // Add default effects chain
        effects.append(AudioEffect(type: .reverb))
        effects.append(AudioEffect(type: .delay))
        effects.append(AudioEffect(type: .compressor))
    }
    
    private func setupSignalChain() {
        // Connect oscillators to mixer
        for oscillator in oscillators {
            mixer.addInput(oscillator.getOutputNode())
        }
        
        // Process through filter
        var processedSignal: Node = filter.process(input: mixer)
        
        // Process through envelope
        processedSignal = envelope.process(input: processedSignal)
        
        // Process through effects chain
        for effect in effects {
            processedSignal = effect.process(input: processedSignal)
        }
        
        // Set final output
        mixer.addInput(processedSignal)
    }
    
    func getOutputNode() -> Node {
        return mixer
    }
    
    func handleMIDIMessage(_ status: MIDIStatus, _ data1: MIDIByte, _ data2: MIDIByte) {
        switch status {
        case .noteOn:
            let frequency = MIDIByte(data1).midiNoteToFrequency()
            let velocity = Float(data2) / 127.0
            
            for oscillator in oscillators {
                oscillator.frequency = frequency
                oscillator.amplitude = velocity
                oscillator.start()
            }
            envelope.start()
            
        case .noteOff:
            envelope.stop()
            for oscillator in oscillators {
                oscillator.stop()
            }
            
        case .controlChange:
            handleControlChange(data1, value: data2)
            
        default:
            break
        }
    }
    
    private func handleControlChange(_ controller: MIDIByte, value: MIDIByte) {
        let normalizedValue = Float(value) / 127.0
        
        switch controller {
        case 1: // Modulation wheel
            filter.resonance = normalizedValue
        case 7: // Volume
            volume = normalizedValue
        case 10: // Pan
            pan = (normalizedValue * 2) - 1 // Convert to -1 to 1 range
        case 74: // Filter cutoff
            filter.cutoffFrequency = normalizedValue * 20000 // 0-20kHz range
        default:
            break
        }
    }
    
    // Parameter control methods
    func setOscillatorParameter(_ index: Int, parameter: String, value: Float) {
        guard index < oscillators.count else { return }
        
        switch parameter {
        case "frequency":
            oscillators[index].frequency = value
        case "amplitude":
            oscillators[index].amplitude = value
        case "detune":
            oscillators[index].detune = value
        default:
            break
        }
    }
    
    func setFilterParameter(_ parameter: String, value: Float) {
        switch parameter {
        case "cutoff":
            filter.cutoffFrequency = value
        case "resonance":
            filter.resonance = value
        case "mix":
            filter.mix = value
        default:
            break
        }
    }
    
    func setEnvelopeParameter(_ parameter: String, value: Float) {
        switch parameter {
        case "attack":
            envelope.attackDuration = value
        case "decay":
            envelope.decayDuration = value
        case "sustain":
            envelope.sustainLevel = value
        case "release":
            envelope.releaseDuration = value
        default:
            break
        }
    }
    
    func setEffectParameter(_ index: Int, parameter: String, value: Float) {
        guard index < effects.count else { return }
        effects[index].setParameter(parameter, value: value)
    }
}