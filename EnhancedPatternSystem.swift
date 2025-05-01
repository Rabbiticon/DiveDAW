import Foundation
import AudioKit

class EnhancedPatternSystem: ObservableObject {
    @Published var patterns: [Pattern] = []
    @Published var currentPattern: Pattern?
    @Published var currentStep: Int = 0
    @Published var currentLength: Int = 16
    @Published var currentResolution: Resolution = .sixteenth
    @Published var currentSwing: Double = 0.0
    @Published var currentQuantization: Quantization = .sixteenth
    @Published var currentScale: Scale = .chromatic
    @Published var currentKey: Key = .c
    @Published var currentMode: Mode = .major
    @Published var currentTempo: Double = 120.0
    @Published var currentTimeSignature: TimeSignature = .fourFour
    @Published var currentLoopEnabled: Bool = false
    @Published var currentLoopStart: Int = 0
    @Published var currentLoopEnd: Int = 16
    @Published var currentRecordEnabled: Bool = false
    @Published var currentOverdubEnabled: Bool = false
    @Published var currentMetronomeEnabled: Bool = false
    @Published var currentCountInEnabled: Bool = false
    @Published var currentCountInBars: Int = 1
    @Published var currentCountInBeats: Int = 4
    
    struct Pattern: Identifiable {
        let id = UUID()
        var name: String
        var steps: [Step]
        var length: Int
        var resolution: Resolution
        var swing: Double
        var quantization: Quantization
        var scale: Scale
        var key: Key
        var mode: Mode
        var tempo: Double
        var timeSignature: TimeSignature
        var loopEnabled: Bool
        var loopStart: Int
        var loopEnd: Int
        var recordEnabled: Bool
        var overdubEnabled: Bool
        var metronomeEnabled: Bool
        var countInEnabled: Bool
        var countInBars: Int
        var countInBeats: Int
    }
    
    struct Step: Identifiable {
        let id = UUID()
        var noteNumber: MIDIByte
        var velocity: MIDIByte
        var startTime: TimeInterval
        var duration: TimeInterval
        var channel: MIDIChannel
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
    
    func createPattern(name: String) -> Pattern {
        let pattern = Pattern(
            name: name,
            steps: [],
            length: currentLength,
            resolution: currentResolution,
            swing: currentSwing,
            quantization: currentQuantization,
            scale: currentScale,
            key: currentKey,
            mode: currentMode,
            tempo: currentTempo,
            timeSignature: currentTimeSignature,
            loopEnabled: currentLoopEnabled,
            loopStart: currentLoopStart,
            loopEnd: currentLoopEnd,
            recordEnabled: currentRecordEnabled,
            overdubEnabled: currentOverdubEnabled,
            metronomeEnabled: currentMetronomeEnabled,
            countInEnabled: currentCountInEnabled,
            countInBars: currentCountInBars,
            countInBeats: currentCountInBeats
        )
        patterns.append(pattern)
        currentPattern = pattern
        return pattern
    }
    
    func deletePattern(_ pattern: Pattern) {
        patterns.removeAll { $0.id == pattern.id }
        if currentPattern?.id == pattern.id {
            currentPattern = patterns.first
        }
    }
    
    func duplicatePattern(_ pattern: Pattern) -> Pattern {
        var newPattern = pattern
        newPattern.name = "\(pattern.name) Copy"
        patterns.append(newPattern)
        return newPattern
    }
    
    func addStep(noteNumber: MIDIByte, velocity: MIDIByte, startTime: TimeInterval, duration: TimeInterval, channel: MIDIChannel) {
        guard var pattern = currentPattern else { return }
        let step = Step(
            noteNumber: noteNumber,
            velocity: velocity,
            startTime: startTime,
            duration: duration,
            channel: channel,
            muted: false,
            selected: false
        )
        pattern.steps.append(step)
        updatePattern(pattern)
    }
    
    func removeStep(_ step: Step) {
        guard var pattern = currentPattern else { return }
        pattern.steps.removeAll { $0.id == step.id }
        updatePattern(pattern)
    }
    
    func updateStep(_ step: Step) {
        guard var pattern = currentPattern else { return }
        if let index = pattern.steps.firstIndex(where: { $0.id == step.id }) {
            pattern.steps[index] = step
            updatePattern(pattern)
        }
    }
    
    func selectStep(_ step: Step) {
        guard var pattern = currentPattern else { return }
        if let index = pattern.steps.firstIndex(where: { $0.id == step.id }) {
            pattern.steps[index].selected = true
            updatePattern(pattern)
        }
    }
    
