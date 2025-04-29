import SwiftUI

// Color扩展 - 从十六进制字符串创建颜色
extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red, green, blue, alpha: Double
        
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            red = Double((rgb >> 8) & 0xF) / 15.0
            green = Double((rgb >> 4) & 0xF) / 15.0
            blue = Double(rgb & 0xF) / 15.0
            alpha = 1.0
        case 6: // RGB (24-bit)
            red = Double((rgb >> 16) & 0xFF) / 255.0
            green = Double((rgb >> 8) & 0xFF) / 255.0
            blue = Double(rgb & 0xFF) / 255.0
            alpha = 1.0
        case 8: // ARGB (32-bit)
            alpha = Double((rgb >> 24) & 0xFF) / 255.0
            red = Double((rgb >> 16) & 0xFF) / 255.0
            green = Double((rgb >> 8) & 0xFF) / 255.0
            blue = Double(rgb & 0xFF) / 255.0
        default:
            red = 1.0
            green = 1.0
            blue = 1.0
            alpha = 1.0
        }
        
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
} 