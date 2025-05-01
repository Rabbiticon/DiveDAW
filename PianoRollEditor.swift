import SwiftUI

struct PianoRollEditor: View {
    @State private var notes: [Note] = []
    @State private var gridSize: CGFloat = 24
    @State private var octaves = 8
    @State private var selectedNote: Note? = nil
    
    let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    
    var body: some View {
        HStack(spacing: 0) {
            PianoKeys(octaves: octaves, noteNames: noteNames)
                .frame(width: 60)
            
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    GridBackground(gridSize: gridSize, octaves: octaves)
                    
                    ForEach(notes) { note in
                        NoteView(note: note, gridSize: gridSize, isSelected: selectedNote?.id == note.id)
                            .position(x: note.startTime * gridSize + gridSize/2,
                                     y: CGFloat(note.midiNote) * gridSize + gridSize/2)
                            .gesture(noteDragGesture(for: note))
                    }
                }
                .frame(width: 1920, height: CGFloat(octaves * 12) * gridSize)
            }
        }
        .overlay(alignment: .topLeading) {
            ToolbarView(gridSize: $gridSize)
                .padding(8)
        }
        .gesture(
            TapGesture(count: 2)
                .onEnded { location in
                    addNote(at: location)
                }
        )
    }
    
    private func noteDragGesture(for note: Note) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if selectedNote?.id != note.id {
                    selectedNote = note
                }
                
                if let index = notes.firstIndex(where: { $0.id == note.id }) {
                    var updatedNote = note
                    updatedNote.startTime = Double(value.location.x / gridSize)
                    updatedNote.midiNote = Int(value.location.y / gridSize)
                    notes[index] = updatedNote
                }
            }
    }
    
    private func addNote(at location: CGPoint) {
        let newNote = Note(
            startTime: Double(location.x / gridSize),
            duration: 1.0,
            midiNote: Int(location.y / gridSize),
            velocity: 100
        )
        notes.append(newNote)
    }
}

struct Note: Identifiable {
    let id = UUID()
    var startTime: Double
    var duration: Double
    var midiNote: Int
    var velocity: Int
}

struct PianoKeys: View {
    let octaves: Int
    let noteNames: [String]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach((0..<octaves).reversed(), id: \.self) { octave in
                ForEach(noteNames.indices, id: \.self) { index in
                    let isBlackKey = noteNames[index].contains("#")
                    Rectangle()
                        .fill(isBlackKey ? Color.black : Color.white)
                        .frame(height: 24)
                        .border(Color.gray, width: 0.5)
                        .overlay(
                            Text("\(noteNames[index])\(octave)")
                                .font(.system(size: 10))
                                .foregroundColor(isBlackKey ? .white : .black),
                            alignment: .leading
                        )
                }
            }
        }
    }
}

struct GridBackground: View {
    let gridSize: CGFloat
    let octaves: Int
    
    var body: some View {
        Canvas { context, size in
            for x in stride(from: 0, to: size.width, by: gridSize) {
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: size.height))
                }
                context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
            }
            
            for y in stride(from: 0, to: size.height, by: gridSize) {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(path, with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
            }
        }
    }
}

struct NoteView: View {
    let note: Note
    let gridSize: CGFloat
    let isSelected: Bool
    
    var body: some View {
        Rectangle()
            .fill(isSelected ? Color.blue.opacity(0.8) : Color.blue.opacity(0.6))
            .frame(width: note.duration * gridSize, height: gridSize - 2)
            .cornerRadius(4)
    }
}

struct ToolbarView: View {
    @Binding var gridSize: CGFloat
    
    var body: some View {
        HStack {
            Button(action: { gridSize = max(12, gridSize - 4) }) {
                Image(systemName: "minus.magnifyingglass")
            }
            Button(action: { gridSize = min(48, gridSize + 4) }) {
                Image(systemName: "plus.magnifyingglass")
            }
        }
        .buttonStyle(.bordered)
        .background(.ultraThinMaterial)
        .cornerRadius(6)
    }
}