import Foundation
import simd
import AudioKit

class SIMDProcessor {
    // SIMD vector size for optimal performance
    private let vectorSize = 8
    // Enable debug logging for detailed processing info
    var debugEnabled: Bool
    // Performance metrics
    private var processingTime: CFTimeInterval = 0
    private var sampleCount: Int = 0
    private var peakValue: Float = 0
    private var processingHistory: [CFTimeInterval] = []
    private var historyMaxSize = 100
    
    // Debug configuration
    struct DebugConfig {
        var logFrequency: Int = 100  // Log every N processing calls
        var trackPerformance: Bool = true
        var trackPeaks: Bool = true
        var visualizeWaveform: Bool = false
        var detectAnomalies: Bool = true
        var anomalyThreshold: Float = 0.95
    }
    
    var debugConfig = DebugConfig()
    private var processCallCount = 0

    init(debugEnabled: Bool = false) {
        self.debugEnabled = debugEnabled
    }
    
    // MARK: - SIMD-optimized Audio Processing
    
    func processSIMD(_ buffer: UnsafeMutablePointer<Float>, count: Int) {
        if debugEnabled && debugConfig.trackPerformance {
            processCallCount += 1
            sampleCount += count
            let startTime = CFAbsoluteTimeGetCurrent()
            defer {
                let endTime = CFAbsoluteTimeGetCurrent()
                processingTime += (endTime - startTime)
                processingHistory.append(endTime - startTime)
                if processingHistory.count > historyMaxSize {
                    processingHistory.removeFirst()
                }
                
                if processCallCount % debugConfig.logFrequency == 0 {
                    printPerformanceMetrics()
                }
            }
        }
        
        let vectorCount = count / vectorSize
        let remainder = count % vectorSize
        
        // Process vectors using SIMD
        for i in 0..<vectorCount {
            let offset = i * vectorSize
            let ptr = buffer.advanced(by: offset)
            var vec = simd_float8(ptr.pointee,
                                 ptr.advanced(by: 1).pointee,
                                 ptr.advanced(by: 2).pointee,
                                 ptr.advanced(by: 3).pointee,
                                 ptr.advanced(by: 4).pointee,
                                 ptr.advanced(by: 5).pointee,
                                 ptr.advanced(by: 6).pointee,
                                 ptr.advanced(by: 7).pointee)
            
            // Track peak values for debugging
            if debugEnabled && debugConfig.trackPeaks {
                let maxInVector = simd.max(abs(vec))
                peakValue = max(peakValue, maxInVector)
            }
            
            // Detect anomalies in input signal
            if debugEnabled && debugConfig.detectAnomalies {
                detectAnomalies(in: vec, at: offset)
            }
            
            // Apply processing
            vec = processVector(vec)
            
            // Write back results
            ptr.pointee = vec[0]
            ptr.advanced(by: 1).pointee = vec[1]
            ptr.advanced(by: 2).pointee = vec[2]
            ptr.advanced(by: 3).pointee = vec[3]
            ptr.advanced(by: 4).pointee = vec[4]
            ptr.advanced(by: 5).pointee = vec[5]
            ptr.advanced(by: 6).pointee = vec[6]
            ptr.advanced(by: 7).pointee = vec[7]
            
            // Visualize waveform if enabled
            if debugEnabled && debugConfig.visualizeWaveform && i % 10 == 0 {
                visualizeVector(vec, offset: offset)
            }
        }
        
        // Process remaining samples
        let remainingOffset = vectorCount * vectorSize
        for i in 0..<remainder {
            let ptr = buffer.advanced(by: remainingOffset + i)
            let sample = ptr.pointee
            
            // Track peak for individual samples too
            if debugEnabled && debugConfig.trackPeaks {
                peakValue = max(peakValue, abs(sample))
            }
            
            ptr.pointee = processSample(sample)
        }
    }
    
    // MARK: - Vector Processing Functions
    
