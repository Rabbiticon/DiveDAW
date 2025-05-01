import Foundation
import AVFoundation
import SwiftUI

class VideoScoringSystem: ObservableObject {
    @Published var currentVideo: Video?
    @Published var markers: [Marker] = []
    @Published var tempoMap: [TempoPoint] = []
    @Published var hitPoints: [HitPoint] = []
    @Published var videoPosition: TimeInterval = 0
    @Published var isPlaying: Bool = false
    @Published var frameRate: Double = 30.0
    @Published var timecodeFormat: TimecodeFormat = .fps30
    @Published var videoWindowSize: CGSize = CGSize(width: 1280, height: 720)
    @Published var videoWindowPosition: CGPoint = .zero
    
    struct Video: Identifiable {
        let id = UUID()
        var url: URL
        var duration: TimeInterval
        var frameRate: Double
        var resolution: CGSize
        var aspectRatio: Double
        var audioTracks: [AudioTrack]
        var metadata: [String: String]
    }
    
    struct AudioTrack: Identifiable {
        let id = UUID()
        var name: String
        var type: AudioTrackType
        var isMuted: Bool
        var volume: Double
        var pan: Double
    }
    
    struct Marker: Identifiable {
        let id = UUID()
        var time: TimeInterval
        var name: String
        var description: String
        var color: Color
        var type: MarkerType
    }
    
    struct TempoPoint: Identifiable {
        let id = UUID()
        var time: TimeInterval
        var tempo: Double
        var timeSignature: TimeSignature
        var isLocked: Bool
    }
    
    struct HitPoint: Identifiable {
        let id = UUID()
        var time: TimeInterval
        var name: String
        var description: String
        var importance: HitPointImportance
        var isLocked: Bool
    }
    
    enum AudioTrackType: String, CaseIterable {
        case dialogue
        case music
        case effects
        case foley
        case ambience
        case narration
    }
    
    enum MarkerType: String, CaseIterable {
        case scene
        case shot
        case cue
        case note
        case reference
    }
    
    enum TimecodeFormat: String, CaseIterable {
        case fps24 = "24 fps"
        case fps25 = "25 fps"
        case fps30 = "30 fps"
        case fps60 = "60 fps"
        case fps120 = "120 fps"
    }
    
    enum HitPointImportance: Int, CaseIterable {
        case low = 1
        case medium = 2
        case high = 3
        case critical = 4
    }
    
    func importVideo(from url: URL) async throws {
        let asset = AVAsset(url: url)
        let duration = try await asset.load(.duration)
        let tracks = try await asset.load(.tracks)
        
        // Get video properties
        let videoTrack = tracks.first(where: { $0.mediaType == .video })
        let frameRate = try await videoTrack?.load(.nominalFrameRate) ?? 30.0
        let naturalSize = try await videoTrack?.load(.naturalSize) ?? CGSize(width: 1920, height: 1080)
        
        // Get audio tracks
        var audioTracks: [AudioTrack] = []
        for track in tracks where track.mediaType == .audio {
            audioTracks.append(AudioTrack(
                name: "Audio Track \(audioTracks.count + 1)",
                type: .effects,
                isMuted: false,
                volume: 1.0,
                pan: 0.0
            ))
        }
        
        // Create video object
        let video = Video(
            url: url,
            duration: duration.seconds,
            frameRate: frameRate,
            resolution: naturalSize,
            aspectRatio: naturalSize.width / naturalSize.height,
            audioTracks: audioTracks,
            metadata: [:]
        )
        
        DispatchQueue.main.async {
            self.currentVideo = video
            self.frameRate = frameRate
        }
    }
    
    func addMarker(at time: TimeInterval, name: String, type: MarkerType) {
        let marker = Marker(
            time: time,
            name: name,
            description: "",
            color: .blue,
            type: type
        )
        markers.append(marker)
        markers.sort { $0.time < $1.time }
    }
    
    func addTempoPoint(at time: TimeInterval, tempo: Double, timeSignature: TimeSignature) {
        let tempoPoint = TempoPoint(
            time: time,
            tempo: tempo,
            timeSignature: timeSignature,
            isLocked: true
        )
        tempoMap.append(tempoPoint)
        tempoMap.sort { $0.time < $1.time }
    }
    
