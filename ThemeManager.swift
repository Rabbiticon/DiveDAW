import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    enum Theme: String {
        case light
        case dark
    }
    
    @Published var currentTheme: Theme = .light {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    struct Colors {
        // Background colors
        static let backgroundPrimary = Color("BackgroundPrimary")
        static let backgroundSecondary = Color("BackgroundSecondary")
        static let backgroundTertiary = Color("BackgroundTertiary")
        
        // Text colors
        static let textPrimary = Color("TextPrimary")
        static let textSecondary = Color("TextSecondary")
        static let textTertiary = Color("TextTertiary")
        
        // Accent colors
        static let accentPrimary = Color("AccentPrimary")
        static let accentSecondary = Color("AccentSecondary")
        
        // UI Element colors
        static let border = Color("Border")
        static let shadow = Color("Shadow")
        
        // Visualization colors
        static let waveformBackground = Color("WaveformBackground")
        static let waveformForeground = Color("WaveformForeground")
        static let spectrumAnalyzer = Color("SpectrumAnalyzer")
        
        // Status colors
        static let success = Color("Success")
        static let warning = Color("Warning")
        static let error = Color("Error")
    }
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = Theme(rawValue: savedTheme) {
            currentTheme = theme
        }
    }
    
    func toggleTheme() {
        currentTheme = currentTheme == .light ? .dark : .light
    }
    
    func isDarkMode() -> Bool {
        return currentTheme == .dark
    }
    
    // Color scheme modifiers
    var backgroundGradient: LinearGradient {
        switch currentTheme {
        case .light:
            return LinearGradient(
                colors: [Colors.backgroundPrimary, Colors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
        case .dark:
            return LinearGradient(
                colors: [Color(hex: "1A1A1A"), Color(hex: "2D2D2D")],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    var shadowColor: Color {
        switch currentTheme {
        case .light:
            return Color.black.opacity(0.1)
        case .dark:
            return Color.black.opacity(0.3)
        }
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}