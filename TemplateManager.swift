import Foundation

struct ProjectTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let genre: String
    let description: String
    let bpm: Int
    let timeSignature: String
    let tracks: [TrackTemplate]
}

struct TrackTemplate: Codable {
    let name: String
    let type: String // "audio", "midi", etc.
    let defaultInstrument: String?
    let defaultEffects: [String]
}

class TemplateManager {
    static let shared = TemplateManager()
    
    private let userDefaults = UserDefaults.standard
    private let showTemplateKey = "showTemplateSelection"
    
    private init() {}
    
    // Default templates for different genres
    var defaultTemplates: [ProjectTemplate] = [
        ProjectTemplate(
            id: "rock-basic",
            name: "Basic Rock Band",
            genre: "Rock",
            description: "Standard rock band setup with drums, bass, guitars and vocals",
            bpm: 120,
            timeSignature: "4/4",
            tracks: [
                TrackTemplate(name: "Drums", type: "midi", defaultInstrument: "Drum Kit", defaultEffects: ["Compression"]),
                TrackTemplate(name: "Bass", type: "audio", defaultInstrument: nil, defaultEffects: ["Compression", "EQ"]),
                TrackTemplate(name: "Guitar 1", type: "audio", defaultInstrument: nil, defaultEffects: ["Amp Sim", "Reverb"]),
                TrackTemplate(name: "Guitar 2", type: "audio", defaultInstrument: nil, defaultEffects: ["Amp Sim", "Delay"]),
                TrackTemplate(name: "Vocals", type: "audio", defaultInstrument: nil, defaultEffects: ["Compression", "EQ", "Reverb"])
            ]
        ),
        ProjectTemplate(
            id: "edm-basic",
            name: "EDM Production",
            genre: "Electronic",
            description: "Electronic dance music setup with synths and drums",
            bpm: 128,
            timeSignature: "4/4",
            tracks: [
                TrackTemplate(name: "Drums", type: "midi", defaultInstrument: "Drum Kit", defaultEffects: ["Compression"]),
                TrackTemplate(name: "Bass", type: "midi", defaultInstrument: "Bass Synth", defaultEffects: ["Compression", "Distortion"]),
                TrackTemplate(name: "Lead Synth", type: "midi", defaultInstrument: "Synth Lead", defaultEffects: ["Reverb", "Delay"]),
                TrackTemplate(name: "Pad", type: "midi", defaultInstrument: "Synth Pad", defaultEffects: ["Reverb"])
            ]
        )
    ]
    
    func shouldShowTemplateSelection() -> Bool {
        return userDefaults.bool(forKey: showTemplateKey)
    }
    
    func setShowTemplateSelection(_ show: Bool) {
        userDefaults.set(show, forKey: showTemplateKey)
    }
    
    func getTemplatesForGenre(_ genre: String) -> [ProjectTemplate] {
        return defaultTemplates.filter { $0.genre.lowercased() == genre.lowercased() }
    }
    
    func getAllGenres() -> [String] {
        return Array(Set(defaultTemplates.map { $0.genre })).sorted()
    }
}