    func addHitPoint(at time: TimeInterval, name: String, importance: HitPointImportance) {
        let hitPoint = HitPoint(
            time: time,
            name: name,
            description: "",
            importance: importance,
            isLocked: false
        )
        hitPoints.append(hitPoint)
        hitPoints.sort { $0.time < $1.time }
    }
    
    func removeMarker(_ marker: Marker) {
        markers.removeAll { $0.id == marker.id }
    }
    
    func removeTempoPoint(_ tempoPoint: TempoPoint) {
        tempoMap.removeAll { $0.id == tempoPoint.id }
    }
    
    func removeHitPoint(_ hitPoint: HitPoint) {
        hitPoints.removeAll { $0.id == hitPoint.id }
    }
    
    func setVideoPosition(_ position: TimeInterval) {
        videoPosition = position
        // Update any synchronized elements
    }
    
    func play() {
        isPlaying = true
        // Start video and audio playback
    }
    
    func pause() {
        isPlaying = false
        // Pause video and audio playback
    }
    
    func stop() {
        isPlaying = false
        videoPosition = 0
        // Stop video and audio playback
    }
    
    func exportVideo(withAudio: Bool = true, format: ExportFormat) async throws -> URL {
        // Implement video export with optional audio
        return URL(fileURLWithPath: "")
    }
    
    func generateTimecode(at time: TimeInterval) -> String {
        let frames = Int(time * frameRate)
        let hours = frames / (Int(frameRate) * 3600)
        let minutes = (frames / (Int(frameRate) * 60)) % 60
        let seconds = (frames / Int(frameRate)) % 60
        let frame = frames % Int(frameRate)
        
        return String(format: "%02d:%02d:%02d:%02d", hours, minutes, seconds, frame)
    }
    
    func snapToNearestFrame(_ time: TimeInterval) -> TimeInterval {
        let frameDuration = 1.0 / frameRate
        let frameCount = round(time / frameDuration)
        return frameCount * frameDuration
    }
    
    func getTempoAtTime(_ time: TimeInterval) -> (tempo: Double, timeSignature: TimeSignature) {
        let previousPoints = tempoMap.filter { $0.time <= time }
        guard let lastPoint = previousPoints.last else {
            return (120.0, .fourFour) // Default values
        }
        return (lastPoint.tempo, lastPoint.timeSignature)
    }
    
    func getHitPointsInRange(start: TimeInterval, end: TimeInterval) -> [HitPoint] {
        return hitPoints.filter { $0.time >= start && $0.time <= end }
    }
    
    func getMarkersInRange(start: TimeInterval, end: TimeInterval) -> [Marker] {
        return markers.filter { $0.time >= start && $0.time <= end }
    }
    
    func getTempoPointsInRange(start: TimeInterval, end: TimeInterval) -> [TempoPoint] {
        return tempoMap.filter { $0.time >= start && $0.time <= end }
    }
    
    func setVideoWindowSize(_ size: CGSize) {
        videoWindowSize = size
    }
    
    func setVideoWindowPosition(_ position: CGPoint) {
        videoWindowPosition = position
    }
    
    func toggleAudioTrackMute(_ track: AudioTrack) {
        if let index = currentVideo?.audioTracks.firstIndex(where: { $0.id == track.id }) {
            currentVideo?.audioTracks[index].isMuted.toggle()
        }
    }
    
    func setAudioTrackVolume(_ track: AudioTrack, volume: Double) {
        if let index = currentVideo?.audioTracks.firstIndex(where: { $0.id == track.id }) {
            currentVideo?.audioTracks[index].volume = volume
        }
    }
    
    func setAudioTrackPan(_ track: AudioTrack, pan: Double) {
        if let index = currentVideo?.audioTracks.firstIndex(where: { $0.id == track.id }) {
            currentVideo?.audioTracks[index].pan = pan
        }
    }
    
    enum ExportFormat {
        case mov
        case mp4
        case proRes
        case dnxhd
    }
} 