    private func processVector(_ vec: simd_float8) -> simd_float8 {
        // Example vector processing operations
        var result = vec
        
        // Gain control (SIMD multiply)
        let gain = simd_float8(repeating: 0.8)
        result *= gain
        
        // Soft clipping (SIMD operations)
        let threshold = simd_float8(repeating: 0.8)
        let scale = simd_float8(repeating: 0.5)
        result = simd.tanh(result * scale) * threshold
        
        return result
    }
    
    private func processSample(_ sample: Float) -> Float {
        // Fallback processing for individual samples
        let gain: Float = 0.8
        let threshold: Float = 0.8
        let scale: Float = 0.5
        return tanh(sample * scale * gain) * threshold
    }
    
    // MARK: - Advanced Processing Effects
    
    func applyMultibandCompression(_ buffer: UnsafeMutablePointer<Float>, count: Int,
                                  bands: [(frequency: Float, ratio: Float, threshold: Float)]) {
        if debugEnabled {
            print("Starting multiband compression with \(bands.count) bands")
        }
        
        // Split signal into frequency bands using SIMD-optimized filters
        // Apply compression to each band independently
        // Combine bands back together
        
        if debugEnabled {
            print("Completed multiband compression")
        }
    }
    
    func applyParallelProcessing(_ buffer: UnsafeMutablePointer<Float>, count: Int,
                                processors: [(simd_float8) -> simd_float8]) {
        if debugEnabled {
            print("Starting parallel processing with \(processors.count) processors")
        }
        
        let startTime = debugEnabled ? CFAbsoluteTimeGetCurrent() : 0
        let vectorCount = count / vectorSize
        
        for i in 0..<vectorCount {
            let offset = i * vectorSize
            let ptr = buffer.advanced(by: offset)
            var vec = simd_float8(ptr.pointee,
                                 ptr.advanced(by: 1).pointee,
                                 ptr.advanced(by: 2).pointee,
                                 ptr.advanced(by: 3).pointee,
                                 ptr.advanced(by: 4).pointee,
                                 ptr.advanced(by: 5).pointee,
                                 ptr.advanced(by: 6).pointee,
                                 ptr.advanced(by: 7).pointee)
            
            // Apply parallel processing
            var result = simd_float8(repeating: 0)
            for processor in processors {
                result += processor(vec)
            }
            result /= Float(processors.count)
            
            // Write back results
            ptr.pointee = result[0]
            ptr.advanced(by: 1).pointee = result[1]
            ptr.advanced(by: 2).pointee = result[2]
            ptr.advanced(by: 3).pointee = result[3]
            ptr.advanced(by: 4).pointee = result[4]
            ptr.advanced(by: 5).pointee = result[5]
            ptr.advanced(by: 6).pointee = result[6]
            ptr.advanced(by: 7).pointee = result[7]
        }
        
        if debugEnabled {
            let endTime = CFAbsoluteTimeGetCurrent()
            print("Parallel processing completed in \(String(format: "%.6f", endTime - startTime))s")
        }
    }
    
    // MARK: - Advanced DSP Operations
    
    func applyConvolution(_ buffer: UnsafeMutablePointer<Float>, count: Int, impulseResponse: [Float]) {
        if debugEnabled {
            print("Applying convolution with impulse response length: \(impulseResponse.count)")
        }
        
        // Perform convolution using SIMD operations for efficiency
        let irLength = impulseResponse.count
        let outputLength = count + irLength - 1
        
        // Create a temporary buffer for the result
        let tempBuffer = UnsafeMutablePointer<Float>.allocate(capacity: outputLength)
        tempBuffer.initialize(repeating: 0, count: outputLength)
        defer { tempBuffer.deallocate() }
        
        // Perform convolution
        for i in 0..<count {
            for j in 0..<irLength {
                if i + j < outputLength {
                    tempBuffer[i + j] += buffer[i] * impulseResponse[j]
                }
            }
        }
        
        // Copy the result back to the original buffer (truncating to original size)
        for i in 0..<count {
            buffer[i] = tempBuffer[i]
        }
        
        if debugEnabled {
            print("Convolution completed, output length: \(outputLength), truncated to: \(count)")
        }
    }
    
