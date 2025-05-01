import Foundation
import AudioKit

class AdvancedMIDIEditor: ObservableObject {
    @Published var notes: [MIDINote] = []
    @Published var selectedNotes: Set<MIDINote> = []
    @Published var currentQuantization: Quantization = .sixteenth
    @Published var currentScale: Scale = .chromatic
    @Published var currentKey: Key = .c
    @Published var currentMode: Mode = .major
    @Published var currentVelocity: MIDIByte = 100
    @Published var currentLength: TimeInterval = 0.25
    @Published var currentChannel: MIDIChannel = 0
    @Published var currentOctave: Int = 4
    @Published var currentTool: Tool = .pencil
    @Published var currentView: ViewMode = .pianoRoll
    @Published var currentZoom: Double = 1.0
    @Published var currentSnap: SnapMode = .grid
    @Published var currentGridSize: GridSize = .sixteenth
    @Published var currentTimeSignature: TimeSignature = .fourFour
    @Published var currentTempo: Double = 120.0
    @Published var currentLoopStart: TimeInterval = 0.0
    @Published var currentLoopEnd: TimeInterval = 4.0
    @Published var currentLoopEnabled: Bool = false
    @Published var currentRecordEnabled: Bool = false
    @Published var currentOverdubEnabled: Bool = false
    @Published var currentMetronomeEnabled: Bool = false
    @Published var currentCountInEnabled: Bool = false
    @Published var currentCountInBars: Int = 1
    @Published var currentCountInBeats: Int = 4
    
    enum Quantization: Double, CaseIterable {
        case whole = 4.0
        case half = 2.0
        case quarter = 1.0
        case eighth = 0.5
        case sixteenth = 0.25
        case thirtySecond = 0.125
        case sixtyFourth = 0.0625
    }
    
    enum Scale: String, CaseIterable {
        case chromatic
        case major
        case minor
        case harmonicMinor
        case melodicMinor
        case pentatonic
        case blues
        case diminished
        case wholeTone
    }
    
    enum Key: String, CaseIterable {
        case c = "C"
        case cSharp = "C#"
        case d = "D"
        case dSharp = "D#"
        case e = "E"
        case f = "F"
        case fSharp = "F#"
        case g = "G"
        case gSharp = "G#"
        case a = "A"
        case aSharp = "A#"
        case b = "B"
    }
    
    enum Mode: String, CaseIterable {
        case major
        case minor
        case dorian
        case phrygian
        case lydian
        case mixolydian
        case aeolian
        case locrian
    }
    
    enum Tool: String, CaseIterable {
        case pencil
        case brush
        case eraser
        case select
        case move
        case resize
        case slice
        case glue
        case mute
        case solo
    }
    
    enum ViewMode: String, CaseIterable {
        case pianoRoll
        case score
        case drum
        case automation
        case event
    }
    
    enum SnapMode: String, CaseIterable {
        case grid
        case line
        case none
    }
    
    enum GridSize: Double, CaseIterable {
        case whole = 4.0
        case half = 2.0
        case quarter = 1.0
        case eighth = 0.5
        case sixteenth = 0.25
        case thirtySecond = 0.125
        case sixtyFourth = 0.0625
    }
    
    enum TimeSignature: String, CaseIterable {
        case twoTwo = "2/2"
        case twoFour = "2/4"
        case threeFour = "3/4"
        case fourFour = "4/4"
        case fiveFour = "5/4"
        case sixFour = "6/4"
        case sevenFour = "7/4"
        case threeEight = "3/8"
        case sixEight = "6/8"
        case nineEight = "9/8"
        case twelveEight = "12/8"
    }
    
    func addNote(noteNumber: MIDIByte, velocity: MIDIByte, startTime: TimeInterval, duration: TimeInterval) {
        let note = MIDINote(noteNumber: noteNumber, velocity: velocity, startTime: startTime, duration: duration)
        notes.append(note)
    }
    
    func removeNote(_ note: MIDINote) {
        notes.removeAll { $0.id == note.id }
    }
    
    func selectNote(_ note: MIDINote) {
        selectedNotes.insert(note)
    }
    
    func deselectNote(_ note: MIDINote) {
        selectedNotes.remove(note)
    }
    
    func clearSelection() {
        selectedNotes.removeAll()
    }
    
    func quantizeNotes() {
        for note in notes {
            let quantizedStart = quantizeTime(note.startTime)
            let quantizedDuration = quantizeTime(note.duration)
            note.startTime = quantizedStart
            note.duration = quantizedDuration
        }
    }
    
