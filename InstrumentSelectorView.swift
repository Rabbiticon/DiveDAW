import SwiftUI
import AudioKit

struct InstrumentSelectorView: View {
    @ObservedObject var track: AudioTrack
    @State private var selectedCategory: InstrumentCategory = .synth
    @State private var selectedPreset: String = ""
    
    enum InstrumentCategory: String, CaseIterable {
        case synth = "Synthesizers"
        case sampler = "Samplers"
        case effects = "Effects"
        case advanced = "Advanced"
    }
    
    var body: some View {
        VStack {
            // Category selector
            Picker("Category", selection: $selectedCategory) {
                ForEach(InstrumentCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Instrument list
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    switch selectedCategory {
                    case .synth:
                        synthInstruments
                    case .sampler:
                        samplerInstruments
                    case .effects:
                        effectInstruments
                    case .advanced:
                        advancedInstruments
                    }
                }
                .padding()
            }
        }
    }
    
    private var synthInstruments: some View {
        VStack(alignment: .leading) {
            Text("Analog Synth")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let synth = InstrumentLibrary.shared.createAnalogSynth()
                    track.setInstrument(synth)
                }
            
            Text("FM Synth")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let synth = InstrumentLibrary.shared.createFMSynth()
                    track.setInstrument(synth)
                }
            
            Text("Wavetable Synth")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let synth = InstrumentLibrary.shared.createWavetableSynth()
                    track.setInstrument(synth)
                }
            
            // Synth presets
            ForEach(InstrumentLibrary.shared.synthPresets, id: \.name) { preset in
                Text("Preset: \(preset.name)")
                    .padding()
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let synth = InstrumentLibrary.shared.createAnalogSynth()
                        InstrumentLibrary.shared.applyPreset(preset, to: synth)
                        track.setInstrument(synth)
                    }
            }
        }
    }
    
    private var samplerInstruments: some View {
        VStack(alignment: .leading) {
            Text("Drum Sampler")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let sampler = InstrumentLibrary.shared.createDrumSampler()
                    track.setInstrument(sampler)
                }
            
            Text("Piano Sampler")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let sampler = InstrumentLibrary.shared.createPianoSampler()
                    track.setInstrument(sampler)
                }
            
            Text("String Sampler")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let sampler = InstrumentLibrary.shared.createStringSampler()
                    track.setInstrument(sampler)
                }
        }
    }
    
    private var effectInstruments: some View {
        VStack(alignment: .leading) {
            Text("Reverb")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let reverb = InstrumentLibrary.shared.createReverbEffect()
                    track.mixer.addInput(reverb)
                }
            
            Text("Delay")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let delay = InstrumentLibrary.shared.createDelayEffect()
                    track.mixer.addInput(delay)
                }
            
            Text("Distortion")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let distortion = InstrumentLibrary.shared.createDistortionEffect()
                    track.mixer.addInput(distortion)
                }
            
            Text("Compressor")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let compressor = InstrumentLibrary.shared.createCompressorEffect()
                    track.mixer.addInput(compressor)
                }
            
            Text("EQ")
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let eq = InstrumentLibrary.shared.createEQEffect()
                    track.mixer.addInput(eq)
                }
        }
    }
    
    private var advancedInstruments: some View {
        VStack(alignment: .leading) {
            // Granular Synthesis
            Text("Granular Synth")
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let synth = InstrumentLibrary.shared.createGranularSynth()
                    track.setInstrument(synth)
                }
            
            // Granular Presets
            ForEach(InstrumentLibrary.shared.granularPresets, id: \.name) { preset in
                Text("Granular: \(preset.name)")
                    .padding()
                    .background(Color.purple.opacity(0.3))
                    .cornerRadius(8)
                    .onTapGesture {
                        let synth = InstrumentLibrary.shared.createGranularSynth()
                        InstrumentLibrary.shared.applyGranularPreset(preset, to: synth)
                        track.setInstrument(synth)
                    }
            }
            
            // Vocoder
            Text("Vocoder")
                .padding()
                .background(Color.purple.opacity(0.2))
                .cornerRadius(8)
                .onTapGesture {
                    let vocoder = InstrumentLibrary.shared.createVocoder()
                    track.setInstrument(vocoder)
                }
            
            // Advanced Effects
            Group {
                Text("Convolution Reverb")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let reverb = InstrumentLibrary.shared.createConvolutionReverb()
                        track.mixer.addInput(reverb)
                    }
                
                Text("Bit Crusher")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let crusher = InstrumentLibrary.shared.createBitCrusher()
                        track.mixer.addInput(crusher)
                    }
                
                Text("Frequency Shifter")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let shifter = InstrumentLibrary.shared.createFrequencyShifter()
                        track.mixer.addInput(shifter)
                    }
                
                Text("Phase Vocoder")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let vocoder = InstrumentLibrary.shared.createPhaseVocoder()
                        track.mixer.addInput(vocoder)
                    }
                
                Text("Spectral Gate")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let gate = InstrumentLibrary.shared.createSpectralGate()
                        track.mixer.addInput(gate)
                    }
                
                Text("Granular Delay")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let delay = InstrumentLibrary.shared.createGranularDelay()
                        track.mixer.addInput(delay)
                    }
                
                Text("Spectral Compressor")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let compressor = InstrumentLibrary.shared.createSpectralCompressor()
                        track.mixer.addInput(compressor)
                    }
                
                Text("Spectral Flanger")
                    .padding()
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(8)
                    .onTapGesture {
                        let flanger = InstrumentLibrary.shared.createSpectralFlanger()
                        track.mixer.addInput(flanger)
                    }
            }
        }
    }
} 