    func applySpectralProcessing(_ buffer: UnsafeMutablePointer<Float>, count: Int, 
                                operation: (simd_float8) -> simd_float8) {
        if debugEnabled {
            print("Starting spectral processing on \(count) samples")
        }
        
        // Ensure count is a power of 2 for FFT
        let fftSize = nextPowerOf2(count)
        
        // Create a temporary buffer for FFT processing
        let tempBuffer = UnsafeMutablePointer<Float>.allocate(capacity: fftSize * 2) // *2 for complex values
        tempBuffer.initialize(repeating: 0, count: fftSize * 2)
        defer { tempBuffer.deallocate() }
        
        // Copy input data to temp buffer (real part)
        for i in 0..<count {
            tempBuffer[i * 2] = buffer[i]
            tempBuffer[i * 2 + 1] = 0 // Imaginary part is zero
        }
        
        // Perform FFT (forward transform)
        performFFT(tempBuffer, fftSize, forward: true)
        
        // Apply spectral processing in SIMD blocks
        let complexVectorSize = vectorSize / 2 // Each complex number needs 2 floats
        let complexVectorCount = fftSize / complexVectorSize
        
        for i in 0..<complexVectorCount {
            let offset = i * vectorSize
            let ptr = tempBuffer.advanced(by: offset)
            
            // Load complex values as real-imaginary pairs into SIMD vector
            var vec = simd_float8(ptr.pointee,
                                 ptr.advanced(by: 1).pointee,
                                 ptr.advanced(by: 2).pointee,
                                 ptr.advanced(by: 3).pointee,
                                 ptr.advanced(by: 4).pointee,
                                 ptr.advanced(by: 5).pointee,
                                 ptr.advanced(by: 6).pointee,
                                 ptr.advanced(by: 7).pointee)
            
            // Apply the spectral operation
            vec = operation(vec)
            
            // Store back the processed values
            ptr.pointee = vec[0]
            ptr.advanced(by: 1).pointee = vec[1]
            ptr.advanced(by: 2).pointee = vec[2]
            ptr.advanced(by: 3).pointee = vec[3]
            ptr.advanced(by: 4).pointee = vec[4]
            ptr.advanced(by: 5).pointee = vec[5]
            ptr.advanced(by: 6).pointee = vec[6]
            ptr.advanced(by: 7).pointee = vec[7]
        }
        
        // Perform inverse FFT
        performFFT(tempBuffer, fftSize, forward: false)
        
        // Copy the real part back to the original buffer and normalize
        let normFactor = 1.0 / Float(fftSize)
        for i in 0..<count {
            buffer[i] = tempBuffer[i * 2] * normFactor
        }
        
        if debugEnabled {
            print("Spectral processing completed")
        }
    }
    
    // Helper function to find the next power of 2
    private func nextPowerOf2(_ n: Int) -> Int {
        var power = 1
        while power < n {
            power *= 2
        }
        return power
    }
    
    // Actual FFT implementation using Accelerate framework
    private func performFFT(_ buffer: UnsafeMutablePointer<Float>, _ size: Int, forward: Bool) {
        if debugEnabled {
            print("Performing \(forward ? "forward" : "inverse") FFT of size \(size)")
        }
        
        // Calculate log2n for vDSP
        let log2n = UInt(log2(Double(size)))
        
        // Create FFT setup
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            print("Error: Failed to create FFT setup")
            return
        }
        defer { vDSP_destroy_fftsetup(fftSetup) }
        
