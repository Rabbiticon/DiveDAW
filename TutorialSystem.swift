import Foundation
import SwiftUI

class TutorialSystem: ObservableObject {
    @Published var tutorials: [Tutorial] = []
    @Published var currentTutorial: Tutorial?
    @Published var currentStep: Int = 0
    @Published var isTutorialActive: Bool = false
    @Published var tutorialProgress: [String: Double] = [:]
    
    struct Tutorial: Identifiable {
        let id = UUID()
        var title: String
        var description: String
        var category: TutorialCategory
        var difficulty: TutorialDifficulty
        var steps: [TutorialStep]
        var estimatedDuration: TimeInterval
        var prerequisites: [String]
        var tags: [String]
        var isCompleted: Bool
    }
    
    struct TutorialStep: Identifiable {
        let id = UUID()
        var title: String
        var description: String
        var instructions: [String]
        var interactiveElements: [InteractiveElement]
        var hints: [String]
        var completionCriteria: [CompletionCriterion]
        var isCompleted: Bool
    }
    
    struct InteractiveElement {
        var type: InteractiveElementType
        var target: String
        var action: String
        var successMessage: String
        var failureMessage: String
    }
    
    struct CompletionCriterion {
        var type: CompletionCriterionType
        var target: String
        var value: Any
        var comparison: ComparisonOperator
    }
    
    enum TutorialCategory: String, CaseIterable {
        case gettingStarted = "Getting Started"
        case recording = "Recording"
        case editing = "Editing"
        case mixing = "Mixing"
        case effects = "Effects"
        case instruments = "Instruments"
        case automation = "Automation"
        case arrangement = "Arrangement"
        case export = "Export"
        case advanced = "Advanced"
    }
    
    enum TutorialDifficulty: String, CaseIterable {
        case beginner
        case intermediate
        case advanced
    }
    
    enum InteractiveElementType: String, CaseIterable {
        case button
        case slider
        case dropdown
        case checkbox
        case textField
        case fileDrop
        case dragAndDrop
    }
    
    enum CompletionCriterionType: String, CaseIterable {
        case buttonClick
        case valueChange
        case fileImport
        case audioRecord
        case midiRecord
        case effectAdd
        case automationCreate
        case exportComplete
    }
    
    enum ComparisonOperator: String, CaseIterable {
        case equals
        case greaterThan
        case lessThan
        case contains
        case matches
    }
    
