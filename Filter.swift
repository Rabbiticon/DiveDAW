import Foundation
import AudioKit

class Filter {
    enum FilterType {
        case lowpass
        case highpass
        case bandpass
        case notch
    }
    
    private var filter: Node
    private var type: FilterType
    
    var cutoffFrequency: Float = 1000.0 {
        didSet {
            updateCutoff()
        }
    }
    
    var resonance: Float = 0.5 {
        didSet {
            updateResonance()
        }
    }
    
    var mix: Float = 1.0 {
        didSet {
            updateMix()
        }
    }
    
    init(type: FilterType = .lowpass) {
        self.type = type
        
        switch type {
        case .lowpass:
            filter = LowPassFilter()
        case .highpass:
            filter = HighPassFilter()
        case .bandpass:
            filter = BandPassFilter()
        case .notch:
            filter = BandRejectFilter()
        }
        
        updateCutoff()
        updateResonance()
        updateMix()
    }
    
    private func updateCutoff() {
        if let lpf = filter as? LowPassFilter {
            lpf.cutoffFrequency = cutoffFrequency
        } else if let hpf = filter as? HighPassFilter {
            hpf.cutoffFrequency = cutoffFrequency
        } else if let bpf = filter as? BandPassFilter {
            bpf.centerFrequency = cutoffFrequency
        } else if let brf = filter as? BandRejectFilter {
            brf.centerFrequency = cutoffFrequency
        }
    }
    
    private func updateResonance() {
        if let lpf = filter as? LowPassFilter {
            lpf.resonance = resonance
        } else if let hpf = filter as? HighPassFilter {
            hpf.resonance = resonance
        } else if let bpf = filter as? BandPassFilter {
            bpf.bandwidth = resonance
        } else if let brf = filter as? BandRejectFilter {
            brf.bandwidth = resonance
        }
    }
    
    private func updateMix() {
        filter.mix = mix
    }
    
    func process(input: Node) -> Node {
        filter.input = input
        return filter
    }
    
    func bypass() {
        mix = 0.0
    }
    
    func enable() {
        mix = 1.0
    }
}