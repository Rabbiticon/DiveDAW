import SwiftUI

struct MicrophoneTrackView: View {
    @ObservedObject var track: MicrophoneTrack
    @State private var showAutotuneControls = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Track Header
            HStack {
                Text(track.name)
                    .font(.headline)
                Spacer()
                recordButton
                autotuneToggle
            }
            .padding(.horizontal)
            
            // Main Controls
            HStack(spacing: 16) {
                volumeControl
                panControl
                muteButton
            }
            .padding(.horizontal)
            
            // Autotune Controls
            if showAutotuneControls && track.autotuneEnabled {
                autotuneControls
                    .padding(.horizontal)
                    .transition(.slide)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var recordButton: some View {
        Button(action: {
            if track.isRecording {
                track.stopRecording()
            } else {
                track.startRecording()
            }
        }) {
            Image(systemName: track.isRecording ? "stop.circle.fill" : "record.circle")
                .foregroundColor(track.isRecording ? .red : .gray)
                .font(.title2)
        }
    }
    
    private var autotuneToggle: some View {
        Button(action: {
            withAnimation {
                track.autotuneEnabled.toggle()
                showAutotuneControls = track.autotuneEnabled
            }
        }) {
            Image(systemName: track.autotuneEnabled ? "waveform.path.ecg.rectangle.fill" : "waveform.path.ecg.rectangle")
                .foregroundColor(track.autotuneEnabled ? .blue : .gray)
                .font(.title2)
        }
    }
    
    private var volumeControl: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Volume")
                .font(.caption)
            Slider(value: $track.volume, in: 0...1)
                .accentColor(.blue)
        }
    }
    
    private var panControl: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Pan")
                .font(.caption)
            Slider(value: $track.pan, in: -1...1)
                .accentColor(.green)
        }
    }
    
    private var muteButton: some View {
        Button(action: { track.isMuted.toggle() }) {
            Image(systemName: track.isMuted ? "speaker.slash.fill" : "speaker.wave.2.fill")
                .foregroundColor(track.isMuted ? .red : .gray)
        }
    }
    
    private var autotuneControls: some View {
        VStack(spacing: 12) {
            // Intensity Control
            VStack(alignment: .leading, spacing: 4) {
                Text("Autotune Intensity")
                    .font(.caption)
                Slider(value: $track.autotuneIntensity, in: 0...1)
                    .accentColor(.purple)
            }
            
            // Speed Control
            VStack(alignment: .leading, spacing: 4) {
                Text("Correction Speed")
                    .font(.caption)
                Slider(value: $track.autotuneSpeed, in: 0...1)
                    .accentColor(.orange)
            }
            
            // Scale Picker
            VStack(alignment: .leading, spacing: 4) {
                Text("Scale")
                    .font(.caption)
                Picker("", selection: $track.selectedScale) {
                    Text("Chromatic").tag(Scale.chromatic)
                    Text("Major").tag(Scale.major)
                    Text("Minor").tag(Scale.minor)
                    Text("Pentatonic").tag(Scale.pentatonic)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .padding(.top, 8)
    }
}

struct MicrophoneTrackView_Previews: PreviewProvider {
    static var previews: some View {
        MicrophoneTrackView(track: MicrophoneTrack())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}