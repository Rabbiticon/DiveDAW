import Foundation
import AudioKit

class VirtualInstrumentManager: ObservableObject {
    static let shared = VirtualInstrumentManager()
    
    @Published private(set) var instruments: [VirtualInstrument] = []
    private var mixer = Mixer()
    
    private init() {
        setupDefaultInstruments()
    }
    
    private func setupDefaultInstruments() {
        // Initialize default instruments
        let defaultInstruments: [InstrumentType] = [
            .piano,
            .electricPiano,
            .bass,
            .electricBass,
            .guitar,
            .electricGuitar
        ]
        
        for type in defaultInstruments {
            let instrument = VirtualInstrument(type: type)
            instruments.append(instrument)
            mixer.addInput(instrument.getOutputNode())
        }
    }
    
    func getInstrument(ofType type: InstrumentType) -> VirtualInstrument? {
        return instruments.first { $0.type == type }
    }
    
    func handleMIDIEvent(status: MIDIStatus, data1: MIDIByte, data2: MIDIByte, channel: MIDIChannel) {
        // Route MIDI events to appropriate instrument based on channel
        if channel < instruments.count {
            let instrument = instruments[Int(channel)]
            if instrument.isEnabled {
                instrument.handleMIDIMessage(status, data1, data2)
            }
        }
    }
    
    func getOutputNode() -> Node {
        return mixer
    }
    
    func setInstrumentVolume(_ volume: Float, forType type: InstrumentType) {
        if let instrument = getInstrument(ofType: type) {
            instrument.volume = volume
        }
    }
    
    func setInstrumentPan(_ pan: Float, forType type: InstrumentType) {
        if let instrument = getInstrument(ofType: type) {
            instrument.pan = pan
        }
    }
    
    func enableInstrument(_ enabled: Bool, forType type: InstrumentType) {
        if let instrument = getInstrument(ofType: type) {
            instrument.isEnabled = enabled
        }
    }
}