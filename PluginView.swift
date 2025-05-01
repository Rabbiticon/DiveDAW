import SwiftUI

struct PluginView: View {
    @ObservedObject var track: AudioTrack
    @StateObject private var pluginManager = PluginManager.shared
    @State private var showingPluginPicker = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Plugin Chain Header
            HStack {
                Text("Plugins")
                    .font(.headline)
                Spacer()
                Button(action: { showingPluginPicker = true }) {
                    Image(systemName: "plus.circle")
                }
            }
            .padding(.horizontal)
            
            // Active Plugins List
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(pluginManager.activePlugins) { plugin in
                        PluginItemView(plugin: plugin)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingPluginPicker) {
            PluginPickerView(track: track)
        }
    }
}

struct PluginItemView: View {
    @ObservedObject var plugin: Plugin
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(plugin.name)
                        .font(.headline)
                    Text(plugin.manufacturer)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: $plugin.isEnabled)
                    .toggleStyle(.switch)
            }
            
            // Plugin Parameters
            ForEach(Array(plugin.parameters.keys.sorted()), id: \.self) { key in
                if let value = plugin.parameters[key] {
                    HStack {
                        Text(key)
                            .font(.caption)
                        Slider(value: .init(get: { value },
                                          set: { plugin.parameters[key] = $0 }),
                               in: 0...1)
                    }
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct PluginPickerView: View {
    @ObservedObject var track: AudioTrack
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var pluginManager = PluginManager.shared
    
    var body: some View {
        NavigationView {
            List(pluginManager.availablePlugins) { plugin in
                HStack {
                    VStack(alignment: .leading) {
                        Text(plugin.name)
                            .font(.headline)
                        Text(plugin.manufacturer)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(plugin.type.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if pluginManager.loadPlugin(plugin) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .navigationTitle("Add Plugin")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}