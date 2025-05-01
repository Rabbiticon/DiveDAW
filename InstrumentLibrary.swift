import Foundation
import AudioKit
import DunneAudioKit

class InstrumentLibrary {
    static let shared = InstrumentLibrary()
    
    private init() {}
    
    enum InstrumentType: String, CaseIterable {
        case grandPiano = "Grand Piano"
        case electricPiano = "Electric Piano"
        case synthLead = "Synth Lead"
        case synthPad = "Synth Pad"
        case bass = "Bass"
        case strings = "Strings"
        case brass = "Brass"
        case drums = "Drums"
        case guitar = "Guitar"
        case choir = "Choir"
        case organ = "Organ"
        case marimba = "Marimba"
        case xylophone = "Xylophone"
        case vibraphone = "Vibraphone"
        case celesta = "Celesta"
        case harp = "Harp"
        case flute = "Flute"
        case clarinet = "Clarinet"
        case saxophone = "Saxophone"
        case trumpet = "Trumpet"
        case trombone = "Trombone"
        case frenchHorn = "French Horn"
        case tuba = "Tuba"
        case violin = "Violin"
        case viola = "Viola"
        case cello = "Cello"
        case doubleBass = "Double Bass"
        case electricGuitar = "Electric Guitar"
        case acousticGuitar = "Acoustic Guitar"
        case bassGuitar = "Bass Guitar"
        case drumKit = "Drum Kit"
        case percussion = "Percussion"
        case worldInstruments = "World Instruments"
        case fx = "FX"
    }
    
    func createInstrument(ofType type: InstrumentType) -> VirtualInstrument {
        switch type {
        case .grandPiano:
            return createGrandPiano()
        case .electricPiano:
            return createElectricPiano()
        case .synthLead:
            return createSynthLead()
        case .synthPad:
            return createSynthPad()
        case .bass:
            return createBass()
        case .strings:
            return createStrings()
        case .brass:
            return createBrass()
        case .drums:
            return createDrums()
        case .guitar:
            return createGuitar()
        case .choir:
            return createChoir()
        case .organ:
            return createOrgan()
        case .marimba:
            return createMarimba()
        case .xylophone:
            return createXylophone()
        case .vibraphone:
            return createVibraphone()
        case .celesta:
            return createCelesta()
        case .harp:
            return createHarp()
        case .flute:
            return createFlute()
        case .clarinet:
            return createClarinet()
        case .saxophone:
            return createSaxophone()
        case .trumpet:
            return createTrumpet()
        case .trombone:
            return createTrombone()
        case .frenchHorn:
            return createFrenchHorn()
        case .tuba:
            return createTuba()
        case .violin:
            return createViolin()
        case .viola:
            return createViola()
        case .cello:
            return createCello()
        case .doubleBass:
            return createDoubleBass()
        case .electricGuitar:
            return createElectricGuitar()
        case .acousticGuitar:
            return createAcousticGuitar()
        case .bassGuitar:
            return createBassGuitar()
        case .drumKit:
            return createDrumKit()
        case .percussion:
            return createPercussion()
        case .worldInstruments:
            return createWorldInstruments()
        case .fx:
            return createFX()
        }
    }
    
    private func createGrandPiano() -> VirtualInstrument {
        let piano = Sampler()
        try? piano.loadSFZ(url: Bundle.main.url(forResource: "GrandPiano", withExtension: "sfz")!)
        return VirtualInstrument(name: "Grand Piano", sampler: piano)
    }
    
    private func createElectricPiano() -> VirtualInstrument {
        let epiano = Sampler()
        try? epiano.loadSFZ(url: Bundle.main.url(forResource: "ElectricPiano", withExtension: "sfz")!)
        return VirtualInstrument(name: "Electric Piano", sampler: epiano)
    }
    
    private func createSynthLead() -> VirtualInstrument {
        let synth = Synth()
        synth.attackDuration = 0.1
        synth.decayDuration = 0.3
        synth.sustainLevel = 0.7
        synth.releaseDuration = 0.2
        return VirtualInstrument(name: "Synth Lead", synth: synth)
    }
    
    private func createSynthPad() -> VirtualInstrument {
        let pad = Synth()
        pad.attackDuration = 1.0
        pad.decayDuration = 0.5
        pad.sustainLevel = 0.8
        pad.releaseDuration = 2.0
        return VirtualInstrument(name: "Synth Pad", synth: pad)
    }
    
