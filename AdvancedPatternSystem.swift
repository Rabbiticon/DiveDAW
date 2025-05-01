import Foundation
import AudioKit

class AdvancedPatternSystem {
    // MARK: - Pattern Types
    
    class Pattern {
        let id: UUID
        var name: String
        var length: TimeInterval
        var steps: [Step]
        var automation: [Automation]
        var variations: [PatternVariation]
        var probability: Double
        var swing: Double
        
        init(id: UUID = UUID(), name: String, length: TimeInterval) {
            self.id = id
            self.name = name
            self.length = length
            self.steps = []
            self.automation = []
            self.variations = []
            self.probability = 1.0
            self.swing = 0.0
        }
        
        func addStep(_ step: Step) {
            steps.append(step)
        }
        
        func addAutomation(_ automation: Automation) {
            self.automation.append(automation)
        }
        
        func addVariation(_ variation: PatternVariation) {
            variations.append(variation)
        }
    }
    
    // MARK: - Step Types
    
    struct Step {
        let time: TimeInterval
        let note: MIDINote
        let velocity: Float
        let duration: TimeInterval
        let probability: Double
        let microTiming: Double
        let accent: Bool
        let slide: Bool
        let retrigger: Int
        
        init(time: TimeInterval, note: MIDINote, velocity: Float, duration: TimeInterval) {
            self.time = time
            self.note = note
            self.velocity = velocity
            self.duration = duration
            self.probability = 1.0
            self.microTiming = 0.0
            self.accent = false
            self.slide = false
            self.retrigger = 1
        }
    }
    
    // MARK: - Automation
    
    struct Automation {
        let parameter: String
        let points: [AutomationPoint]
        let curve: AutomationCurve
        let loop: Bool
        
        struct AutomationPoint {
            let time: TimeInterval
            let value: Float
            let curve: AutomationCurve
        }
        
        enum AutomationCurve {
            case linear
            case exponential
            case logarithmic
            case bezier
            case step
        }
    }
    
    // MARK: - Pattern Variations
    
    struct PatternVariation {
        let id: UUID
        let name: String
        let steps: [Step]
        let probability: Double
        let conditions: [VariationCondition]
        
        struct VariationCondition {
            let type: ConditionType
            let value: Double
            let comparison: Comparison
            
            enum ConditionType {
                case velocity
                case time
                case random
                case pattern
            }
            
            enum Comparison {
                case greaterThan
                case lessThan
                case equals
                case notEquals
            }
        }
    }
    
    // MARK: - Pattern Generator
    
    class PatternGenerator {
        private var patterns: [Pattern] = []
        private var currentPattern: Pattern?
        private var currentVariation: PatternVariation?
        
        func createPattern(name: String, length: TimeInterval) -> Pattern {
            let pattern = Pattern(name: name, length: length)
            patterns.append(pattern)
            return pattern
        }
        
        func generateStepSequence(pattern: Pattern, steps: Int) {
            let stepDuration = pattern.length / Double(steps)
            
            for i in 0..<steps {
                let time = Double(i) * stepDuration
                let step = Step(
                    time: time,
                    note: MIDINote(noteNumber: 60, velocity: 100, startTime: time, duration: stepDuration),
                    velocity: 100,
                    duration: stepDuration
                )
                pattern.addStep(step)
            }
        }
        
        func addSwing(pattern: Pattern, amount: Double) {
            pattern.swing = amount
            // Apply swing to steps
            for i in 0..<pattern.steps.count {
                if i % 2 == 1 { // Off-beat steps
                    pattern.steps[i].microTiming = amount
                }
            }
        }
        
        func addProbability(pattern: Pattern, amount: Double) {
            pattern.probability = amount
            // Apply probability to steps
            for i in 0..<pattern.steps.count {
                pattern.steps[i].probability = amount
            }
        }
        
        func createVariation(pattern: Pattern, name: String) -> PatternVariation {
            let variation = PatternVariation(
                id: UUID(),
                name: name,
                steps: pattern.steps,
                probability: 1.0,
                conditions: []
            )
            pattern.addVariation(variation)
            return variation
        }
        
        func addCondition(to variation: PatternVariation, type: PatternVariation.VariationCondition.ConditionType, value: Double, comparison: PatternVariation.VariationCondition.Comparison) {
            let condition = PatternVariation.VariationCondition(
                type: type,
                value: value,
                comparison: comparison
            )
            // Add condition to variation
        }
    }
    
    // MARK: - Pattern Player
    
    class PatternPlayer {
        private var engine: AudioEngine
        private var currentTime: TimeInterval = 0
        private var isPlaying: Bool = false
        private var tempo: Double = 120
        
        init(engine: AudioEngine) {
            self.engine = engine
        }
        
        func playPattern(_ pattern: Pattern) {
            isPlaying = true
            currentTime = 0
            
            // Schedule pattern playback
            Timer.scheduledTimer(withTimeInterval: 60.0 / tempo, repeats: true) { [weak self] timer in
                guard let self = self, self.isPlaying else {
                    timer.invalidate()
                    return
                }
                
                self.playCurrentStep(pattern)
                self.currentTime += 60.0 / self.tempo
                
                if self.currentTime >= pattern.length {
                    self.currentTime = 0
                }
            }
        }
        
        private func playCurrentStep(_ pattern: Pattern) {
            // Find steps that should play at current time
            let currentSteps = pattern.steps.filter { step in
                // Check probability
                guard Double.random(in: 0...1) < step.probability else { return false }
                
                // Check variation conditions
                if let variation = pattern.variations.randomElement() {
                    for condition in variation.conditions {
                        if !checkCondition(condition) {
                            return false
                        }
                    }
                }
                
                return abs(step.time - currentTime) < 0.001
            }
            
            // Play the steps
            for step in currentSteps {
                // Apply swing and micro-timing
                let actualTime = step.time + step.microTiming
                
                // Send MIDI note
                engine.sendMIDIEvent(
                    status: .noteOn,
                    data1: step.note.noteNumber,
                    data2: UInt8(step.velocity)
                )
                
                // Schedule note off
                DispatchQueue.main.asyncAfter(deadline: .now() + step.duration) {
                    self.engine.sendMIDIEvent(
                        status: .noteOff,
                        data1: step.note.noteNumber,
                        data2: 0
                    )
                }
            }
        }
        
        private func checkCondition(_ condition: PatternVariation.VariationCondition) -> Bool {
            let value: Double
            
            switch condition.type {
            case .velocity:
                value = Double.random(in: 0...127)
            case .time:
                value = currentTime
            case .random:
                value = Double.random(in: 0...1)
            case .pattern:
                value = Double.random(in: 0...1) // Placeholder
            }
            
            switch condition.comparison {
            case .greaterThan:
                return value > condition.value
            case .lessThan:
                return value < condition.value
            case .equals:
                return abs(value - condition.value) < 0.001
            case .notEquals:
                return abs(value - condition.value) >= 0.001
            }
        }
    }
} 