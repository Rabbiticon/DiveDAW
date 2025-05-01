import Foundation
import AudioKit

class Oscillator {
    enum WaveformType {
        case sine
        case square
        case sawtooth
        case triangle
        case noise
        case pulse
        case superSaw
        case wavetable
    }
    
    private var oscillator: Node
    private var waveform: WaveformType
    private var syncOscillator: Oscillator?
    private var phaseModulator: Oscillator?
    private var wavetable: Table?
    
    // Basic parameters
    var frequency: Float = 440.0 {
        didSet {
            updateFrequency()
        }
    }
    
    var amplitude: Float = 0.5 {
        didSet {
            updateAmplitude()
        }
    }
    
    var detune: Float = 0.0 {
        didSet {
            updateDetune()
        }
    }
    
    // Advanced parameters
    var pulseWidth: Float = 0.5 {
        didSet {
            updatePulseWidth()
        }
    }
    
    var phase: Float = 0.0 {
        didSet {
            updatePhase()
        }
    }
    
    var syncAmount: Float = 0.0 {
        didSet {
            updateSync()
        }
    }
    
    var phaseModAmount: Float = 0.0 {
        didSet {
            updatePhaseMod()
        }
    }
    
    var wavetablePosition: Float = 0.0 {
        didSet {
            updateWavetablePosition()
        }
    }
    
    var superSawDetune: Float = 0.0 {
        didSet {
            updateSuperSaw()
        }
    }
    
    var superSawVoices: Int = 7 {
        didSet {
            updateSuperSaw()
        }
    }
    
    init(waveform: WaveformType = .sine) {
        self.waveform = waveform
        
        switch waveform {
        case .sine:
            oscillator = Oscillator(waveform: Table(.sine))
        case .square:
            oscillator = Oscillator(waveform: Table(.square))
        case .sawtooth:
            oscillator = Oscillator(waveform: Table(.sawtooth))
        case .triangle:
            oscillator = Oscillator(waveform: Table(.triangle))
        case .noise:
            oscillator = WhiteNoise()
        case .pulse:
            oscillator = Oscillator(waveform: Table(.square))
            updatePulseWidth()
        case .superSaw:
            oscillator = Oscillator(waveform: Table(.sawtooth))
            updateSuperSaw()
        case .wavetable:
            wavetable = Table(.sine)
            oscillator = Oscillator(waveform: wavetable!)
        }
        
        updateFrequency()
        updateAmplitude()
        updateDetune()
        updatePhase()
    }
    
    // MARK: - Parameter Updates
    
    private func updateFrequency() {
        if let osc = oscillator as? Oscillator {
            osc.frequency = frequency
        }
    }
    
    private func updateAmplitude() {
        oscillator.amplitude = amplitude
    }
    
    private func updateDetune() {
        if let osc = oscillator as? Oscillator {
            osc.detuningOffset = detune
        }
    }
    
    private func updatePulseWidth() {
        if waveform == .pulse, let osc = oscillator as? Oscillator {
            let table = Table(.square)
            table.pulseWidth = pulseWidth
            osc.waveform = table
        }
    }
    
    private func updatePhase() {
        if let osc = oscillator as? Oscillator {
            osc.phase = phase
        }
    }
    
    private func updateSync() {
        if syncAmount > 0, let syncOsc = syncOscillator {
            if let osc = oscillator as? Oscillator {
                osc.syncAmount = syncAmount
                osc.syncOscillator = syncOsc.getOutputNode()
            }
        }
    }
    
    private func updatePhaseMod() {
        if phaseModAmount > 0, let modOsc = phaseModulator {
            if let osc = oscillator as? Oscillator {
                osc.phaseModulationAmount = phaseModAmount
                osc.phaseModulator = modOsc.getOutputNode()
            }
        }
    }
    
    private func updateWavetablePosition() {
        if waveform == .wavetable, let table = wavetable {
            table.position = wavetablePosition
        }
    }
    
    private func updateSuperSaw() {
        if waveform == .superSaw {
            // Create multiple detuned sawtooth oscillators
            var oscillators: [Node] = []
            for i in 0..<superSawVoices {
                let detune = Float(i) * superSawDetune
                let osc = Oscillator(waveform: Table(.sawtooth))
                osc.frequency = frequency + detune
                osc.amplitude = amplitude / Float(superSawVoices)
                oscillators.append(osc)
            }
            oscillator = Mixer(oscillators)
        }
    }
    
    // MARK: - Public Methods
    
    func setSyncOscillator(_ syncOsc: Oscillator) {
        syncOscillator = syncOsc
        updateSync()
    }
    
    func setPhaseModulator(_ modOsc: Oscillator) {
        phaseModulator = modOsc
        updatePhaseMod()
    }
    
    func setWavetable(_ table: Table) {
        wavetable = table
        if waveform == .wavetable, let osc = oscillator as? Oscillator {
            osc.waveform = table
        }
    }
    
    func getOutputNode() -> Node {
        return oscillator
    }
    
    func start() {
        oscillator.start()
        syncOscillator?.start()
        phaseModulator?.start()
    }
    
    func stop() {
        oscillator.stop()
        syncOscillator?.stop()
        phaseModulator?.stop()
    }
    
    // MARK: - Modulation
    
    func modulateFrequency(amount: Float, rate: Float) {
        let lfo = Oscillator(waveform: Table(.sine))
        lfo.frequency = rate
        lfo.amplitude = amount
        
        if let osc = oscillator as? Oscillator {
            osc.frequencyModulationAmount = amount
            osc.frequencyModulator = lfo
        }
    }
    
    func modulatePulseWidth(amount: Float, rate: Float) {
        let lfo = Oscillator(waveform: Table(.sine))
        lfo.frequency = rate
        lfo.amplitude = amount
        
        if waveform == .pulse, let osc = oscillator as? Oscillator {
            osc.pulseWidthModulationAmount = amount
            osc.pulseWidthModulator = lfo
        }
    }
    
    func modulatePhase(amount: Float, rate: Float) {
        let lfo = Oscillator(waveform: Table(.sine))
        lfo.frequency = rate
        lfo.amplitude = amount
        
        if let osc = oscillator as? Oscillator {
            osc.phaseModulationAmount = amount
            osc.phaseModulator = lfo
        }
    }
}