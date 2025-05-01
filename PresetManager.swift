import Foundation
import AudioKit

class PresetManager {
    static let shared = PresetManager()
    
    // MARK: - Preset Types
    
    struct Preset: Codable, Identifiable {
        let id: UUID
        let name: String
        let type: PresetType
        let parameters: [String: Any]
        let tags: [String]
        let author: String?
        let description: String?
        let version: String
        let creationDate: Date
        let lastModified: Date
        
        enum PresetType: String, Codable {
            case instrument
            case effect
            case pattern
            case project
        }
    }
    
    // MARK: - Template Types
    
    struct Template: Codable, Identifiable {
        let id: UUID
        let name: String
        let type: TemplateType
        let tracks: [Track]
        let mixer: Mixer
        let bpm: Double
        let timeSignature: TimeSignature
        let description: String?
        let tags: [String]
        let author: String?
        let version: String
        let creationDate: Date
        let lastModified: Date
        
        struct Track: Codable {
            let name: String
            let instrument: String?
            let effects: [String]
            let automation: [Automation]
            let patterns: [Pattern]
        }
        
        struct TimeSignature: Codable {
            let numerator: Int
            let denominator: Int
        }
        
        enum TemplateType: String, Codable {
            case electronic
            case orchestral
            case hipHop
            case rock
            case ambient
            case custom
        }
    }
    
    // MARK: - Properties
    
    private var presets: [Preset] = []
    private var templates: [Template] = []
    private let presetsDirectory: URL
    private let templatesDirectory: URL
    private let sharedPresetsDirectory: URL
    private let sharedTemplatesDirectory: URL
    
    // MARK: - Initialization
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        presetsDirectory = documentsDirectory.appendingPathComponent("Presets")
        templatesDirectory = documentsDirectory.appendingPathComponent("Templates")
        sharedPresetsDirectory = documentsDirectory.appendingPathComponent("Shared/Presets")
        sharedTemplatesDirectory = documentsDirectory.appendingPathComponent("Shared/Templates")
        
