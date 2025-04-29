import SwiftUI

// 等效焦距换算视图
struct FocalLengthCalculatorView: View {
    // 状态变量
    @State private var focalLength: Double = 50
    @State private var sensorType: SensorType = .fullFrame
    @Environment(\.presentationMode) var presentationMode
    
    // 主题色
    let themeColor = Color(hex: "#FF7648")
    
    // 传感器类型枚举
    enum SensorType: String, CaseIterable, Identifiable {
        case fullFrame = "fullFrame"
        case mediumFormat = "mediumFormat"  // 中画幅（完全）
        case mediumFormat4433 = "mediumFormat4433"  // 中画幅4433
        case apsc = "apsc"
        case micro43 = "micro43"
        case oneInch = "oneInch"
        
        var id: String { self.rawValue }
        
        // 显示名称
        var displayName: String {
            switch self {
            case .fullFrame: return NSLocalizedString("全画幅", comment: "全画幅传感器")
            case .mediumFormat: return NSLocalizedString("中画幅(完全)", comment: "中画幅完全传感器")
            case .mediumFormat4433: return NSLocalizedString("中画幅4433", comment: "中画幅4433传感器")
            case .apsc: return NSLocalizedString("APS-C", comment: "APS-C传感器")
            case .micro43: return NSLocalizedString("M4/3", comment: "M4/3传感器")
            case .oneInch: return NSLocalizedString("1英寸", comment: "1英寸传感器")
            }
        }
        
        // 裁切系数
        var cropFactor: Double {
            switch self {
            case .fullFrame: return 1.0
            case .mediumFormat: return 0.64  // 中画幅完全，约为0.64x
            case .mediumFormat4433: return 0.79  // 中画幅4433，约为0.79x
            case .apsc: return 1.5
            case .micro43: return 2.0
            case .oneInch: return 2.7
            }
        }
    }
    
    // 创建说明文本，避免格式化字符串的问题
    private func createExplanationText() -> String {
        let originalFocalLength = Int(focalLength)
        let equivalentFocalLength = Int(focalLength * sensorType.cropFactor)
        
        // 直接创建完整字符串，避免复杂的格式化
        return "\(originalFocalLength) mm lens on \(sensorType.displayName) sensor is equivalent to \(equivalentFocalLength) mm on full frame"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 标题说明
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("焦距等效换算", comment: "焦距等效换算标题"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(NSLocalizedString("计算不同传感器尺寸下的等效焦距", comment: "焦距等效换算说明"))
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                    }
                    .padding(.top, 20)
                    
                    // 传感器选择部分
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(themeColor)
                            
                            Text(NSLocalizedString("传感器类型", comment: "传感器类型"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        
                        // 传感器类型下拉菜单
                        Menu {
                            ForEach(SensorType.allCases) { type in
                                Button(action: {
                                    sensorType = type
                                }) {
                                    HStack {
                                        Text(type.displayName)
                                            .font(.system(size: 16))
                                        
                                        if sensorType == type {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14))
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(sensorType.displayName)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // 焦距设置部分
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "camera.aperture")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(themeColor)
                            
                            Text(NSLocalizedString("焦距", comment: "焦距设置"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // 数值显示
                            Text(String(format: NSLocalizedString("%d 毫米", comment: "焦距值显示"), Int(focalLength)))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(themeColor)
                        }
                        
                        // 滑块和刻度
                        VStack(spacing: 8) {
                            Slider(value: $focalLength, in: 10...400)
                                .accentColor(themeColor)
                            
                            // 刻度标记
                            HStack {
                                Text(NSLocalizedString("10", comment: "最小焦距值"))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(NSLocalizedString("205", comment: "中间焦距值"))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(NSLocalizedString("400", comment: "最大焦距值"))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 4)
                        }
                        
                        // 加减按钮
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                if focalLength > 10 {
                                    focalLength = max(10, focalLength - 5)
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(themeColor)
                                    .clipShape(Circle())
                            }
                            
                            Spacer(minLength: 30)
                            
                            Button(action: {
                                if focalLength < 400 {
                                    focalLength = min(400, focalLength + 5)
                                }
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 44, height: 44)
                                    .background(themeColor)
                                    .clipShape(Circle())
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // 计算结果部分
                    VStack(spacing: 24) {
                        // 图解说明
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(NSLocalizedString("原始焦距", comment: "原始焦距"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text(String(format: NSLocalizedString("%d 毫米", comment: "焦距值显示"), Int(focalLength)))
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text("\(sensorType.displayName)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text(String(format: NSLocalizedString("×%@", comment: "裁切系数格式"), String(format: "%.1f", sensorType.cropFactor)))
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            
                            Image(systemName: "equal")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                            
                            VStack(alignment: .leading, spacing: 6) {
                                Text(NSLocalizedString("等效焦距", comment: "等效焦距"))
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text(String(format: NSLocalizedString("%d 毫米", comment: "焦距值显示"), Int(focalLength * sensorType.cropFactor)))
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(themeColor)
                            }
                        }
                        
                        Divider()
                        
                        // 最终结果
                        VStack(spacing: 10) {
                            Text(NSLocalizedString("等效焦距", comment: "等效焦距"))
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            Text("\(Int(focalLength * sensorType.cropFactor))")
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(themeColor)
                            
                            Text(NSLocalizedString("毫米", comment: "毫米单位"))
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        // 简易说明 - 使用更安全的方式避免格式化字符串问题
                        Text(createExplanationText())
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGray6))
            .edgesIgnoringSafeArea(.bottom)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(NSLocalizedString("等效焦距换算", comment: "等效焦距换算"))
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(themeColor)
                    Text(NSLocalizedString("设置", comment: "返回设置"))
                        .foregroundColor(themeColor)
                }
            })
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    FocalLengthCalculatorView()
}