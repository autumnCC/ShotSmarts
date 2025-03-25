import Foundation

// 参数计算器 - Parameter Calculator
class ParameterCalculator {
    // 单例模式 - Singleton pattern
    static let shared = ParameterCalculator()
    
    private init() {}
    
    // 计算推荐的摄影参数 - Calculate recommended photography parameters
    func calculateParameters(lightCondition: ShootingParameters.LightCondition, 
                            iso: Double, 
                            sceneMode: ShootingParameters.SceneMode) -> (aperture: Double, 
                                                                       shutterSpeed: Double, 
                                                                       meteringMode: ShootingParameters.MeteringMode, 
                                                                       exposureCompensation: Double) {
        
        // 初始参数 - Initial parameters
        var aperture: Double = 8.0
        var shutterSpeed: Double = 125.0
        var meteringMode: ShootingParameters.MeteringMode = .evaluative
        var exposureCompensation: Double = 0.0
        
        // 基于光线条件的基础调整 - Basic adjustments based on light conditions
        switch lightCondition {
        case .sunny:
            aperture = 11.0
            shutterSpeed = 250.0
            exposureCompensation = 0.0
        case .cloudy:
            aperture = 8.0
            shutterSpeed = 125.0
            exposureCompensation = +0.5
        case .overcast:
            aperture = 5.6
            shutterSpeed = 125.0
            exposureCompensation = +1.0
        case .night:
            aperture = 2.8
            shutterSpeed = 15.0
            exposureCompensation = +2.0
            meteringMode = .centerWeighted
        case .indoor:
            aperture = 4.0
            shutterSpeed = 60.0
            exposureCompensation = +1.5
        }
        
        // ISO调整 - ISO adjustment
        // 正确计算ISO对曝光的影响 - Correctly calculate ISO's effect on exposure
        // ISO翻倍，快门速度也应该翻倍（曝光不变） - If ISO doubles, shutter speed should also double (keeping exposure constant)
        let isoRatio = iso / 100.0 // 相对于基础ISO 100的比率 - Ratio relative to base ISO 100
        shutterSpeed = shutterSpeed * isoRatio
        
        // 场景模式特定调整 - Scene mode specific adjustments
        switch sceneMode {
        case .sport:
            // 运动模式优先快门速度 - Sports mode prioritizes shutter speed
            let originalShutter = shutterSpeed
            shutterSpeed = max(500.0, shutterSpeed * 2)
            // 快门变化比例 - Shutter change ratio
            let shutterRatio = shutterSpeed / originalShutter
            // 根据快门变化调整光圈以保持曝光一致 - Adjust aperture based on shutter change to maintain exposure
            aperture = calculateApertureForExposure(aperture, shutterRatio: shutterRatio)
            meteringMode = .evaluative
        case .portrait:
            // 人像模式优先大光圈（小f值）获得浅景深 - Portrait mode prioritizes large aperture (small f-value) for shallow depth of field
            let originalAperture = aperture
            aperture = min(aperture, 4.0)
            // 光圈变化比例 - Aperture change ratio
            let apertureRatio = (aperture * aperture) / (originalAperture * originalAperture)
            // 根据光圈变化调整快门速度以保持曝光一致 - Adjust shutter speed based on aperture change to maintain exposure
            shutterSpeed = calculateShutterForExposure(shutterSpeed, apertureRatio: apertureRatio)
            meteringMode = .centerWeighted
            exposureCompensation += 0.3 // 略微提亮肤色 - Slightly brighten skin tones
        case .landscape:
            // 风景模式优先小光圈（大f值）获得大景深 - Landscape mode prioritizes small aperture (large f-value) for deep depth of field
            let originalAperture = aperture
            aperture = max(aperture, 8.0)
            // 光圈变化比例 - Aperture change ratio
            let apertureRatio = (aperture * aperture) / (originalAperture * originalAperture)
            // 根据光圈变化调整快门速度以保持曝光一致 - Adjust shutter speed based on aperture change to maintain exposure
            shutterSpeed = calculateShutterForExposure(shutterSpeed, apertureRatio: apertureRatio)
            meteringMode = .evaluative
            exposureCompensation -= 0.3 // 略微增加饱和度 - Slightly increase saturation
        case .macro:
            // 微距模式需要精确对焦和减少手抖动 - Macro mode needs precise focus and reduced hand shake
            let originalAperture = aperture
            aperture = max(5.6, aperture) // 避免景深太浅 - Avoid too shallow depth of field
            // 光圈变化比例 - Aperture change ratio
            let apertureRatio = (aperture * aperture) / (originalAperture * originalAperture)
            // 根据光圈变化调整快门速度 - Adjust shutter speed based on aperture change
            shutterSpeed = calculateShutterForExposure(shutterSpeed, apertureRatio: apertureRatio)
            // 确保快门速度足够快以减少抖动 - Ensure shutter speed is fast enough to reduce shake
            shutterSpeed = max(125.0, shutterSpeed)
            meteringMode = .spot
        case .night:
            // 夜景模式需要收集更多光线 - Night mode needs to collect more light
            aperture = min(aperture, 2.8)
            shutterSpeed = min(shutterSpeed, 30.0)
            meteringMode = .centerWeighted
            exposureCompensation += 1.0
        }
        
        // 最终参数限制在合理范围内 - Final parameters limited to reasonable ranges
        aperture = max(1.4, min(22.0, aperture))
        shutterSpeed = max(1.0, min(4000.0, shutterSpeed))
        exposureCompensation = max(-3.0, min(3.0, exposureCompensation))
        
        // 规范化快门速度为标准值 - Normalize shutter speed to standard values
        shutterSpeed = normalizeShutterSpeed(shutterSpeed)
        
        return (aperture, shutterSpeed, meteringMode, exposureCompensation)
    }
    