        createDirectoriesIfNeeded()
        loadPresetsAndTemplates()
    }
    
    // MARK: - Directory Management
    
    private func createDirectoriesIfNeeded() {
        let directories = [
            presetsDirectory,
            templatesDirectory,
            sharedPresetsDirectory,
            sharedTemplatesDirectory
        ]
        
        for directory in directories {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Preset Management
    
    func savePreset(_ preset: Preset) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(preset)
        let fileURL = presetsDirectory.appendingPathComponent("\(preset.id).json")
        try data.write(to: fileURL)
        
        presets.append(preset)
    }
    
    func loadPreset(with id: UUID) -> Preset? {
        return presets.first { $0.id == id }
    }
    
    func deletePreset(with id: UUID) throws {
        let fileURL = presetsDirectory.appendingPathComponent("\(id).json")
        try FileManager.default.removeItem(at: fileURL)
        presets.removeAll { $0.id == id }
    }
    
    func searchPresets(query: String, type: Preset.PresetType? = nil) -> [Preset] {
        return presets.filter { preset in
            let matchesQuery = preset.name.localizedCaseInsensitiveContains(query) ||
                             preset.description?.localizedCaseInsensitiveContains(query) == true ||
                             preset.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            
            if let type = type {
                return matchesQuery && preset.type == type
            }
            return matchesQuery
        }
    }
    
    // MARK: - Template Management
    
    func saveTemplate(_ template: Template) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(template)
        let fileURL = templatesDirectory.appendingPathComponent("\(template.id).json")
        try data.write(to: fileURL)
        
        templates.append(template)
    }
    
    func loadTemplate(with id: UUID) -> Template? {
        return templates.first { $0.id == id }
    }
    
    func deleteTemplate(with id: UUID) throws {
        let fileURL = templatesDirectory.appendingPathComponent("\(id).json")
        try FileManager.default.removeItem(at: fileURL)
        templates.removeAll { $0.id == id }
    }
    
    func searchTemplates(query: String, type: Template.TemplateType? = nil) -> [Template] {
        return templates.filter { template in
            let matchesQuery = template.name.localizedCaseInsensitiveContains(query) ||
                             template.description?.localizedCaseInsensitiveContains(query) == true ||
                             template.tags.contains { $0.localizedCaseInsensitiveContains(query) }
            
            if let type = type {
                return matchesQuery && template.type == type
            }
            return matchesQuery
        }
    }
    
    // MARK: - Sharing
    
    func sharePreset(_ preset: Preset) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(preset)
        let fileURL = sharedPresetsDirectory.appendingPathComponent("\(preset.id).json")
        try data.write(to: fileURL)
    }
    
    func shareTemplate(_ template: Template) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let data = try encoder.encode(template)
        let fileURL = sharedTemplatesDirectory.appendingPathComponent("\(template.id).json")
        try data.write(to: fileURL)
    }
    
    func importSharedPreset(from url: URL) throws -> Preset {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let preset = try decoder.decode(Preset.self, from: data)
        try savePreset(preset)
        return preset
    }
    
    func importSharedTemplate(from url: URL) throws -> Template {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let template = try decoder.decode(Template.self, from: data)
        try saveTemplate(template)
        return template
    }
    
    // MARK: - Loading
    
    private func loadPresetsAndTemplates() {
        // Load presets
        let presetFiles = (try? FileManager.default.contentsOfDirectory(at: presetsDirectory, includingPropertiesForKeys: nil)) ?? []
        for file in presetFiles where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let preset = try? JSONDecoder().decode(Preset.self, from: data) {
                presets.append(preset)
            }
        }
        
        // Load templates
        let templateFiles = (try? FileManager.default.contentsOfDirectory(at: templatesDirectory, includingPropertiesForKeys: nil)) ?? []
        for file in templateFiles where file.pathExtension == "json" {
            if let data = try? Data(contentsOf: file),
               let template = try? JSONDecoder().decode(Template.self, from: data) {
                templates.append(template)
            }
        }
    }
    
    // MARK: - Default Content
    
    func createDefaultPresets() throws {
        // Create default instrument presets
        let defaultPresets: [Preset] = [
            Preset(
                id: UUID(),
                name: "Warm Pad",
                type: .instrument,
                parameters: [
                    "waveform": "sine",
                    "attack": 0.5,
                    "decay": 0.3,
                    "sustain": 0.7,
                    "release": 1.0,
                    "filterCutoff": 2000.0,
                    "filterResonance": 0.5
                ],
                tags: ["pad", "ambient", "synth"],
                author: "DiveDaw",
                description: "A warm, evolving pad sound perfect for ambient music",
                version: "1.0",
                creationDate: Date(),
                lastModified: Date()
            ),
            // Add more default presets here
        ]
        
        for preset in defaultPresets {
            try savePreset(preset)
        }
    }
    
    func createDefaultTemplates() throws {
        // Create default project templates
        let defaultTemplates: [Template] = [
            Template(
                id: UUID(),
                name: "Electronic Starter",
                type: .electronic,
                tracks: [
                    Template.Track(
                        name: "Drums",
                        instrument: "DrumKit",
                        effects: ["Compressor", "EQ"],
                        automation: [],
                        patterns: []
                    ),
                    Template.Track(
                        name: "Bass",
                        instrument: "BassSynth",
                        effects: ["Distortion", "EQ"],
                        automation: [],
                        patterns: []
                    ),
                    Template.Track(
                        name: "Lead",
                        instrument: "LeadSynth",
                        effects: ["Delay", "Reverb"],
                        automation: [],
                        patterns: []
                    )
                ],
                mixer: Mixer(),
                bpm: 128.0,
                timeSignature: Template.TimeSignature(numerator: 4, denominator: 4),
                description: "A template for electronic music production",
                tags: ["electronic", "dance", "EDM"],
                author: "DiveDaw",
                version: "1.0",
                creationDate: Date(),
                lastModified: Date()
            ),
            // Add more default templates here
        ]
        
        for template in defaultTemplates {
            try saveTemplate(template)
        }
    }
} 