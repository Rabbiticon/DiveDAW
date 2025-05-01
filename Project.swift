
import Foundation
import AudioKit

struct Project: Codable {
    var name: String
    var tracks: [TrackData]
    var tempo: Double
    var timeSignature: TimeSignature
    
    struct TimeSignature: Codable {
        var numerator: Int
        var denominator: Int
    }
    
    struct TrackData: Codable, Identifiable {
        let id: UUID
        var name: String
        var volume: Float
        var pan: Float
        var isMuted: Bool
        var audioFilePath: String?
        
        
        }
    }
    
    init(name: String, tracks: [AudioTrack]) {
        self.name = name
        self.tracks = tracks.map { TrackData(from: $0) }
        self.tempo = 120.0 // Default tempo
        self.timeSignature = TimeSignature(numerator: 4, denominator: 4) // Default time signature
    }
    
    func loadAudioFile(for track: TrackData) -> AudioFile? {
        guard let path = track.audioFilePath else { return nil }
        return try? AudioFile(readFileName: path)
    }
    
    func saveAudioFile(for track: TrackData, audioFile: AudioFile) {
        track.audioFilePath = audioFile.fileName
    }
}