import Foundation
import AudioKit

struct ProjectTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let genre: String
    let bpm: Int
    let timeSignature: String
    let key: String
    let presetData: TemplatePresetData
    let isLightweight: Bool
    
    struct TemplatePresetData: Codable {
        // Track configurations
        let tracks: [TrackPreset]
        let mixerSettings: MixerPreset
        let masterSettings: MasterPreset
        
        struct TrackPreset: Codable {
            let name: String
            let type: TrackType
            let instrument: InstrumentPreset?
            let effects: [EffectPreset]
            let automation: [AutomationPreset]
            let clips: [ClipPreset]
            
            enum TrackType: String, Codable {
                case audio
                case midi
                case bus
                case master
            }
            
            struct InstrumentPreset: Codable {
                let type: InstrumentType
                let parameters: [String: Float]
                let midiMapping: [String: Int]
                
                enum InstrumentType: String, Codable {
                    case analogSynth
                    case fmSynth
                    case wavetableSynth
                    case granularSynth
                    case vocoder
                    case drumSampler
                    case pianoSampler
                    case stringSampler
                }
            }
            
            struct EffectPreset: Codable {
                let type: EffectType
                let parameters: [String: Float]
                let position: Int
                
                enum EffectType: String, Codable {
                    case reverb
                    case delay
                    case distortion
                    case compressor
                    case eq
                    case bitCrusher
                    case frequencyShifter
                    case phaseVocoder
                    case spectralGate
                    case spectralFlanger
                }
            }
            
            struct AutomationPreset: Codable {
                let parameter: String
                let points: [AutomationPoint]
                
                struct AutomationPoint: Codable {
                    let time: Double
                    let value: Float
                    let curve: AutomationCurve
                    
                    enum AutomationCurve: String, Codable {
                        case linear
                        case exponential
                        case logarithmic
                        case bezier
                    }
                }
            }
            
            struct ClipPreset: Codable {
                let name: String
                let startTime: Double
                let duration: Double
                let content: ClipContent
                
                enum ClipContent: Codable {
                    case audio(AudioClipPreset)
                    case midi(MIDIClipPreset)
                    
                    struct AudioClipPreset: Codable {
                        let filePath: String
                        let gain: Float
                        let fadeIn: Double
                        let fadeOut: Double
                    }
                    
                    struct MIDIClipPreset: Codable {
                        let notes: [MIDINotePreset]
                        let quantization: String
                        
                        struct MIDINotePreset: Codable {
                            let pitch: Int
                            let velocity: Int
                            let startTime: Double
                            let duration: Double
                        }
                    }
                }
            }
        }
        
        struct MixerPreset: Codable {
            let routing: [String: String] // Track to bus routing
            let busSettings: [String: BusPreset]
            
            struct BusPreset: Codable {
                let effects: [EffectPreset]
                let volume: Float
                let pan: Float
            }
        }
        
        struct MasterPreset: Codable {
            let effects: [EffectPreset]
            let volume: Float
            let limiterThreshold: Float
            let dithering: Bool
        }
    }
    
    // Lightweight template constructor
    static func lightweight(name: String, description: String, genre: String, bpm: Int, timeSignature: String, key: String) -> ProjectTemplate {
        return ProjectTemplate(
            id: UUID(),
            name: name,
            description: description,
            genre: genre,
            bpm: bpm,
            timeSignature: timeSignature,
            key: key,
            presetData: TemplatePresetData(
                tracks: [],
                mixerSettings: MixerPreset(
                    routing: [:],
                    busSettings: [:]
                ),
                masterSettings: MasterPreset(
                    effects: [],
                    volume: 1.0,
                    limiterThreshold: -1.0,
                    dithering: false
                )
            ),
            isLightweight: true
        )
    }
} 