    func deselectStep(_ step: Step) {
        guard var pattern = currentPattern else { return }
        if let index = pattern.steps.firstIndex(where: { $0.id == step.id }) {
            pattern.steps[index].selected = false
            updatePattern(pattern)
        }
    }
    
    func clearSelection() {
        guard var pattern = currentPattern else { return }
        for index in pattern.steps.indices {
            pattern.steps[index].selected = false
        }
        updatePattern(pattern)
    }
    
    func muteStep(_ step: Step) {
        guard var pattern = currentPattern else { return }
        if let index = pattern.steps.firstIndex(where: { $0.id == step.id }) {
            pattern.steps[index].muted = true
            updatePattern(pattern)
        }
    }
    
    func unmuteStep(_ step: Step) {
        guard var pattern = currentPattern else { return }
        if let index = pattern.steps.firstIndex(where: { $0.id == step.id }) {
            pattern.steps[index].muted = false
            updatePattern(pattern)
        }
    }
    
    func quantizeSteps() {
        guard var pattern = currentPattern else { return }
        for index in pattern.steps.indices {
            let step = pattern.steps[index]
            let quantizedStart = quantizeTime(step.startTime)
            let quantizedDuration = quantizeTime(step.duration)
            pattern.steps[index].startTime = quantizedStart
            pattern.steps[index].duration = quantizedDuration
        }
        updatePattern(pattern)
    }
    
    func quantizeTime(_ time: TimeInterval) -> TimeInterval {
        let beat = time * currentTempo / 60.0
        let quantizedBeat = round(beat / currentQuantization.rawValue) * currentQuantization.rawValue
        return quantizedBeat * 60.0 / currentTempo
    }
    
    func scaleStep(_ step: Step) -> Step {
        let scaleNotes = getScaleNotes()
        let noteNumber = step.noteNumber
        let octave = noteNumber / 12
        let noteInOctave = noteNumber % 12
        
        if scaleNotes.contains(noteInOctave) {
            return step
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
        return Step(
            noteNumber: MIDIByte(newNoteNumber),
            velocity: step.velocity,
            startTime: step.startTime,
            duration: step.duration,
            channel: step.channel,
            muted: step.muted,
            selected: step.selected
        )
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
    
    func transposeSteps(_ steps: [Step], by semitones: Int) {
        guard var pattern = currentPattern else { return }
        for step in steps {
            if let index = pattern.steps.firstIndex(where: { $0.id == step.id }) {
                pattern.steps[index].noteNumber = MIDIByte(Int(step.noteNumber) + semitones)
            }
        }
        updatePattern(pattern)
    }
    
    func duplicateSteps(_ steps: [Step], at time: TimeInterval) {
        guard var pattern = currentPattern else { return }
        for step in steps {
            let newStep = Step(
                noteNumber: step.noteNumber,
                velocity: step.velocity,
                startTime: step.startTime + time,
                duration: step.duration,
                channel: step.channel,
                muted: step.muted,
                selected: step.selected
            )
            pattern.steps.append(newStep)
        }
        updatePattern(pattern)
    }
    
    func splitStep(_ step: Step, at time: TimeInterval) -> (Step, Step) {
        let firstDuration = time - step.startTime
        let secondDuration = step.duration - firstDuration
        
        let firstStep = Step(
            noteNumber: step.noteNumber,
            velocity: step.velocity,
            startTime: step.startTime,
            duration: firstDuration,
            channel: step.channel,
            muted: step.muted,
            selected: step.selected
        )
        
        let secondStep = Step(
            noteNumber: step.noteNumber,
            velocity: step.velocity,
            startTime: time,
            duration: secondDuration,
            channel: step.channel,
            muted: step.muted,
            selected: step.selected
        )
        
        return (firstStep, secondStep)
    }
    
    func glueSteps(_ steps: [Step]) -> Step? {
        guard let firstStep = steps.first else { return nil }
        
        let startTime = steps.map { $0.startTime }.min() ?? firstStep.startTime
        let endTime = steps.map { $0.startTime + $0.duration }.max() ?? firstStep.startTime + firstStep.duration
        let duration = endTime - startTime
        
                return Step(
            noteNumber: firstStep.noteNumber,
            velocity: firstStep.velocity,
            startTime: startTime,
            duration: duration,
            channel: firstStep.channel,
            muted: firstStep.muted,
            selected: firstStep.selected
        )
    }
    
    func recordPattern() {
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
    
    func setLoopPoints(start: Int, end: Int) {
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
    
    private func updatePattern(_ pattern: Pattern) {
        if let index = patterns.firstIndex(where: { $0.id == pattern.id }) {
            patterns[index] = pattern
            currentPattern = pattern
        }
    }
} 