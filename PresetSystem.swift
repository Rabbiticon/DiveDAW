import Foundation
import AudioKit

class PresetSystem: ObservableObject {
    @Published var instrumentPresets: [InstrumentPreset] = []
    @Published var effectPresets: [EffectPreset] = []
    @Published var projectPresets: [ProjectPreset] = []
    @Published var currentCategory: PresetCategory = .all
    
    struct InstrumentPreset: Identifiable {
        let id = UUID()
        var name: String
        var category: PresetCategory
        var instrumentType: InstrumentType
        var parameters: [String: Double]
        var description: String
        var tags: [String]
        var author: String
        var rating: Double
        var isFavorite: Bool
    }
    
    struct EffectPreset: Identifiable {
        let id = UUID()
        var name: String
        var category: PresetCategory
        var effectType: EffectType
        var parameters: [String: Double]
        var description: String
        var tags: [String]
        var author: String
        var rating: Double
        var isFavorite: Bool
    }
    
    struct ProjectPreset: Identifiable {
        let id = UUID()
        var name: String
        var category: PresetCategory
        var tempo: Double
        var timeSignature: TimeSignature
        var tracks: [TrackPreset]
        var description: String
        var tags: [String]
        var author: String
        var rating: Double
        var isFavorite: Bool
    }
    
    struct TrackPreset {
        var name: String
        var instrument: InstrumentPreset?
        var effects: [EffectPreset]
        var automation: [AutomationPreset]
        var clips: [ClipPreset]
    }
    
    struct AutomationPreset {
        var parameter: String
        var points: [AutomationPoint]
    }
    
    struct ClipPreset {
        var name: String
        var type: ClipType
        var content: ClipContent
        var loop: Bool
        var loopPoints: (start: TimeInterval, end: TimeInterval)
    }
    
    enum PresetCategory: String, CaseIterable {
        case all
        case bass
        case lead
        case pad
        case drum
        case fx
        case ambient
        case cinematic
        case electronic
        case acoustic
        case vocal
        case mastering
        case mixing
    }
    
    enum InstrumentType: String, CaseIterable {
        case synth
        case sampler
        case drumMachine
        case piano
        case strings
        case brass
        case woodwind
        case guitar
        case bass
        case vocal
    }
    
    enum EffectType: String, CaseIterable {
        case reverb
        case delay
        case distortion
        case filter
        case compressor
        case limiter
        case eq
        case chorus
        case flanger
        case phaser
        case vocoder
        case pitchShift
        case timeStretch
    }
    
    func loadDefaultPresets() {
        // Load instrument presets
        instrumentPresets = [
            InstrumentPreset(
                name: "Deep Bass",
                category: .bass,
                instrumentType: .synth,
                parameters: [
                    "osc1Wave": 0.0,
                    "osc1Octave": -1.0,
                    "filterCutoff": 0.3,
                    "filterResonance": 0.5,
                    "attack": 0.1,
                    "decay": 0.3,
                    "sustain": 0.7,
                    "release": 0.2
                ],
                description: "A deep, powerful bass sound perfect for electronic music",
                tags: ["bass", "electronic", "synth"],
                author: "System",
                rating: 4.5,
                isFavorite: true
            ),
            // Add more instrument presets...
        ]
        
        // Load effect presets
        effectPresets = [
            EffectPreset(
                name: "Warm Reverb",
                category: .fx,
                effectType: .reverb,
                parameters: [
                    "mix": 0.3,
                    "decay": 0.7,
                    "predelay": 0.1,
                    "damping": 0.5
                ],
                description: "A warm, natural reverb perfect for vocals and instruments",
                tags: ["reverb", "warm", "natural"],
                author: "System",
                rating: 4.8,
                isFavorite: true
            ),
            // Add more effect presets...
        ]
        
        // Load project presets
        projectPresets = [
            ProjectPreset(
                name: "Electronic Starter",
                category: .electronic,
                tempo: 128.0,
                timeSignature: .fourFour,
                tracks: [
                    TrackPreset(
                        name: "Drums",
                        instrument: instrumentPresets[0],
                        effects: [effectPresets[0]],
                        automation: [],
                        clips: []
                    )
                ],
                description: "A basic electronic music template",
                tags: ["electronic", "template", "starter"],
                author: "System",
                rating: 4.0,
                isFavorite: true
            ),
            // Add more project presets...
        ]
    }
    
    func savePreset(_ preset: InstrumentPreset) {
        instrumentPresets.append(preset)
        savePresetsToDisk()
    }
    
    func savePreset(_ preset: EffectPreset) {
        effectPresets.append(preset)
        savePresetsToDisk()
    }
    
    func savePreset(_ preset: ProjectPreset) {
        projectPresets.append(preset)
        savePresetsToDisk()
    }
    
    func deletePreset(_ preset: InstrumentPreset) {
        instrumentPresets.removeAll { $0.id == preset.id }
        savePresetsToDisk()
    }
    
    func deletePreset(_ preset: EffectPreset) {
        effectPresets.removeAll { $0.id == preset.id }
        savePresetsToDisk()
    }
    
    func deletePreset(_ preset: ProjectPreset) {
        projectPresets.removeAll { $0.id == preset.id }
        savePresetsToDisk()
    }
    
    func filterPresets(by category: PresetCategory, searchText: String = "") -> [InstrumentPreset] {
        var filtered = instrumentPresets
        
        if category != .all {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    func filterEffectPresets(by category: PresetCategory, searchText: String = "") -> [EffectPreset] {
        var filtered = effectPresets
        
        if category != .all {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    func filterProjectPresets(by category: PresetCategory, searchText: String = "") -> [ProjectPreset] {
        var filtered = projectPresets
        
        if category != .all {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    private func savePresetsToDisk() {
        // Implement saving presets to disk
    }
    
    private func loadPresetsFromDisk() {
        // Implement loading presets from disk
    }
} 