import SwiftUI
import AudioKit

struct TransportControls: View {
    @State private var isPlaying = false
    @State private var isRecording = false
    @State private var currentTime: Double = 0.0
    @State private var tempo: Double = 120.0
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 20) {
                Button(action: { isPlaying.toggle() }) {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.blue)
                }
                
                Button(action: { isRecording.toggle() }) {
                    Image(systemName: "record.circle")
                        .font(.system(size: 32))
                        .foregroundColor(isRecording ? .red : .gray)
                }
                
                Button(action: { currentTime = 0.0 }) {
                    Image(systemName: "backward.end.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading) {
                    Text("Time: \(formatTime(currentTime))")
                        .font(.system(.body, design: .monospaced))
                    
                    HStack {
                        Text("BPM:")
                        TextField("", value: $tempo, formatter: NumberFormatter())
                            .frame(width: 60)
                            .textFieldStyle(.roundedBorder)
                    }
                }
            }
            
            TimelineView(currentTime: $currentTime)
        }
        .padding()
    }
    
    private func formatTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let milliseconds = Int((time.truncatingRemainder(dividingBy: 1)) * 1000)
        return String(format: "%02d:%02d:%03d", minutes, seconds, milliseconds)
    }
}

struct TimelineView: View {
    @Binding var currentTime: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.blue.opacity(0.1))
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 2)
                    .offset(x: geometry.size.width * CGFloat(currentTime / 60.0))
                
                ForEach(0..<61) { i in
                    Rectangle()
                        .fill(Color.blue.opacity(i % 4 == 0 ? 0.8 : 0.4))
                        .frame(width: 1, height: i % 4 == 0 ? 12 : 8)
                        .offset(x: geometry.size.width * CGFloat(Double(i) / 60.0))
                }
            }
        }
        .frame(height: 24)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let ratio = value.location.x / value.startLocation.x
                    currentTime = max(0, min(60, Double(ratio) * currentTime))
                }
        )
    }
}