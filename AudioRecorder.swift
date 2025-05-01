import Foundation
import AudioKit

class AudioRecorder: ObservableObject {
    private var recorder: NodeRecorder?
    private var mic: AudioEngine.InputNode?
    private var mixer = Mixer()
    private var engine = AudioEngine()
    
    @Published var isRecording = false
    @Published var recordedFileURL: URL?
    
    init() {
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        do {
            mic = engine.input
            if let mic = mic {
                mixer.addInput(mic)
                engine.output = mixer
                try engine.start()
            }
        } catch {
            print("Error setting up audio engine: \(error)")
        }
    }
    
    func startRecording() {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording-\(Date().timeIntervalSince1970).wav")
            
            recorder = try NodeRecorder(node: mixer)
            try recorder?.record(to: audioFilename)
            isRecording = true
            recordedFileURL = audioFilename
        } catch {
            print("Error starting recording: \(error)")
        }
    }
    
    func stopRecording() {
        recorder?.stop()
        isRecording = false
    }
    
    func playRecording() {
        guard let url = recordedFileURL else { return }
        do {
            let player = AudioPlayer(url: url)
            engine.output = player
            try engine.start()
            player.play()
        } catch {
            print("Error playing recording: \(error)")
        }
    }
} 