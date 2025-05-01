import Foundation
import AudioKit

class StepSequencer: ObservableObject {
    @Published var patterns: [Pattern] = []
    @Published var currentPattern: Pattern?
    @Published var currentStep: Int = 0
    @Published var isPlaying: Bool = false
    @Published var currentTempo: Double = 120.0
    @Published var currentTimeSignature: TimeSignature = .fourFour
    @Published var currentQuantization: Quantization = .sixteenth
    @Published var currentSwing: Double = 0.0
    @Published var currentScale: Scale = .chromatic
    @Published var currentKey: Key = .c
    @Published var currentMode: Mode = .ionian
    
    struct Pattern: Identifiable {
        let id = UUID()
        var name: String
        var steps: [Step]
        var length: Int
        var resolution: Resolution
        var swing: Double
        var scale: Scale
        var key: Key
        var mode: Mode
        var color: Color
        var muted: Bool
        var soloed: Bool
    }
    
    struct Step: Identifiable {
        let id = UUID()
        var noteNumber: Int
        var velocity: Double
        var duration: Double
        var probability: Double
        var accent: Bool
        var slide: Bool
        var muted: Bool
        var selected: Bool
    }
    
    enum Resolution: Double, CaseIterable {
        case whole = 4.0
        case half = 2.0
        case quarter = 1.0
        case eighth = 0.5
        case sixteenth = 0.25
        case thirtySecond = 0.125
        case sixtyFourth = 0.0625
    }
    
    enum Quantization: Double, CaseIterable {
        case none = 0.0
        case eighth = 0.5
        case quarter = 1.0
        case half = 2.0
        case oneBar = 4.0
        case twoBars = 8.0
        case fourBars = 16.0
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
        case dorian
        case phrygian
        case lydian
        case mixolydian
        case locrian
    }
    
    enum Key: String, CaseIterable {
        case c
        case cSharp
        case d
        case dSharp
        case e
        case f
        case fSharp
        case g
        case gSharp
        case a
        case aSharp
        case b
    }
    
    enum Mode: String, CaseIterable {
        case ionian
        case dorian
        case phrygian
        case lydian
        case mixolydian
        case aeolian
        case locrian
    }
    
    enum Color: String, CaseIterable {
        case red
        case orange
        case yellow
        case green
        case blue
        case purple
        case pink
        case gray
    }
    
    func createPattern(name: String, length: Int = 16, resolution: Resolution = .sixteenth) -> Pattern {
        let pattern = Pattern(
            name: name,
            steps: Array(repeating: Step(
                noteNumber: 60,
                velocity: 1.0,
                duration: resolution.rawValue,
                probability: 1.0,
                accent: false,
                slide: false,
                muted: false,
                selected: false
            ), count: length),
            length: length,
            resolution: resolution,
            swing: currentSwing,
            scale: currentScale,
            key: currentKey,
            mode: currentMode,
            color: .blue,
            muted: false,
            soloed: false
        )
        patterns.append(pattern)
        return pattern
    }
    
    func addStep(to pattern: Pattern, at index: Int, noteNumber: Int, velocity: Double = 1.0) {
        guard var pattern = patterns.first(where: { $0.id == pattern.id }) else { return }
        guard index < pattern.steps.count else { return }
        
        pattern.steps[index] = Step(
            noteNumber: noteNumber,
            velocity: velocity,
            duration: pattern.resolution.rawValue,
            probability: 1.0,
            accent: false,
            slide: false,
            muted: false,
            selected: false
        )
        
        updatePattern(pattern)
    }
    
    func removeStep(from pattern: Pattern, at index: Int) {
        guard var pattern = patterns.first(where: { $0.id == pattern.id }) else { return }
        guard index < pattern.steps.count else { return }
        
        pattern.steps[index] = Step(
            noteNumber: 60,
            velocity: 0.0,
            duration: pattern.resolution.rawValue,
            probability: 1.0,
            accent: false,
            slide: false,
            muted: true,
            selected: false
        )
        
        updatePattern(pattern)
    }
    
