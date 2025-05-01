import SwiftUI

struct PluginBrowserView: View {
    @State private var selectedCategory: PluginLibrary.PluginCategory = .synthesizer
    @State private var searchText = ""
    @State private var showingPluginDetails = false
    @State private var selectedPlugin: PluginLibrary.Plugin?
    @State private var isImporting = false
    
    private let pluginManager = PluginManager.shared
    
    var filteredPlugins: [PluginLibrary.Plugin] {
        let plugins = Array(pluginManager.plugins.values)
            .filter { $0.category == selectedCategory }
        
        if searchText.isEmpty {
            return plugins
        }
        
        return plugins.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(PluginLibrary.PluginCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    ForEach(filteredPlugins, id: \.id) { plugin in
                        PluginRowView(plugin: plugin)
                            .onTapGesture {
                                selectedPlugin = plugin
                                showingPluginDetails = true
                            }
                    }
                } header: {
                    Text("\(selectedCategory.rawValue)")
                }
            }
            .searchable(text: $searchText, prompt: "Search plugins")
            .navigationTitle("Plugin Browser")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isImporting = true }) {
                        Label("Import Plugin", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingPluginDetails) {
                if let plugin = selectedPlugin {
                    PluginDetailView(plugin: plugin)
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: true
            ) { result in
                // Handle plugin import
            }
        }
    }
}

struct PluginRowView: View {
    let plugin: PluginLibrary.Plugin
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(plugin.name)
                    .font(.headline)
                Spacer()
                if plugin.isNative {
                    Label("Native", systemImage: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Text(plugin.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Label("v\(plugin.version)", systemImage: "tag")
                Spacer()
                Label(plugin.manufacturer, systemImage: "building.2")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            HStack {
                if plugin.isVST {
                    Label("VST", systemImage: "plug")
                        .font(.caption)
                }
                if plugin.isAU {
                    Label("AU", systemImage: "waveform")
                        .font(.caption)
                }
                Spacer()
                Text("\(plugin.presets.count) presets")
                    .font(.caption)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct PluginDetailView: View {
    let plugin: PluginLibrary.Plugin
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPreset: PluginLibrary.Plugin.Preset?
    @State private var parameters: [String: Float]
    @State private var isSavingPreset = false
    @State private var newPresetName = ""
    
    init(plugin: PluginLibrary.Plugin) {
        self.plugin = plugin
        _parameters = State(initialValue: Dictionary(
            uniqueKeysWithValues: plugin.parameters.map { ($0.id, $0.defaultValue) }
        ))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Text(plugin.description)
                        .font(.body)
                } header: {
                    Text("Description")
                }
                
                Section {
                    ForEach(plugin.parameters, id: \.id) { param in
                        VStack(alignment: .leading) {
                            Text(param.name)
                                .font(.headline)
                            HStack {
                                Slider(
                                    value: Binding(
                                        get: { parameters[param.id] ?? param.defaultValue },
                                        set: { parameters[param.id] = $0 }
                                    ),
                                    in: param.range
                                )
                                Text("\(parameters[param.id] ?? param.defaultValue, specifier: "%.2f")")
                                    .font(.caption)
                                    .frame(width: 50)
                                Text(param.unit)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Parameters")
                }
                
                Section {
                    ForEach(plugin.presets, id: \.id) { preset in
                        VStack(alignment: .leading) {
                            Text(preset.name)
                                .font(.headline)
                            Text(preset.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .onTapGesture {
                            selectedPreset = preset
                            parameters = preset.parameters
                        }
                    }
                } header: {
                    HStack {
                        Text("Presets")
                        Spacer()
                        Button(action: { isSavingPreset = true }) {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }
                    }
                }
            }
            .navigationTitle(plugin.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Save Preset", isPresented: $isSavingPreset) {
                TextField("Preset Name", text: $newPresetName)
                Button("Cancel", role: .cancel) { }
                Button("Save") {
                    // Save preset
                    newPresetName = ""
                }
            }
        }
    }
}

#Preview {
    PluginBrowserView()
} 