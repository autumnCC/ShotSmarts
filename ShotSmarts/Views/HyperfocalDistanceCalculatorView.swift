import SwiftUI

struct HyperfocalDistanceCalculatorView: View {
    // 状态变量
    @State private var focalLength: Double = 50
    @State private var aperture: Double = 2.8
    @State private var sensorType: SensorType = .fullFrame
    @Environment(\.presentationMode) var presentationMode
    
    // 主题色
    let themeColor = Color(hex: "#FF7648")
    
    // 光圈选项
    let apertureOptions = [1.4, 1.8, 2.0, 2.8, 4.0, 5.6, 8.0, 11.0, 16.0, 22.0]
    
    // 传感器类型枚举
    enum SensorType: String, CaseIterable, Identifiable {
        case fullFrame = "fullFrame"
        case apsc = "apsc"
        case micro43 = "micro43"
        case oneInch = "oneInch"
        
        var id: String { self.rawValue }
        
        // 显示名称
        var displayName: String {
            switch self {
            case .fullFrame: return NSLocalizedString("全画幅", comment: "全画幅传感器")
            case .apsc: return NSLocalizedString("APS-C", comment: "APS-C传感器")
            case .micro43: return NSLocalizedString("M4/3", comment: "M4/3传感器")
            case .oneInch: return NSLocalizedString("1英寸", comment: "1英寸传感器")
            }
        }
        
        // 圈散模糊圈大小（毫米）
        var circleOfConfusion: Double {
            switch self {
            case .fullFrame: return 0.029
            case .apsc: return 0.019
            case .micro43: return 0.015
            case .oneInch: return 0.011
            }
        }
    }
    
    // 计算超焦距
    private func calculateHyperfocalDistance() -> Double {
        // 焦距（毫米转米）
        let f = focalLength / 1000
        // 光圈值
        let a = aperture
        // 圈散模糊圈大小（毫米转米）
        let c = sensorType.circleOfConfusion / 1000
        
        // 计算超焦距（米）
        let h = (f * f) / (a * c) + f
        
        return h
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title and description
                    VStack(spacing: 12) {
                        Text(NSLocalizedString("超焦距计算", comment: "Title of hyperfocal distance calculator"))
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text(NSLocalizedString("根据传感器类型、焦距和光圈计算超焦距", comment: "Description of hyperfocal distance calculator"))
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 12)
                    }
                    .padding(.top, 20)
                    
                    // Sensor type selection
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(NSLocalizedString("传感器类型", comment: "Sensor type selection"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text(sensorType.displayName)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
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
                    
                    // Focal length settings
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(NSLocalizedString("焦距", comment: "Focal length settings"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // Value display
                            Text(String(format: NSLocalizedString("%d 毫米", comment: "Focal length with unit"), Int(focalLength)))
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        
                        // 滑块和刻度
                        VStack(spacing: 8) {
                            Slider(value: $focalLength, in: 10...400, step: 1)
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
                                    .background(Color(.systemGray5))
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
                                    .background(Color(.systemGray5))
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
                    
                    // Aperture settings
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(NSLocalizedString("光圈", comment: "Aperture settings"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            // Value display
                            Text(String(format: NSLocalizedString("f/%@", comment: "Aperture value format"), String(format: "%.1f", aperture)))
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                        }
                        
                        // 光圈选择下拉菜单
                        Menu {
                            ForEach(apertureOptions, id: \.self) { value in
                                Button(action: {
                                    aperture = value
                                }) {
                                    HStack {
                                        Text(String(format: NSLocalizedString("f/%@", comment: "Aperture value format"), String(format: "%.1f", value)))
                                            .font(.system(size: 16))
                                        
                                        if abs(aperture - value) < 0.01 {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14))
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(String(format: NSLocalizedString("f/%@", comment: "Aperture value format"), String(format: "%.1f", aperture)))
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
                    
                    // Calculation results
                    VStack(spacing: 24) {
                        Text(NSLocalizedString("超焦距", comment: "Hyperfocal distance result"))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        
                        let hyperfocalDistance = calculateHyperfocalDistance()
                        
                        // Distance
                        VStack(spacing: 8) {
                            Text(String(format: "%.2f %@", hyperfocalDistance, NSLocalizedString("米", comment: "Unit: meter")))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(themeColor)
                        }
                        
                        // Explanation
                        VStack(spacing: 16) {
                            Text(NSLocalizedString("对焦于超焦距时，景深范围", comment: "Depth of field range explanation"))
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack(spacing: 20) {
                                VStack(spacing: 8) {
                                    Text(NSLocalizedString("近点距离", comment: "Near point distance"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Text(String(format: "%.2f %@", hyperfocalDistance / 2, NSLocalizedString("米", comment: "Unit: meter")))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                }
                                
                                Divider()
                                    .frame(height: 40)
                                
                                VStack(spacing: 8) {
                                    Text(NSLocalizedString("远点距离", comment: "Far point distance"))
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                    
                                    Text(NSLocalizedString("无穷远", comment: "Infinity"))
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                        .padding(.top, 8)
                        
                        // Visual range
                        VStack(spacing: 8) {
                            Text(NSLocalizedString("可视化范围", comment: "Visual range display"))
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .padding(.top, 8)
                            
                            ZStack(alignment: .leading) {
                                // 背景条
                                Rectangle()
                                    .fill(Color(.systemGray5))
                                    .frame(height: 8)
                                    .cornerRadius(4)
                                
                                // 超焦距点
                                Circle()
                                    .fill(Color.black)
                                    .frame(width: 12, height: 12)
                                    .offset(x: min(UIScreen.main.bounds.width - 40, max(0, (UIScreen.main.bounds.width - 40) * CGFloat(min(hyperfocalDistance, 20) / 20.0) - 6)))
                                
                                // 景深范围
                                Rectangle()
                                    .fill(themeColor)
                                    .frame(width: (UIScreen.main.bounds.width - 40) * CGFloat(min(hyperfocalDistance, 20) - (hyperfocalDistance / 2)) / 20.0, height: 8)
                                    .cornerRadius(4)
                                    .offset(x: (UIScreen.main.bounds.width - 40) * CGFloat(hyperfocalDistance / 2) / 20.0)
                            }
                            .frame(height: 20)
                            .padding(.vertical, 8)
                            
                            // 刻度标记
                            HStack {
                                Text(NSLocalizedString("0米", comment: "Distance scale start"))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Spacer()
                                
                                Text(NSLocalizedString("20米", comment: "Distance scale end"))
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // 实用说明
                        VStack(alignment: .leading, spacing: 12) {
                            Text(NSLocalizedString("实用技巧", comment: "Practical tips header"))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text(NSLocalizedString("在风景摄影中，将焦点设置在超焦距上可以使从前景到无穷远的景物都保持足够清晰。", comment: "Landscape photography tip"))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(NSLocalizedString("街头摄影常用超焦距技巧配合小光圈（如f/8或更小）快速拍摄而无需每次对焦。", comment: "Street photography tip"))
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.top, 16)
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
            .navigationTitle(NSLocalizedString("超焦距计算", comment: "超焦距计算"))
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

struct HyperfocalDistanceCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        HyperfocalDistanceCalculatorView()
    }
} 