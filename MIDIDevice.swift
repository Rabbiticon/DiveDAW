import Foundation
import AudioKit

struct MIDIDevice: Identifiable, Equatable {
    let id: Int
    let name: String
    
    var isConnected: Bool = false
    var lastMessageTimestamp: TimeInterval = 0
    
    static func == (lhs: MIDIDevice, rhs: MIDIDevice) -> Bool {
        return lhs.id == rhs.id
    }
    
    func connect() {
        // Implement MIDI device connection
        MIDI.sharedInstance.openInput(name)
    }
    
    func disconnect() {
        // Implement MIDI device disconnection
        MIDI.sharedInstance.closeInput(name)
    }
}

// MIDI Event Handler Protocol
protocol MIDIEventHandler: AnyObject {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, channel: MIDIChannel)
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel)
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel)
}

// Default implementation
extension MIDIEventHandler {
    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {}
    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, channel: MIDIChannel) {}
    func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel) {}
    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel) {}
}