import SwiftUI

struct TemplateSelectionView: View {
    @State private var selectedGenre: String? = nil
    @State private var showTemplateSelection: Bool = true
    @State private var searchText = ""
    @State private var showTemplateDetails = false
    @State private var selectedTemplate: ProjectTemplate? = nil
    
    private let templateManager = TemplateManager.shared
    private var genres: [String] { templateManager.getAllGenres() }
    
    var filteredTemplates: [ProjectTemplate] {
        guard let genre = selectedGenre else { return [] }
        let templates = templateManager.getTemplatesForGenre(genre)
        if searchText.isEmpty { return templates }
        return templates.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(genres, id: \.self) { genre in
                        Button(action: { selectedGenre = genre }) {
                            HStack {
                                Text(genre)
                                Spacer()
                                if selectedGenre == genre {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .foregroundColor(.primary)
                    }
                } header: {
                    Text("Genres")
                }
                
                if let selectedGenre = selectedGenre {
                    Section {
                        ForEach(filteredTemplates) { template in
                            TemplateRowView(template: template)
                                .onTapGesture {
                                    selectedTemplate = template
                                    showTemplateDetails = true
                                }
                        }
                    } header: {
                        Text("Templates for \(selectedGenre)")
                    }
                }
                
                Section {
                    Toggle("Don't show template selection when creating new projects", isOn: $showTemplateSelection)
                        .onChange(of: showTemplateSelection) { newValue in
                            templateManager.setShowTemplateSelection(newValue)
                        }
                }
            }
            .searchable(text: $searchText, prompt: "Search templates")
            .navigationTitle("Project Templates")
            .sheet(isPresented: $showTemplateDetails) {
                if let template = selectedTemplate {
                    TemplateDetailView(template: template)
                }
            }
        }
    }
}

struct TemplateRowView: View {
    let template: ProjectTemplate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(template.name)
                    .font(.headline)
                Spacer()
                if template.isLightweight {
                    Label("Lightweight", systemImage: "leaf.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Text(template.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(template.bpm) BPM", systemImage: "metronome")
                Spacer()
                Label(template.timeSignature, systemImage: "music.note")
                Spacer()
                Label(template.key, systemImage: "music.quarternote.3")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            if !template.isLightweight {
                HStack {
                    Label("\(template.presetData.tracks.count) tracks", systemImage: "waveform")
                    Spacer()
                    Label("\(template.presetData.mixerSettings.busSettings.count) buses", systemImage: "arrow.triangle.branch")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TemplateDetailView: View {
    let template: ProjectTemplate
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(template.description)
                        .font(.body)
                } header: {
                    Text("Description")
                }
                
                Section {
                    LabeledContent("BPM", value: "\(template.bpm)")
                    LabeledContent("Time Signature", value: template.timeSignature)
                    LabeledContent("Key", value: template.key)
                } header: {
                    Text("Project Settings")
                }
                
                if !template.isLightweight {
                    Section {
                        ForEach(template.presetData.tracks, id: \.name) { track in
                            VStack(alignment: .leading) {
                                Text(track.name)
                                    .font(.headline)
                                Text(track.type.rawValue.capitalized)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                if let instrument = track.instrument {
                                    Text("Instrument: \(instrument.type.rawValue)")
                                        .font(.caption)
                                }
                                
                                if !track.effects.isEmpty {
                                    Text("Effects: \(track.effects.count)")
                                        .font(.caption)
                                }
                                
                                if !track.clips.isEmpty {
                                    Text("Clips: \(track.clips.count)")
                                        .font(.caption)
                                }
                            }
                        }
                    } header: {
                        Text("Tracks")
                    }
                    
                    Section {
                        ForEach(template.presetData.mixerSettings.busSettings.sorted(by: { $0.key < $1.key }), id: \.key) { name, bus in
                            VStack(alignment: .leading) {
                                Text(name)
                                    .font(.headline)
                                Text("Effects: \(bus.effects.count)")
                                    .font(.caption)
                            }
                        }
                    } header: {
                        Text("Buses")
                    }
                }
            }
            .navigationTitle(template.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Use Template") {
                        // Handle template selection
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TemplateSelectionView()
}