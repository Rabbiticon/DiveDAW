import Foundation
import AudioKit

class Envelope {
    private var adsr: ADSR
    
    var attackDuration: Float = 0.1 {
        didSet {
            updateAttack()
        }
    }
    
    var decayDuration: Float = 0.1 {
        didSet {
            updateDecay()
        }
    }
    
    var sustainLevel: Float = 0.5 {
        didSet {
            updateSustain()
        }
    }
    
    var releaseDuration: Float = 0.1 {
        didSet {
            updateRelease()
        }
    }
    
    init() {
        adsr = ADSR()
        updateParameters()
    }
    
    private func updateAttack() {
        adsr.attackDuration = attackDuration
    }
    
    private func updateDecay() {
        adsr.decayDuration = decayDuration
    }
    
    private func updateSustain() {
        adsr.sustainLevel = sustainLevel
    }
    
    private func updateRelease() {
        adsr.releaseDuration = releaseDuration
    }
    
    private func updateParameters() {
        updateAttack()
        updateDecay()
        updateSustain()
        updateRelease()
    }
    
    func process(input: Node) -> Node {
        adsr.input = input
        return adsr
    }
    
    func start() {
        adsr.start()
    }
    
    func stop() {
        adsr.stop()
    }
    
    func bypass() {
        adsr.bypass()
    }
    
    func enable() {
        adsr.enable()
    }
}