    private func createBass() -> VirtualInstrument {
        let bass = Sampler()
        try? bass.loadSFZ(url: Bundle.main.url(forResource: "Bass", withExtension: "sfz")!)
        return VirtualInstrument(name: "Bass", sampler: bass)
    }
    
    private func createStrings() -> VirtualInstrument {
        let strings = Sampler()
        try? strings.loadSFZ(url: Bundle.main.url(forResource: "Strings", withExtension: "sfz")!)
        return VirtualInstrument(name: "Strings", sampler: strings)
    }
    
    private func createBrass() -> VirtualInstrument {
        let brass = Sampler()
        try? brass.loadSFZ(url: Bundle.main.url(forResource: "Brass", withExtension: "sfz")!)
        return VirtualInstrument(name: "Brass", sampler: brass)
    }
    
    private func createDrums() -> VirtualInstrument {
        let drums = Sampler()
        try? drums.loadSFZ(url: Bundle.main.url(forResource: "Drums", withExtension: "sfz")!)
        return VirtualInstrument(name: "Drums", sampler: drums)
    }
    
    private func createGuitar() -> VirtualInstrument {
        let guitar = Sampler()
        try? guitar.loadSFZ(url: Bundle.main.url(forResource: "Guitar", withExtension: "sfz")!)
        return VirtualInstrument(name: "Guitar", sampler: guitar)
    }
    
    private func createChoir() -> VirtualInstrument {
        let choir = Sampler()
        try? choir.loadSFZ(url: Bundle.main.url(forResource: "Choir", withExtension: "sfz")!)
        return VirtualInstrument(name: "Choir", sampler: choir)
    }
    
    private func createOrgan() -> VirtualInstrument {
        let organ = Sampler()
        try? organ.loadSFZ(url: Bundle.main.url(forResource: "Organ", withExtension: "sfz")!)
        return VirtualInstrument(name: "Organ", sampler: organ)
    }
    
    private func createMarimba() -> VirtualInstrument {
        let marimba = Sampler()
        try? marimba.loadSFZ(url: Bundle.main.url(forResource: "Marimba", withExtension: "sfz")!)
        return VirtualInstrument(name: "Marimba", sampler: marimba)
    }
    
    private func createXylophone() -> VirtualInstrument {
        let xylophone = Sampler()
        try? xylophone.loadSFZ(url: Bundle.main.url(forResource: "Xylophone", withExtension: "sfz")!)
        return VirtualInstrument(name: "Xylophone", sampler: xylophone)
    }
    
    private func createVibraphone() -> VirtualInstrument {
        let vibraphone = Sampler()
        try? vibraphone.loadSFZ(url: Bundle.main.url(forResource: "Vibraphone", withExtension: "sfz")!)
        return VirtualInstrument(name: "Vibraphone", sampler: vibraphone)
    }
    
    private func createCelesta() -> VirtualInstrument {
        let celesta = Sampler()
        try? celesta.loadSFZ(url: Bundle.main.url(forResource: "Celesta", withExtension: "sfz")!)
        return VirtualInstrument(name: "Celesta", sampler: celesta)
    }
    
    private func createHarp() -> VirtualInstrument {
        let harp = Sampler()
        try? harp.loadSFZ(url: Bundle.main.url(forResource: "Harp", withExtension: "sfz")!)
        return VirtualInstrument(name: "Harp", sampler: harp)
    }
    
    private func createFlute() -> VirtualInstrument {
        let flute = Sampler()
        try? flute.loadSFZ(url: Bundle.main.url(forResource: "Flute", withExtension: "sfz")!)
        return VirtualInstrument(name: "Flute", sampler: flute)
    }
    
    private func createClarinet() -> VirtualInstrument {
        let clarinet = Sampler()
        try? clarinet.loadSFZ(url: Bundle.main.url(forResource: "Clarinet", withExtension: "sfz")!)
        return VirtualInstrument(name: "Clarinet", sampler: clarinet)
    }
    
    private func createSaxophone() -> VirtualInstrument {
        let saxophone = Sampler()
        try? saxophone.loadSFZ(url: Bundle.main.url(forResource: "Saxophone", withExtension: "sfz")!)
        return VirtualInstrument(name: "Saxophone", sampler: saxophone)
    }
    