    func quantizeTime(_ time: TimeInterval) -> TimeInterval {
        let beat = time * currentTempo / 60.0
        let quantizedBeat = round(beat / currentQuantization.rawValue) * currentQuantization.rawValue
        return quantizedBeat * 60.0 / currentTempo
    }
    
    func scaleNote(_ note: MIDINote) -> MIDINote {
        let scaleNotes = getScaleNotes()
        let noteNumber = note.noteNumber
        let octave = noteNumber / 12
        let noteInOctave = noteNumber % 12
        
        if scaleNotes.contains(noteInOctave) {
            return note
        }
        
        var closestNote = noteInOctave
        var minDistance = 12
        
        for scaleNote in scaleNotes {
            let distance = abs(scaleNote - noteInOctave)
            if distance < minDistance {
                minDistance = distance
                closestNote = scaleNote
            }
        }
        
        let newNoteNumber = octave * 12 + closestNote
        return MIDINote(noteNumber: MIDIByte(newNoteNumber), velocity: note.velocity, startTime: note.startTime, duration: note.duration)
    }
    
    func getScaleNotes() -> [Int] {
        switch currentScale {
        case .chromatic:
            return Array(0...11)
        case .major:
            return [0, 2, 4, 5, 7, 9, 11]
        case .minor:
            return [0, 2, 3, 5, 7, 8, 10]
        case .harmonicMinor:
            return [0, 2, 3, 5, 7, 8, 11]
        case .melodicMinor:
            return [0, 2, 3, 5, 7, 9, 11]
        case .pentatonic:
            return [0, 2, 4, 7, 9]
        case .blues:
            return [0, 3, 5, 6, 7, 10]
        case .diminished:
            return [0, 2, 3, 5, 6, 8, 9, 11]
        case .wholeTone:
            return [0, 2, 4, 6, 8, 10]
        }
    }
    
    func transposeNotes(_ notes: [MIDINote], by semitones: Int) {
        for note in notes {
            note.noteNumber = MIDIByte(Int(note.noteNumber) + semitones)
        }
    }
    
    func duplicateNotes(_ notes: [MIDINote], at time: TimeInterval) {
        for note in notes {
            let newNote = MIDINote(noteNumber: note.noteNumber, velocity: note.velocity, startTime: note.startTime + time, duration: note.duration)
            self.notes.append(newNote)
        }
    }
    
    func splitNote(_ note: MIDINote, at time: TimeInterval) -> (MIDINote, MIDINote) {
        let firstDuration = time - note.startTime
        let secondDuration = note.duration - firstDuration
        
        let firstNote = MIDINote(noteNumber: note.noteNumber, velocity: note.velocity, startTime: note.startTime, duration: firstDuration)
        let secondNote = MIDINote(noteNumber: note.noteNumber, velocity: note.velocity, startTime: time, duration: secondDuration)
        
        return (firstNote, secondNote)
    }
    
    func glueNotes(_ notes: [MIDINote]) -> MIDINote? {
        guard let firstNote = notes.first else { return nil }
        
        let startTime = notes.map { $0.startTime }.min() ?? firstNote.startTime
        let endTime = notes.map { $0.startTime + $0.duration }.max() ?? firstNote.startTime + firstNote.duration
        let duration = endTime - startTime
        
        return MIDINote(noteNumber: firstNote.noteNumber, velocity: firstNote.velocity, startTime: startTime, duration: duration)
    }
    
    func muteNotes(_ notes: [MIDINote]) {
        for note in notes {
            note.velocity = 0
        }
    }
    
    func soloNotes(_ notes: [MIDINote]) {
        for note in self.notes {
            note.velocity = notes.contains(note) ? note.velocity : 0
        }
    }
    
    func recordMIDI() {
        currentRecordEnabled = true
        if currentCountInEnabled {
            startCountIn()
        } else {
            startRecording()
        }
    }
    
    func stopRecording() {
        currentRecordEnabled = false
        currentOverdubEnabled = false
    }
    
    private func startCountIn() {
        // Implement count-in logic
    }
    
    private func startRecording() {
        // Implement recording logic
    }
    
    func setLoopPoints(start: TimeInterval, end: TimeInterval) {
        currentLoopStart = start
        currentLoopEnd = end
        currentLoopEnabled = true
    }
    
    func disableLoop() {
        currentLoopEnabled = false
    }
    
    func enableMetronome() {
        currentMetronomeEnabled = true
    }
    
    func disableMetronome() {
        currentMetronomeEnabled = false
    }
    
    func setCountIn(bars: Int, beats: Int) {
        currentCountInBars = bars
        currentCountInBeats = beats
        currentCountInEnabled = true
    }
    
    func disableCountIn() {
        currentCountInEnabled = false
    }
} 