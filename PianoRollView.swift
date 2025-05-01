import SwiftUI
import AudioKit

struct PianoRollView: View {
    @ObservedObject var track: AudioTrack
    @State private var notes: [MIDINote] = []
    @State private var selectedNotes: Set<MIDINote> = []
    @State private var gridSize: CGFloat = 20
    @State private var currentOctave: Int = 4
    @State private var draggingNote: MIDINote?
    @State private var dragOffset: CGPoint = .zero
    
    var body: some View {
        VStack {
            // Piano keys on the left
            HStack(spacing: 0) {
                PianoKeysView(octave: currentOctave)
                    .frame(width: 100)
                
                // Main grid area
                ScrollView([.horizontal, .vertical]) {
                    ZStack {
                        // Grid background
                        GridBackgroundView(gridSize: gridSize)
                        
                        // MIDI notes
                        ForEach(notes) { note in
                            NoteView(note: note, gridSize: gridSize, isSelected: selectedNotes.contains(note))
                                .position(x: CGFloat(note.startTime) * gridSize + 50,
                                         y: CGFloat(127 - note.noteNumber) * gridSize + 20)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            handleNoteDrag(value: value, note: note)
                                        }
                                        .onEnded { value in
                                            finalizeNoteDrag(note: note)
                                        }
                                )
                                .onTapGesture {
                                    toggleNoteSelection(note)
                                }
                        }
                    }
                    .frame(width: 2000, height: 2000)
                }
            }
            
            // Controls
            HStack {
                Button("Add Note") {
                    addNote()
                }
                Button("Delete Selected") {
                    deleteSelectedNotes()
                }
                Slider(value: $gridSize, in: 10...50)
                    .frame(width: 200)
                Text("Octave: \(currentOctave)")
                Stepper("", value: $currentOctave, in: 0...8)
            }
            .padding()
        }
    }
    
    private func handleNoteDrag(value: DragGesture.Value, note: MIDINote) {
        if draggingNote == nil {
            draggingNote = note
            dragOffset = value.location
        }
        
        let timeDelta = (value.location.x - dragOffset.x) / gridSize
        let pitchDelta = (value.location.y - dragOffset.y) / gridSize
        
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.startTime = max(0, note.startTime + timeDelta)
            updatedNote.noteNumber = MIDIByte(max(0, min(127, Int(note.noteNumber) - Int(pitchDelta))))
            notes[index] = updatedNote
        }
    }
    
    private func finalizeNoteDrag(note: MIDINote) {
        draggingNote = nil
        dragOffset = .zero
        
        // Snap to grid
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            var updatedNote = note
            updatedNote.startTime = round(updatedNote.startTime * 4) / 4 // Snap to quarter notes
            notes[index] = updatedNote
        }
    }
    
    private func toggleNoteSelection(_ note: MIDINote) {
        if selectedNotes.contains(note) {
            selectedNotes.remove(note)
        } else {
            selectedNotes.insert(note)
        }
    }
    
    private func addNote() {
        let newNote = MIDINote(
            noteNumber: MIDIByte(60 + (currentOctave - 4) * 12), // Middle C in current octave
            velocity: 100,
            startTime: 0,
            duration: 1.0
        )
        notes.append(newNote)
    }
    
    private func deleteSelectedNotes() {
        notes.removeAll { selectedNotes.contains($0) }
        selectedNotes.removeAll()
    }
}

struct MIDINote: Identifiable {
    let id = UUID()
    var noteNumber: MIDIByte
    var velocity: MIDIByte
    var startTime: TimeInterval
    var duration: TimeInterval
}

struct PianoKeysView: View {
    let octave: Int
    private let whiteKeys = [0, 2, 4, 5, 7, 9, 11]
    private let blackKeys = [1, 3, 6, 8, 10]
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach((0...11).reversed(), id: \.self) { note in
                if blackKeys.contains(note) {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 20)
                } else {
                    Rectangle()
                        .fill(Color.white)
                        .frame(height: 20)
                        .border(Color.gray, width: 0.5)
                }
            }
        }
    }
}

struct GridBackgroundView: View {
    let gridSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                // Vertical lines
                for x in stride(from: 0, through: Int(geometry.size.width), by: Int(gridSize)) {
                    path.move(to: CGPoint(x: CGFloat(x), y: 0))
                    path.addLine(to: CGPoint(x: CGFloat(x), y: geometry.size.height))
                }
                
                // Horizontal lines
                for y in stride(from: 0, through: Int(geometry.size.height), by: Int(gridSize)) {
                    path.move(to: CGPoint(x: 0, y: CGFloat(y)))
                    path.addLine(to: CGPoint(x: geometry.size.width, y: CGFloat(y)))
                }
            }
            .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        }
    }
}

struct NoteView: View {
    let note: MIDINote
    let gridSize: CGFloat
    let isSelected: Bool
    
    var body: some View {
        Rectangle()
            .fill(isSelected ? Color.blue.opacity(0.7) : Color.blue.opacity(0.3))
            .frame(width: CGFloat(note.duration) * gridSize, height: gridSize - 2)
            .cornerRadius(4)
    }
} 