    private func createTrumpet() -> VirtualInstrument {
        let trumpet = Sampler()
        try? trumpet.loadSFZ(url: Bundle.main.url(forResource: "Trumpet", withExtension: "sfz")!)
        return VirtualInstrument(name: "Trumpet", sampler: trumpet)
    }
    
    private func createTrombone() -> VirtualInstrument {
        let trombone = Sampler()
        try? trombone.loadSFZ(url: Bundle.main.url(forResource: "Trombone", withExtension: "sfz")!)
        return VirtualInstrument(name: "Trombone", sampler: trombone)
    }
    
    private func createFrenchHorn() -> VirtualInstrument {
        let frenchHorn = Sampler()
        try? frenchHorn.loadSFZ(url: Bundle.main.url(forResource: "FrenchHorn", withExtension: "sfz")!)
        return VirtualInstrument(name: "French Horn", sampler: frenchHorn)
    }
    
    private func createTuba() -> VirtualInstrument {
        let tuba = Sampler()
        try? tuba.loadSFZ(url: Bundle.main.url(forResource: "Tuba", withExtension: "sfz")!)
        return VirtualInstrument(name: "Tuba", sampler: tuba)
    }
    
    private func createViolin() -> VirtualInstrument {
        let violin = Sampler()
        try? violin.loadSFZ(url: Bundle.main.url(forResource: "Violin", withExtension: "sfz")!)
        return VirtualInstrument(name: "Violin", sampler: violin)
    }
    
    private func createViola() -> VirtualInstrument {
        let viola = Sampler()
        try? viola.loadSFZ(url: Bundle.main.url(forResource: "Viola", withExtension: "sfz")!)
        return VirtualInstrument(name: "Viola", sampler: viola)
    }
    
    private func createCello() -> VirtualInstrument {
        let cello = Sampler()
        try? cello.loadSFZ(url: Bundle.main.url(forResource: "Cello", withExtension: "sfz")!)
        return VirtualInstrument(name: "Cello", sampler: cello)
    }
    
    private func createDoubleBass() -> VirtualInstrument {
        let doubleBass = Sampler()
        try? doubleBass.loadSFZ(url: Bundle.main.url(forResource: "DoubleBass", withExtension: "sfz")!)
        return VirtualInstrument(name: "Double Bass", sampler: doubleBass)
    }
    
    private func createElectricGuitar() -> VirtualInstrument {
        let electricGuitar = Sampler()
        try? electricGuitar.loadSFZ(url: Bundle.main.url(forResource: "ElectricGuitar", withExtension: "sfz")!)
        return VirtualInstrument(name: "Electric Guitar", sampler: electricGuitar)
    }
    
    private func createAcousticGuitar() -> VirtualInstrument {
        let acousticGuitar = Sampler()
        try? acousticGuitar.loadSFZ(url: Bundle.main.url(forResource: "AcousticGuitar", withExtension: "sfz")!)
        return VirtualInstrument(name: "Acoustic Guitar", sampler: acousticGuitar)
    }
    
    private func createBassGuitar() -> VirtualInstrument {
        let bassGuitar = Sampler()
        try? bassGuitar.loadSFZ(url: Bundle.main.url(forResource: "BassGuitar", withExtension: "sfz")!)
        return VirtualInstrument(name: "Bass Guitar", sampler: bassGuitar)
    }
    
    private func createDrumKit() -> VirtualInstrument {
        let drumKit = Sampler()
        try? drumKit.loadSFZ(url: Bundle.main.url(forResource: "DrumKit", withExtension: "sfz")!)
        return VirtualInstrument(name: "Drum Kit", sampler: drumKit)
    }
    
    private func createPercussion() -> VirtualInstrument {
        let percussion = Sampler()
        try? percussion.loadSFZ(url: Bundle.main.url(forResource: "Percussion", withExtension: "sfz")!)
        return VirtualInstrument(name: "Percussion", sampler: percussion)
    }
    
    private func createWorldInstruments() -> VirtualInstrument {
        let worldInstruments = Sampler()
        try? worldInstruments.loadSFZ(url: Bundle.main.url(forResource: "WorldInstruments", withExtension: "sfz")!)
        return VirtualInstrument(name: "World Instruments", sampler: worldInstruments)
    }
    
    private func createFX() -> VirtualInstrument {
        let fx = Sampler()
        try? fx.loadSFZ(url: Bundle.main.url(forResource: "FX", withExtension: "sfz")!)
        return VirtualInstrument(name: "FX", sampler: fx)
    }
} 