    func loadTutorials() {
        tutorials = [
            Tutorial(
                title: "Getting Started with DiveDaw",
                description: "Learn the basics of DiveDaw and create your first project",
                category: .gettingStarted,
                difficulty: .beginner,
                steps: [
                    TutorialStep(
                        title: "Welcome to DiveDaw",
                        description: "Introduction to the interface and basic navigation",
                        instructions: [
                            "Open DiveDaw",
                            "Familiarize yourself with the main interface",
                            "Learn about the different views and panels"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "mainMenu",
                                action: "open",
                                successMessage: "Great! You've opened the main menu",
                                failureMessage: "Try clicking the menu button in the top-left corner"
                            )
                        ],
                        hints: [
                            "The main menu is located in the top-left corner",
                            "You can access different views from the main menu"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "mainMenu",
                                value: "open",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    ),
                    TutorialStep(
                        title: "Create Your First Project",
                        description: "Learn how to create a new project in DiveDaw",
                        instructions: [
                            "Click on 'File' in the top menu",
                            "Select 'New Project'",
                            "Choose a template for your project",
                            "Name your project and select a save location"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .menu,
                                target: "fileMenu",
                                action: "click",
                                successMessage: "You've opened the file menu!",
                                failureMessage: "Click on 'File' in the top menu bar"
                            ),
                            InteractiveElement(
                                type: .menuItem,
                                target: "newProject",
                                action: "select",
                                successMessage: "Great! Now you can create a new project",
                                failureMessage: "Select 'New Project' from the file menu"
                            )
                        ],
                        hints: [
                            "The File menu is in the top-left of the application",
                            "Templates help you get started quickly with common project types",
                            "Give your project a descriptive name"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .projectCreation,
                                target: "newProject",
                                value: "created",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    ),
                    TutorialStep(
                        title: "Adding Tracks",
                        description: "Learn how to add audio and MIDI tracks to your project",
                        instructions: [
                            "Right-click in the tracks area",
                            "Select 'Add Audio Track' or 'Add MIDI Track'",
                            "Configure the track settings if prompted",
                            "Observe the new track in your project"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .contextMenu,
                                target: "tracksArea",
                                action: "rightClick",
                                successMessage: "You've opened the tracks context menu",
                                failureMessage: "Try right-clicking in the empty tracks area"
                            ),
                            InteractiveElement(
                                type: .menuItem,
                                target: "addTrack",
                                action: "select",
                                successMessage: "You've selected to add a track!",
                                failureMessage: "Select either 'Add Audio Track' or 'Add MIDI Track'"
                            )
                        ],
                        hints: [
                            "Audio tracks are for recorded sounds or imported audio files",
                            "MIDI tracks are for virtual instruments and sequenced notes",
                            "You can add multiple tracks of different types"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .trackCreation,
                                target: "projectTracks",
                                value: "1",
                                comparison: .greaterThan
                            )
                        ],
                        isCompleted: false
                    ),
                    TutorialStep(
                        title: "Recording Your First Audio",
                        description: "Learn how to record audio into your project",
                        instructions: [
                            "Select an audio track",
                            "Arm the track for recording by clicking the record button",
                            "Click the main transport record button",
                            "Make some noise or play an instrument",
                            "Click stop when finished"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "trackRecordArm",
                                action: "click",
                                successMessage: "Track armed for recording!",
                                failureMessage: "Click the record button on the audio track"
                            ),
                            InteractiveElement(
                                type: .button,
                                target: "transportRecord",
                                action: "click",
                                successMessage: "Recording started!",
                                failureMessage: "Click the record button in the transport controls"
                            )
                        ],
                        hints: [
                            "Make sure your microphone or audio interface is connected",
                            "You can monitor your input levels in the mixer",
                            "Press space bar to stop recording"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .recordingComplete,
                                target: "audioTrack",
                                value: "hasContent",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 15 * 60, // 15 minutes
                prerequisites: [],
                tags: ["beginner", "interface", "navigation"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Mixing Basics",
                description: "Learn the fundamentals of mixing your tracks",
                steps: [
                    TutorialStep(
                        title: "Understanding the Mixer",
                        description: "Get familiar with the mixer interface",
                        instructions: [
                            "Open the mixer view",
                            "Identify channel strips for each track",
                            "Locate volume faders, pan controls, and effect slots"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "mixerViewButton",
                                action: "click",
                                successMessage: "Mixer view opened!",
                                failureMessage: "Click the mixer button in the main toolbar"
                            )
                        ],
                        hints: [
                            "The mixer gives you control over the volume and effects of each track",
                            "Each vertical strip represents one track in your project"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "mixerViewButton",
                                value: "clicked",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 20 * 60, // 20 minutes
                prerequisites: ["Getting Started"],
                tags: ["intermediate", "mixing", "audio"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Songwriting Essentials",
                description: "Learn how to compose songs using the DAW",
                steps: [
                    TutorialStep(
                        title: "Creating a Chord Progression",
                        description: "Build the harmonic foundation of your song",
                        instructions: [
                            "Create a new MIDI track",
                            "Open the chord tool",
                            "Place chords on the timeline"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "newMidiTrackButton",
                                action: "click",
                                successMessage: "New MIDI track created!",
                                failureMessage: "Click the 'Add MIDI Track' button"
                            )
                        ],
                        hints: [
                            "Common chord progressions include I-IV-V and ii-V-I",
                            "Try different chord voicings to find what sounds best"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "midiTrack",
                                value: "hasChords",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 25 * 60, // 25 minutes
                prerequisites: ["Getting Started"],
                tags: ["beginner", "composition", "songwriting"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Beat Making 101",
                description: "Create your first drum beat from scratch",
                steps: [
                    TutorialStep(
                        title: "Setting Up the Drum Kit",
                        description: "Learn to use the drum sampler",
                        instructions: [
                            "Add a drum sampler instrument",
                            "Load a drum kit preset",
                            "Create a basic pattern with kick and snare"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "drumSamplerButton",
                                action: "click",
                                successMessage: "Drum sampler added!",
                                failureMessage: "Click 'Add Instrument' and select 'Drum Sampler'"
                            )
                        ],
                        hints: [
                            "Start with a simple kick on beats 1 and 3, snare on 2 and 4",
                            "Use the step sequencer for precise rhythm programming"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "drumTrack",
                                value: "hasPattern",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 20 * 60, // 20 minutes
                prerequisites: ["Getting Started"],
                tags: ["beginner", "drums", "rhythm"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Advanced MIDI Editing",
                description: "Master MIDI editing techniques for complex compositions",
                steps: [
                    TutorialStep(
                        title: "MIDI Editor Overview",
                        description: "Learn about the advanced MIDI editing tools",
                        instructions: [
                            "Open the MIDI editor for a MIDI track",
                            "Explore the piano roll interface",
                            "Identify note editing tools and velocity controls"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "midiEditorButton",
                                action: "click",
                                successMessage: "MIDI editor opened!",
                                failureMessage: "Double-click on a MIDI clip to open the editor"
                            )
                        ],
                        hints: [
                            "The piano roll shows notes as horizontal bars",
                            "Note velocity is shown by color intensity",
                            "You can edit multiple notes at once by selecting them"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "midiEditorButton",
                                value: "clicked",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 30 * 60, // 30 minutes
                prerequisites: ["Getting Started", "Mixing Basics"],
                tags: ["advanced", "midi", "composition"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Vocal Recording and Processing",
                description: "Learn how to record and process vocals professionally",
                steps: [
                    TutorialStep(
                        title: "Setting Up for Vocal Recording",
                        description: "Prepare your DAW for vocal recording",
                        instructions: [
                            "Create a new audio track for vocals",
                            "Set up input monitoring",
                            "Adjust recording levels"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "newAudioTrackButton",
                                action: "click",
                                successMessage: "New audio track created!",
                                failureMessage: "Click the 'Add Audio Track' button"
                            )
                        ],
                        hints: [
                            "Use headphones to prevent feedback while recording",
                            "Aim for recording levels around -12dB to -6dB"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "audioTrack",
                                value: "isMonitoring",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 35 * 60, // 35 minutes
                prerequisites: ["Getting Started", "Mixing Basics"],
                tags: ["intermediate", "vocals", "recording"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Electronic Music Production",
                description: "Create electronic music from scratch",
                steps: [
                    TutorialStep(
                        title: "Designing Synth Sounds",
                        description: "Learn to create custom synthesizer sounds",
                        instructions: [
                            "Add a synthesizer instrument",
                            "Explore oscillator types",
                            "Adjust filter and envelope settings"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "synthesizerButton",
                                action: "click",
                                successMessage: "Synthesizer added!",
                                failureMessage: "Click 'Add Instrument' and select 'Synthesizer'"
                            )
                        ],
                        hints: [
                            "Start with a simple waveform like sine or saw",
                            "Use the filter to shape the tone of your sound",
                            "Envelopes control how your sound evolves over time"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "synthTrack",
                                value: "hasCustomPatch",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 40 * 60, // 40 minutes
                prerequisites: ["Getting Started", "Mixing Basics"],
                tags: ["intermediate", "synthesis", "electronic"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Mastering Your Project",
                description: "Learn professional mastering techniques for your final mix",
                steps: [
                    TutorialStep(
                        title: "Setting Up a Mastering Chain",
                        description: "Create a professional mastering chain for your project",
                        instructions: [
                            "Add an EQ to the master channel",
                            "Insert a compressor after the EQ",
                            "Add a limiter as the final processor"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "addMasterEQ",
                                action: "click",
                                successMessage: "EQ added to master channel!",
                                failureMessage: "Click the '+' button on the master channel and select EQ"
                            )
                        ],
                        hints: [
                            "Mastering is the final step before releasing your music",
                            "A typical mastering chain includes EQ, compression, and limiting",
                            "Subtle adjustments often work best in mastering"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "masterChannel",
                                value: "hasEQ",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 45 * 60, // 45 minutes
                prerequisites: ["Getting Started", "Mixing Basics"],
                tags: ["expert", "mastering", "finishing"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Film Scoring Fundamentals",
                description: "Learn how to compose music for visual media",
                steps: [
                    TutorialStep(
                        title: "Importing Video",
                        description: "Set up your project for scoring to picture",
                        instructions: [
                            "Import a video file",
                            "Set up markers for key scenes",
                            "Create a tempo map that fits the video"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "importVideoButton",
                                action: "click",
                                successMessage: "Video import dialog opened!",
                                failureMessage: "Click 'Import Video' in the File menu"
                            )
                        ],
                        hints: [
                            "Use hit points to align music with important visual moments",
                            "Consider the emotional tone of each scene when composing"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "project",
                                value: "hasVideo",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 50 * 60, // 50 minutes
                prerequisites: ["Getting Started", "Mixing Basics", "Advanced MIDI Editing"],
                tags: ["expert", "film scoring", "composition"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Live Performance Setup",
                description: "Configure your DAW for live performance",
                steps: [
                    TutorialStep(
                        title: "Creating Performance Scenes",
                        description: "Set up scenes for live triggering",
                        instructions: [
                            "Open the performance view",
                            "Create scene triggers for different song sections",
                            "Assign MIDI controllers to key parameters"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "performanceViewButton",
                                action: "click",
                                successMessage: "Performance view opened!",
                                failureMessage: "Click the 'Performance' tab in the main toolbar"
                            )
                        ],
                        hints: [
                            "Scenes let you trigger multiple clips simultaneously",
                            "Map hardware controls to frequently adjusted parameters",
                            "Test your setup thoroughly before performing live"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "performanceViewButton",
                                value: "clicked",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 40 * 60, // 40 minutes
                prerequisites: ["Getting Started", "Mixing Basics"],
                tags: ["advanced", "live performance", "controllers"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Accessibility Features for Music Production",
                description: "Learn how to use the DAW's accessibility features",
                steps: [
                    TutorialStep(
                        title: "Setting Up Screen Reader Support",
                        description: "Configure the DAW for screen reader compatibility",
                        instructions: [
                            "Open accessibility settings",
                            "Enable screen reader support",
                            "Learn keyboard shortcuts for navigation"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "accessibilitySettingsButton",
                                action: "click",
                                successMessage: "Accessibility settings opened!",
                                failureMessage: "Click 'Accessibility' in the preferences menu"
                            )
                        ],
                        hints: [
                            "Keyboard shortcuts can speed up your workflow significantly",
                            "Custom color schemes can help with visual impairments"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "settings",
                                value: "screenReaderEnabled",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 25 * 60, // 25 minutes
                prerequisites: [],
                tags: ["accessibility", "beginner", "setup"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Podcast Production",
                description: "Learn how to record and edit podcasts",
                steps: [
                    TutorialStep(
                        title: "Setting Up for Voice Recording",
                        description: "Configure your DAW for podcast recording",
                        instructions: [
                            "Create a new podcast template",
                            "Set up multiple microphone inputs",
                            "Configure recording levels for speech"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "podcastTemplateButton",
                                action: "click",
                                successMessage: "Podcast template loaded!",
                                failureMessage: "Click 'New Project' and select 'Podcast Template'"
                            )
                        ],
                        hints: [
                            "Use a high-pass filter to reduce low-frequency rumble",
                            "Record each speaker on a separate track for easier editing"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "podcastTemplateButton",
                                value: "clicked",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 30 * 60, // 30 minutes
                prerequisites: ["Getting Started"],
                tags: ["podcast", "voice", "recording"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Sound Design for Games",
                description: "Create and implement sound effects for games",
                steps: [
                    TutorialStep(
                        title: "Creating Impact Sounds",
                        description: "Design sound effects for impacts and collisions",
                        instructions: [
                            "Create a new sound design project",
                            "Record or import source materials",
                            "Layer and process sounds for impact effects"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "soundDesignTemplateButton",
                                action: "click",
                                successMessage: "Sound design template loaded!",
                                failureMessage: "Click 'New Project' and select 'Sound Design Template'"
                            )
                        ],
                        hints: [
                            "Combine multiple sounds for richer impacts",
                            "Use pitch shifting to create variations from a single sound"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "soundDesignTemplateButton",
                                value: "clicked",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 45 * 60, // 45 minutes
                prerequisites: ["Getting Started", "Mixing Basics"],
                tags: ["sound design", "games", "sfx"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Music Theory for Producers",
                description: "Learn essential music theory concepts for production",
                steps: [
                    TutorialStep(
                        title: "Understanding Scales and Modes",
                        description: "Learn how scales and modes work in your productions",
                        instructions: [
                            "Open the scale tool",
                            "Explore different scales and modes",
                            "Apply scale highlighting to the piano roll"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "scaleToolButton",
                                action: "click",
                                successMessage: "Scale tool opened!",
                                failureMessage: "Click the 'Scale' button in the MIDI editor"
                            )
                        ],
                        hints: [
                            "Major and minor scales are the foundation of Western music",
                            "Modes offer different emotional colors using the same notes"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "scaleToolButton",
                                value: "clicked",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 35 * 60, // 35 minutes
                prerequisites: ["Getting Started", "Songwriting Essentials"],
                tags: ["music theory", "composition", "intermediate"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Orchestral Arrangement",
                description: "Learn to create realistic orchestral arrangements",
                steps: [
                    TutorialStep(
                        title: "Setting Up Orchestra Sections",
                        description: "Organize your project for orchestral composition",
                        instructions: [
                            "Create track folders for each orchestra section",
                            "Load orchestral instrument libraries",
                            "Set up expression maps for articulations"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "createFolderButton",
                                action: "click",
                                successMessage: "New folder created!",
                                failureMessage: "Right-click in the track list and select 'Create Folder'"
                            )
                        ],
                        hints: [
                            "Organize by standard sections: strings, brass, woodwinds, percussion",
                            "Consider the natural ranges of each instrument"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "project",
                                value: "hasFolders",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 60 * 60, // 60 minutes
                prerequisites: ["Getting Started", "Advanced MIDI Editing", "Music Theory for Producers"],
                tags: ["orchestral", "composition", "advanced"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Jazz Production Techniques",
                description: "Learn specialized techniques for jazz recording and production",
                steps: [
                    TutorialStep(
                        title: "Recording a Jazz Ensemble",
                        description: "Set up for recording a live jazz group",
                        instructions: [
                            "Configure multiple input channels",
                            "Set up a click track with count-in",
                            "Create monitor mixes for musicians"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "inputConfigButton",
                                action: "click",
                                successMessage: "Input configuration opened!",
                                failureMessage: "Click 'Audio Setup' in the preferences menu"
                            )
                        ],
                        hints: [
                            "Consider room acoustics when placing microphones",
                            "Minimal processing often works best for jazz recordings"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .buttonClick,
                                target: "inputConfigButton",
                                value: "clicked",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 45 * 60, // 45 minutes
                prerequisites: ["Getting Started", "Mixing Basics", "Vocal Recording and Processing"],
                tags: ["jazz", "recording", "advanced"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Remote Collaboration",
                description: "Learn how to collaborate with musicians remotely",
                steps: [
                    TutorialStep(
                        title: "Setting Up Cloud Collaboration",
                        description: "Configure your project for remote collaboration",
                        instructions: [
                            "Enable cloud collaboration features",
                            "Invite collaborators to your project",
                            "Set up track sharing permissions"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "cloudCollabButton",
                                action: "click",
                                successMessage: "Cloud collaboration enabled!",
                                failureMessage: "Click 'Enable Collaboration' in the File menu"
                            )
                        ],
                        hints: [
                            "Freeze CPU-intensive tracks before sharing",
                            "Use comments to communicate ideas with collaborators"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "project",
                                value: "collaborationEnabled",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 30 * 60, // 30 minutes
                prerequisites: ["Getting Started"],
                tags: ["collaboration", "workflow", "intermediate"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Hip-Hop Production",
                description: "Create modern hip-hop beats and arrangements",
                steps: [
                    TutorialStep(
                        title: "Sampling Techniques",
                        description: "Learn how to sample and flip records",
                        instructions: [
                            "Import a sample into your project",
                            "Use warping to match the sample tempo",
                            "Chop and rearrange sample parts"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "importSampleButton",
                                action: "click",
                                successMessage: "Sample import dialog opened!",
                                failureMessage: "Click 'Import Audio' in the File menu"
                            )
                        ],
                        hints: [
                            "Look for interesting breaks or melodic sections to sample",
                            "Use filters and EQ to isolate parts of the sample"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "project",
                                value: "hasSample",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 40 * 60, // 40 minutes
                prerequisites: ["Getting Started", "Beat Making 101"],
                tags: ["hip-hop", "sampling", "beats"],
                isCompleted: false
            ),
            Tutorial(
                id: UUID(),
                title: "Spatial Audio Production",
                description: "Create immersive audio experiences with spatial audio",
                steps: [
                    TutorialStep(
                        title: "Setting Up for Binaural Audio",
                        description: "Configure your project for 3D audio production",
                        instructions: [
                            "Enable spatial audio processing",
                            "Set up a binaural monitoring environment",
                            "Position sounds in the 3D field"
                        ],
                        interactiveElements: [
                            InteractiveElement(
                                type: .button,
                                target: "spatialAudioButton",
                                action: "click",
                                successMessage: "Spatial audio enabled!",
                                failureMessage: "Click 'Enable Spatial Audio' in the Project menu"
                            )
                        ],
                        hints: [
                            "Headphones are recommended for monitoring binaural audio",
                            "Consider both horizontal and vertical positioning"
                        ],
                        completionCriteria: [
                            CompletionCriterion(
                                type: .valueChange,
                                target: "project",
                                value: "spatialAudioEnabled",
                                comparison: .equals
                            )
                        ],
                        isCompleted: false
                    )
                ],
                estimatedDuration: 50 * 60, // 50 minutes
                prerequisites: ["Getting Started", "Mixing Basics", "Advanced MIDI Editing"],
                tags: ["spatial audio", "immersive", "expert"],
                isCompleted: false
            )
        ]
    }
    
    func startTutorial(_ tutorial: Tutorial) {
        currentTutorial = tutorial
        currentStep = 0
        isTutorialActive = true
    }
    
    func nextStep() {
        guard let tutorial = currentTutorial else { return }
        if currentStep < tutorial.steps.count - 1 {
            currentStep += 1
        } else {
            completeTutorial(tutorial)
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func completeStep(_ step: TutorialStep) {
        guard var tutorial = currentTutorial else { return }
        if let stepIndex = tutorial.steps.firstIndex(where: { $0.id == step.id }) {
            tutorial.steps[stepIndex].isCompleted = true
            updateTutorial(tutorial)
        }
    }
    
    func completeTutorial(_ tutorial: Tutorial) {
        guard var tutorial = tutorials.first(where: { $0.id == tutorial.id }) else { return }
        tutorial.isCompleted = true
        updateTutorial(tutorial)
        isTutorialActive = false
        currentTutorial = nil
        currentStep = 0
    }
    
    func checkCompletionCriteria(for step: TutorialStep) -> Bool {
        for criterion in step.completionCriteria {
            switch criterion.type {
            case .buttonClick:
                // Check if button was clicked
                break
            case .valueChange:
                // Check if value was changed
                break
            case .fileImport:
                // Check if file was imported
                break
            case .audioRecord:
                // Check if audio was recorded
                break
            case .midiRecord:
                // Check if MIDI was recorded
                break
            case .effectAdd:
                // Check if effect was added
                break
            case .automationCreate:
                // Check if automation was created
                break
            case .exportComplete:
                // Check if export was completed
                break
            }
        }
        return true
    }
    
    func getProgress(for tutorial: Tutorial) -> Double {
        let completedSteps = tutorial.steps.filter { $0.isCompleted }.count
        return Double(completedSteps) / Double(tutorial.steps.count)
    }
    
    func filterTutorials(by category: TutorialCategory? = nil,
                        difficulty: TutorialDifficulty? = nil,
                        searchText: String = "") -> [Tutorial] {
        var filtered = tutorials
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let difficulty = difficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        return filtered
    }
    
    private func updateTutorial(_ tutorial: Tutorial) {
        if let index = tutorials.firstIndex(where: { $0.id == tutorial.id }) {
            tutorials[index] = tutorial
        }
    }
} 