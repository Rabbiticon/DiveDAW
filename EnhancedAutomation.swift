import Foundation
import AudioKit

class EnhancedAutomation: ObservableObject {
    @Published var automationLanes: [AutomationLane] = []
    @Published var currentLane: AutomationLane?
    @Published var currentTool: AutomationTool = .pencil
    @Published var currentCurve: AutomationCurve = .linear
    @Published var currentQuantization: Quantization = .none
    @Published var currentSnap: SnapMode = .grid
    @Published var currentGridSize: GridSize = .sixteenth
    @Published var currentZoom: Double = 1.0
    @Published var currentTimeSignature: TimeSignature = .fourFour
    @Published var currentTempo: Double = 120.0
    
    struct AutomationLane: Identifiable {
        let id = UUID()
        var name: String
        var parameter: AutomationParameter
        var points: [AutomationPoint]
        var color: Color
        var visible: Bool
        var locked: Bool
        var recording: Bool
        var loop: Bool
        var loopStart: TimeInterval
        var loopEnd: TimeInterval
    }
    
    struct AutomationPoint: Identifiable {
        let id = UUID()
        var time: TimeInterval
        var value: Double
        var curve: AutomationCurve
        var selected: Bool
        var locked: Bool
    }
    
    enum AutomationParameter: String, CaseIterable {
        case volume
        case pan
        case pitch
        case filterCutoff
        case filterResonance
        case reverbMix
        case delayTime
        case delayFeedback
        case distortionAmount
        case compressionThreshold
        case compressionRatio
        case compressionAttack
        case compressionRelease
        case lfoRate
        case lfoAmount
        case envelopeAttack
        case envelopeDecay
        case envelopeSustain
        case envelopeRelease
    }
    
    enum AutomationTool: String, CaseIterable {
        case pencil
        case line
        case curve
        case erase
        case select
        case move
        case resize
    }
    
    enum AutomationCurve: String, CaseIterable {
        case linear
        case exponential
        case logarithmic
        case bezier
        case step
        case sine
        case cosine
        case smooth
    }
    
    enum Quantization: Double, CaseIterable {
        case none = 0.0
        case eighth = 0.5
        case quarter = 1.0
        case half = 2.0
        case oneBar = 4.0
        case twoBars = 8.0
        case fourBars = 16.0
    }
    
    enum SnapMode: String, CaseIterable {
        case grid
        case line
        case none
    }
    
    enum GridSize: Double, CaseIterable {
        case whole = 4.0
        case half = 2.0
        case quarter = 1.0
        case eighth = 0.5
        case sixteenth = 0.25
        case thirtySecond = 0.125
        case sixtyFourth = 0.0625
    }
    
    enum TimeSignature: String, CaseIterable {
        case twoTwo = "2/2"
        case twoFour = "2/4"
        case threeFour = "3/4"
        case fourFour = "4/4"
        case fiveFour = "5/4"
        case sixFour = "6/4"
        case sevenFour = "7/4"
        case threeEight = "3/8"
        case sixEight = "6/8"
        case nineEight = "9/8"
        case twelveEight = "12/8"
    }
    
    enum Color: String, CaseIterable {
        case red
        case orange
        case yellow
        case green
        case blue
        case purple
        case pink
        case gray
    }
    
    func createLane(name: String, parameter: AutomationParameter) -> AutomationLane {
        let lane = AutomationLane(
            name: name,
            parameter: parameter,
            points: [],
            color: .blue,
            visible: true,
            locked: false,
            recording: false,
            loop: false,
            loopStart: 0.0,
            loopEnd: 4.0
        )
        automationLanes.append(lane)
        return lane
    }
    