    func quantizeSteps(in pattern: Pattern) {
        guard var pattern = patterns.first(where: { $0.id == pattern.id }) else { return }
        
        for index in pattern.steps.indices {
            let step = pattern.steps[index]
            if step.velocity > 0 {
                let quantizedNote = quantizeNote(step.noteNumber)
                pattern.steps[index].noteNumber = quantizedNote
            }
        }
        
        updatePattern(pattern)
    }
    
    func quantizeNote(_ noteNumber: Int) -> Int {
        let scaleNotes = getScaleNotes()
        let octave = noteNumber / 12
        let noteInOctave = noteNumber % 12
        
        var closestNote = scaleNotes[0]
        var minDistance = abs(noteInOctave - scaleNotes[0])
        
        for note in scaleNotes {
            let distance = abs(noteInOctave - note)
            if distance < minDistance {
                minDistance = distance
                closestNote = note
            }
        }
        
        return (octave * 12) + closestNote
    }
    
    func getScaleNotes() -> [Int] {
        let baseNote = getKeyBaseNote()
        var scaleNotes: [Int] = []
        
        switch currentScale {
        case .chromatic:
            scaleNotes = Array(0...11)
        case .major:
            scaleNotes = [0, 2, 4, 5, 7, 9, 11]
        case .minor:
            scaleNotes = [0, 2, 3, 5, 7, 8, 10]
        case .harmonicMinor:
            scaleNotes = [0, 2, 3, 5, 7, 8, 11]
        case .melodicMinor:
            scaleNotes = [0, 2, 3, 5, 7, 9, 11]
        case .pentatonic:
            scaleNotes = [0, 2, 4, 7, 9]
        case .blues:
            scaleNotes = [0, 3, 5, 6, 7, 10]
        case .diminished:
            scaleNotes = [0, 2, 3, 5, 6, 8, 9, 11]
        case .wholeTone:
            scaleNotes = [0, 2, 4, 6, 8, 10]
        case .dorian:
            scaleNotes = [0, 2, 3, 5, 7, 9, 10]
        case .phrygian:
            scaleNotes = [0, 1, 3, 5, 7, 8, 10]
        case .lydian:
            scaleNotes = [0, 2, 4, 6, 7, 9, 11]
        case .mixolydian:
            scaleNotes = [0, 2, 4, 5, 7, 9, 10]
        case .locrian:
            scaleNotes = [0, 1, 3, 5, 6, 8, 10]
        }
        
        return scaleNotes.map { ($0 + baseNote) % 12 }
    }
    
    func getKeyBaseNote() -> Int {
        switch currentKey {
        case .c: return 0
        case .cSharp: return 1
        case .d: return 2
        case .dSharp: return 3
        case .e: return 4
        case .f: return 5
        case .fSharp: return 6
        case .g: return 7
        case .gSharp: return 8
        case .a: return 9
        case .aSharp: return 10
        case .b: return 11
        }
    }
    
    func play() {
        isPlaying = true
        startSequencer()
    }
    
    func stop() {
        isPlaying = false
        stopSequencer()
    }
    
    func setTempo(_ tempo: Double) {
        currentTempo = tempo
        updateSequencerTiming()
    }
    
    func setTimeSignature(_ timeSignature: TimeSignature) {
        currentTimeSignature = timeSignature
        updateSequencerTiming()
    }
    
    func setSwing(_ swing: Double) {
        currentSwing = swing
        updateSequencerTiming()
    }
    
    private func updatePattern(_ pattern: Pattern) {
        if let index = patterns.firstIndex(where: { $0.id == pattern.id }) {
            patterns[index] = pattern
        }
    }
    
    private func startSequencer() {
        // Implement sequencer playback
    }
    
    private func stopSequencer() {
        // Implement sequencer stop
    }
    
    private func updateSequencerTiming() {
        // Implement timing updates
    }
} 