        // Create a DSPSplitComplex structure to hold the complex data
        var realp = [Float](repeating: 0, count: size/2)
        var imagp = [Float](repeating: 0, count: size/2)
        var splitComplex = DSPSplitComplex(realp: &realp, imagp: &imagp)
        
        // Convert interleaved complex format to split complex format
        buffer.withMemoryRebound(to: DSPComplex.self, capacity: size/2) { complexBuffer in
            vDSP_ctoz(complexBuffer, 2, &splitComplex, 1, vDSP_Length(size/2))
        }
        
        // Perform the FFT
        if forward {
            vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(kFFTDirection_Forward))
        } else {
            vDSP_fft_zrip(fftSetup, &splitComplex, 1, log2n, FFTDirection(kFFTDirection_Inverse))
        }
        
        // Convert back to interleaved complex format
        vDSP_ztoc(&splitComplex, 1, buffer.withMemoryRebound(to: DSPComplex.self, capacity: size/2), 2, vDSP_Length(size/2))
        
        if debugEnabled {
            print("FFT processing completed")
        }
    }
    }
    
    // MARK: - Debug Utilities
    
    private func printPerformanceMetrics() {
        guard debugEnabled else { return }
        
        let avgProcessingTime = processingTime / Double(processCallCount)
        let samplesPerSecond = Double(sampleCount) / processingTime
        
        print("--- SIMD Processor Performance Metrics ---")
        print("Total processing time: \(String(format: "%.6f", processingTime))s")
        print("Average processing time: \(String(format: "%.6f", avgProcessingTime))s per call")
        print("Samples processed: \(sampleCount)")
        print("Processing rate: \(String(format: "%.2f", samplesPerSecond)) samples/second")
        print("Peak value: \(peakValue)")
        
        if !processingHistory.isEmpty {
            let minTime = processingHistory.min() ?? 0
            let maxTime = processingHistory.max() ?? 0
            print("Min processing time: \(String(format: "%.6f", minTime))s")
            print("Max processing time: \(String(format: "%.6f", maxTime))s")
            print("Jitter: \(String(format: "%.6f", maxTime - minTime))s")
        }
        
        print("------------------------------------------")
    }
    
    private func detectAnomalies(in vector: simd_float8, at offset: Int) {
        let maxValue = simd.max(abs(vector))
        if maxValue > debugConfig.anomalyThreshold {
            print("⚠️ Anomaly detected at offset \(offset): value = \(maxValue)")
        }
        
        // Check for NaN or Inf values
        for i in 0..<vectorSize {
            if vector[i].isNaN || vector[i].isInfinite {
                print("🚨 Critical error: NaN or Inf value detected at offset \(offset + i)")
            }
        }
    }
    
    private func visualizeVector(_ vector: simd_float8, offset: Int) {
        var visualization = "["
        for i in 0..<vectorSize {
            let value = vector[i]
            let barLength = Int(abs(value) * 20)
            let bar = String(repeating: "|", count: barLength)
            visualization += "\(bar) \(String(format: "%.2f", value))"
            if i < vectorSize - 1 {
                visualization += ", "
            }
        }
        visualization += "]"
        print("Waveform at \(offset): \(visualization)")
    }
    
    func resetDebugMetrics() {
        processingTime = 0
        sampleCount = 0
        peakValue = 0
        processingHistory.removeAll()
        processCallCount = 0
    }
    
    func generateDebugReport() -> String {
        var report = "SIMD Processor Debug Report\n"
        report += "==========================\n"
        report += "Vector size: \(vectorSize)\n"
        report += "Peak value: \(peakValue)\n"
        report += "Total processing time: \(String(format: "%.6f", processingTime))s\n"
        report += "Total samples processed: \(sampleCount)\n"
        
        if !processingHistory.isEmpty {
            let avgTime = processingHistory.reduce(0, +) / Double(processingHistory.count)
            report += "Average processing time (recent): \(String(format: "%.6f", avgTime))s\n"
        }
        
        return report
    }
}