    func addPoint(to lane: AutomationLane, at time: TimeInterval, value: Double) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        let point = AutomationPoint(
            time: time,
            value: value,
            curve: currentCurve,
            selected: false,
            locked: false
        )
        lane.points.append(point)
        updateLane(lane)
    }
    
    func removePoint(_ point: AutomationPoint, from lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        lane.points.removeAll { $0.id == point.id }
        updateLane(lane)
    }
    
    func updatePoint(_ point: AutomationPoint, in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        if let index = lane.points.firstIndex(where: { $0.id == point.id }) {
            lane.points[index] = point
            updateLane(lane)
        }
    }
    
    func selectPoint(_ point: AutomationPoint, in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        if let index = lane.points.firstIndex(where: { $0.id == point.id }) {
            lane.points[index].selected = true
            updateLane(lane)
        }
    }
    
    func deselectPoint(_ point: AutomationPoint, in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        if let index = lane.points.firstIndex(where: { $0.id == point.id }) {
            lane.points[index].selected = false
            updateLane(lane)
        }
    }
    
    func clearSelection(in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        for index in lane.points.indices {
            lane.points[index].selected = false
        }
        updateLane(lane)
    }
    
    func quantizePoints(in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        for index in lane.points.indices {
            let point = lane.points[index]
            let quantizedTime = quantizeTime(point.time)
            lane.points[index].time = quantizedTime
        }
        updateLane(lane)
    }
    
    func quantizeTime(_ time: TimeInterval) -> TimeInterval {
        let beat = time * currentTempo / 60.0
        let quantizedBeat = round(beat / currentQuantization.rawValue) * currentQuantization.rawValue
        return quantizedBeat * 60.0 / currentTempo
    }
    
    func drawCurve(in lane: AutomationLane, from startTime: TimeInterval, to endTime: TimeInterval, with curve: AutomationCurve) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        let points = generateCurvePoints(from: startTime, to: endTime, with: curve)
        lane.points.append(contentsOf: points)
        updateLane(lane)
    }
    
    func generateCurvePoints(from startTime: TimeInterval, to endTime: TimeInterval, with curve: AutomationCurve) -> [AutomationPoint] {
        var points: [AutomationPoint] = []
        let duration = endTime - startTime
        let stepSize = duration / 100.0 // Generate 100 points for smooth curves
        
        for i in 0...100 {
            let time = startTime + (Double(i) * stepSize)
            let normalizedTime = Double(i) / 100.0
            let value = calculateCurveValue(normalizedTime, with: curve)
            
            let point = AutomationPoint(
                time: time,
                value: value,
                curve: curve,
                selected: false,
                locked: false
            )
            points.append(point)
        }
        
        return points
    }
    
    func calculateCurveValue(_ normalizedTime: Double, with curve: AutomationCurve) -> Double {
        switch curve {
        case .linear:
            return normalizedTime
        case .exponential:
            return exp(normalizedTime) - 1.0
        case .logarithmic:
            return log(normalizedTime + 1.0) / log(2.0)
        case .bezier:
            let t = normalizedTime
            let t2 = t * t
            let t3 = t2 * t
            let mt = 1.0 - t
            let mt2 = mt * mt
            let mt3 = mt2 * mt
            return mt3 + 3.0 * mt2 * t + 3.0 * mt * t2 + t3
        case .step:
            return normalizedTime < 0.5 ? 0.0 : 1.0
        case .sine:
            return sin(normalizedTime * .pi * 2.0) * 0.5 + 0.5
        case .cosine:
            return cos(normalizedTime * .pi * 2.0) * 0.5 + 0.5
        case .smooth:
            return normalizedTime * normalizedTime * (3.0 - 2.0 * normalizedTime)
        }
    }
    
    func startRecording(in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        lane.recording = true
        updateLane(lane)
    }
    
    func stopRecording(in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        lane.recording = false
        updateLane(lane)
    }
    
    func setLoopPoints(in lane: AutomationLane, start: TimeInterval, end: TimeInterval) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        lane.loopStart = start
        lane.loopEnd = end
        lane.loop = true
        updateLane(lane)
    }
    
    func disableLoop(in lane: AutomationLane) {
        guard var lane = automationLanes.first(where: { $0.id == lane.id }) else { return }
        lane.loop = false
        updateLane(lane)
    }
    
    private func updateLane(_ lane: AutomationLane) {
        if let index = automationLanes.firstIndex(where: { $0.id == lane.id }) {
            automationLanes[index] = lane
        }
    }
} 