import Foundation

// 摄影参数模型 - Photography Parameters Model
struct ShootingParameters: Identifiable, Codable, Equatable {
    // 为Equatable协议添加的静态方法，用于判断两个ShootingParameters实例是否相等
    static func == (lhs: ShootingParameters, rhs: ShootingParameters) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.date == rhs.date &&
               lhs.notes == rhs.notes &&
               lhs.lightCondition == rhs.lightCondition &&
               lhs.iso == rhs.iso &&
               lhs.sceneMode == rhs.sceneMode &&
               lhs.aperture == rhs.aperture &&
               lhs.shutterSpeed == rhs.shutterSpeed &&
               lhs.meteringMode == rhs.meteringMode &&
               lhs.exposureCompensation == rhs.exposureCompensation
    }
    
    var id = UUID()
    var name: String = "" // 参数集名称 - Parameter set name
    var date: Date = Date() // 创建日期 - Creation date
    var notes: String = "" // 笔记 - Notes
    
    // 光线条件 - Light conditions
    enum LightCondition: String, CaseIterable, Identifiable, Codable {
        case sunny = "晴天" // Sunny
        case cloudy = "多云" // Cloudy
        case overcast = "阴天" // Overcast
        case night = "夜间" // Night
        case indoor = "室内" // Indoor
        
        var id: String { self.rawValue }
        
        // 获取英文名称 - Get English name
        var englishName: String {
            switch self {
            case .sunny: return "Sunny"
            case .cloudy: return "Cloudy"
            case .overcast: return "Overcast"
            case .night: return "Night"
            case .indoor: return "Indoor"
            }
        }
    }
    
    // 场景模式 - Scene modes
    enum SceneMode: String, CaseIterable, Identifiable, Codable {
        case sport = "运动" // Sports
        case portrait = "人像" // Portrait
        case landscape = "风景" // Landscape
        case macro = "微距" // Macro
        case night = "夜景" // Night
        
        var id: String { self.rawValue }
        
        // 获取英文名称 - Get English name
        var englishName: String {
            switch self {
            case .sport: return "Sports"
            case .portrait: return "Portrait"
            case .landscape: return "Landscape"
            case .macro: return "Macro"
            case .night: return "Night"
            }
        }
    }
    
    // 测光模式 - Metering modes
    enum MeteringMode: String, CaseIterable, Identifiable, Codable {
        case evaluative = "评价测光" // Evaluative
        case centerWeighted = "中央重点" // Center-weighted
        case spot = "点测光" // Spot
        
        var id: String { self.rawValue }
        
        // 获取英文名称 - Get English name
        var englishName: String {
            switch self {
            case .evaluative: return "Evaluative"
            case .centerWeighted: return "Center-weighted"
            case .spot: return "Spot"
            }
        }
    }
    
    // 输入参数 - Input parameters
    var lightCondition: LightCondition = .sunny
    var iso: Double = 100 // ISO值范围100-3200
    var sceneMode: SceneMode = .landscape
    
    // 计算结果 - Calculation results
    var aperture: Double = 8.0 // 光圈值(f值) - Aperture (f-value)
    var shutterSpeed: Double = 125 // 快门速度(分母) - Shutter speed (denominator)
    var meteringMode: MeteringMode = .evaluative
    var exposureCompensation: Double = 0.0 // 曝光补偿(-3~+3 EV) - Exposure compensation
    
    // 格式化快门速度显示 - Format shutter speed display
    var formattedShutterSpeed: String {
        return "1/\(Int(shutterSpeed))"
    }
    
    // 格式化光圈值显示 - Format aperture display
    var formattedAperture: String {
        return "f/\(String(format: "%.1f", aperture))"
    }
    
    // 格式化曝光补偿显示 - Format exposure compensation display
    var formattedExposureCompensation: String {
        let prefix = exposureCompensation > 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.1f", exposureCompensation)) EV"
    }
} 