    // 标准化快门速度为常用值 - Normalize shutter speed to common values
    private func normalizeShutterSpeed(_ speed: Double) -> Double {
        let standardSpeeds = [1, 2, 4, 8, 15, 30, 60, 125, 250, 500, 1000, 2000, 4000]
        
        // 找到最接近的标准快门速度 - Find the closest standard shutter speed
        var closest = standardSpeeds[0]
        var minDiff = abs(Double(standardSpeeds[0]) - speed)
        
        for std in standardSpeeds {
            let diff = abs(Double(std) - speed)
            if diff < minDiff {
                minDiff = diff
                closest = std
            }
        }
        
        return Double(closest)
    }
    
    // 根据光圈变化比例调整快门速度以保持相同曝光 - Adjust shutter speed based on aperture ratio to maintain the same exposure
    private func calculateShutterForExposure(_ shutterSpeed: Double, apertureRatio: Double) -> Double {
        // 光圈平方与快门成反比 - Square of aperture is inversely proportional to shutter
        return shutterSpeed / apertureRatio
    }
    
    // 根据快门速度变化比例调整光圈以保持相同曝光 - Adjust aperture based on shutter ratio to maintain the same exposure
    private func calculateApertureForExposure(_ aperture: Double, shutterRatio: Double) -> Double {
        // 光圈平方与快门成反比 - Square of aperture is inversely proportional to shutter
        return aperture * sqrt(1.0 / shutterRatio)
    }
    
    // 旧方法保留兼容性 - Old methods kept for compatibility
    @available(*, deprecated, message: "使用新的calculateShutterForExposure方法")
    private func adjustShutterForExposure(shutterSpeed: Double, apertureChange: Double) -> Double {
        return shutterSpeed / apertureChange
    }
    
    @available(*, deprecated, message: "使用新的calculateApertureForExposure方法")
    private func adjustApertureForExposure(aperture: Double, shutterSpeedChange: Double) -> Double {
        let sqrtChange = sqrt(shutterSpeedChange)
        return aperture / sqrtChange
    }
} 