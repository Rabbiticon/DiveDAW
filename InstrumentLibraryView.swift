import SwiftUI
import AudioKit

struct InstrumentLibraryView: View {
    @ObservedObject var track: AudioTrack
    @StateObject private var instrumentManager = VirtualInstrumentManager.shared
    @Environment(".dismiss") var dismiss
    @State private var searchText = ""
    
    var filteredInstruments: [VirtualInstrument] {
        if searchText.isEmpty {
            return instrumentManager.instruments
        }
        return instrumentManager.instruments.filter { $0.type.displayName.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            List(filteredInstruments, id: \.id) { instrument in
                InstrumentRowView(instrument: instrument, track: track)
            }
            .searchable(text: $searchText, prompt: "Search instruments")
            .navigationTitle("Instrument Library")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct InstrumentRowView: View {
    @ObservedObject var instrument: VirtualInstrument
    @ObservedObject var track: AudioTrack
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(instrument.type.displayName)
                    .font(.headline)
                Text("MIDI Channel \(track.midiChannel)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle(isOn: $instrument.isEnabled) {
                EmptyView()
            }
            .toggleStyle(.switch)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            track.setInstrument(instrument)
        }
    }
}