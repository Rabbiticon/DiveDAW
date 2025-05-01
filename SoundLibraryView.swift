import SwiftUI
import AVFoundation

struct SoundLibraryView: View {
    @State private var selectedCategory: String?
    @State private var searchText = ""
    @State private var isImporting = false
    @State private var showingSampleDetails = false
    @State private var selectedSample: PluginLibrary.SoundLibrary.Sample?
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    private let pluginManager = PluginManager.shared
    
    var categories: [String] {
        Array(Set(pluginManager.soundLibraries.values.map(\.category))).sorted()
    }
    
    var filteredSamples: [PluginLibrary.SoundLibrary.Sample] {
        let allSamples = pluginManager.soundLibraries.values.flatMap { library in
            guard selectedCategory == nil || library.category == selectedCategory else {
                return []
            }
            return library.samples
        }
        
        if searchText.isEmpty {
            return allSamples
        }
        
        return allSamples.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            CategoryButton(
                                title: "All",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )
                            
                            ForEach(categories, id: \.self) { category in
                                CategoryButton(
                                    title: category,
                                    isSelected: category == selectedCategory,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Section {
                    ForEach(filteredSamples, id: \.id) { sample in
                        SampleRowView(sample: sample)
                            .onTapGesture {
                                selectedSample = sample
                                showingSampleDetails = true
                            }
                    }
                } header: {
                    Text(selectedCategory ?? "All Samples")
                }
            }
            .searchable(text: $searchText, prompt: "Search samples")
            .navigationTitle("Sound Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isImporting = true }) {
                        Label("Import Samples", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingSampleDetails) {
                if let sample = selectedSample {
                    SampleDetailView(sample: sample)
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true
            ) { result in
                // Handle sample import
            }
        }
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct SampleRowView: View {
    let sample: PluginLibrary.SoundLibrary.Sample
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(sample.name)
                    .font(.headline)
                Spacer()
                Button(action: togglePlayback) {
                    Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                }
            }
            
            HStack {
                Label(String(format: "%.1f sec", sample.duration), systemImage: "clock")
                Spacer()
                Label("\(sample.sampleRate) Hz", systemImage: "waveform")
                Spacer()
                Label("\(sample.bitDepth) bit", systemImage: "music.note")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if !sample.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(sample.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
        } else {
            do {
                let url = URL(fileURLWithPath: sample.path)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Error playing sample: \(error)")
            }
        }
    }
}

struct SampleDetailView: View {
    let sample: PluginLibrary.SoundLibrary.Sample
    @Environment(\.dismiss) private var dismiss
    @State private var isPlaying = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isEditingTags = false
    @State private var newTag = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Spacer()
                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                                .font(.system(size: 48))
                        }
                        Spacer()
                    }
                }
                
                Section {
                    LabeledContent("Duration", value: String(format: "%.1f sec", sample.duration))
                    LabeledContent("Sample Rate", value: "\(sample.sampleRate) Hz")
                    LabeledContent("Bit Depth", value: "\(sample.bitDepth) bit")
                    LabeledContent("Channels", value: "\(sample.channels)")
                    LabeledContent("Format", value: sample.format)
                } header: {
                    Text("Properties")
                }
                
                Section {
                    ForEach(sample.tags, id: \.self) { tag in
                        Text(tag)
                    }
                    
                    Button(action: { isEditingTags = true }) {
                        Label("Add Tag", systemImage: "plus")
                    }
                } header: {
                    Text("Tags")
                }
                
                if !sample.metadata.isEmpty {
                    Section {
                        ForEach(Array(sample.metadata.keys.sorted()), id: \.self) { key in
                            if let value = sample.metadata[key] {
                                LabeledContent(key, value: value)
                            }
                        }
                    } header: {
                        Text("Metadata")
                    }
                }
            }
            .navigationTitle(sample.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Add Tag", isPresented: $isEditingTags) {
                TextField("Tag Name", text: $newTag)
                Button("Cancel", role: .cancel) { }
                Button("Add") {
                    // Add tag
                    newTag = ""
                }
            }
        }
    }
    
    private func togglePlayback() {
        if isPlaying {
            audioPlayer?.stop()
            isPlaying = false
        } else {
            do {
                let url = URL(fileURLWithPath: sample.path)
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                isPlaying = true
            } catch {
                print("Error playing sample: \(error)")
            }
        }
    }
}

#Preview {
    SoundLibraryView()
} 