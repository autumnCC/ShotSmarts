import SwiftUI

// 首页视图 - Home View
struct HomeView: View {
    // 状态变量 - State variables
    @State private var currentParameters = ShootingParameters()
    @State private var showingSaveDialog = false
    @State private var parameterName = ""
    
    // 环境对象 - Environment objects
    @EnvironmentObject var historyManager: ParameterHistoryManager
    
    var body: some View {
      
        NavigationView {
            ScrollView {
                VStack(spacing: 16) { // 缩短整体间距
                    // 顶部标题 - Top title
                    Text("大师快拍")
                        .font(.system(size: 28, weight: .bold)) // 减小标题
                        .foregroundColor(.black)
                        .padding(.top, 10) // 减少顶部内边距
                  
                    
                    // 参数输入卡片 - Parameter input card
                    ParameterInputCard(parameters: $currentParameters)
                    
                    // 参数结果仪表盘 - Parameter results dashboard
                    ParameterResultDashboard(parameters: currentParameters)
                    
                    // 底部按钮 - Bottom buttons
                    HStack(spacing: 16) { // 减少按钮间距
                        // 重置按钮 - Reset button
                        Button(action: {
                            withAnimation {
                                resetParameters()
                            }
                        }) {
                            Text("重置")
                                .font(.system(size: 16, weight: .medium))
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.vertical, 12) // 减少垂直内边距
                                .background(Color(.systemGray6))
                                .foregroundColor(.black)
                                .cornerRadius(12)
                        }
                        
                        // 保存按钮 - Save button
                        Button(action: {
                            showingSaveDialog = true
                        }) {
                            Text("保存")
                                .font(.system(size: 16, weight: .medium))
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding(.vertical, 12) // 减少垂直内边距
                                .background(Color(hex: "#FF7648")) // 橙色
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4) // 减少顶部间距
                }
                .padding(.horizontal, 16) // 减少水平内边距
                .padding(.bottom, 16) // 减少底部内边距
            }
            .navigationBarHidden(true)
            .background(Color.white)
            .edgesIgnoringSafeArea(.bottom)
            
            // 保存对话框 - Save dialog
            .alert("保存参数", isPresented: $showingSaveDialog) {
                TextField("参数名称", text: $parameterName)
                
                Button("取消", role: .cancel) {
                    parameterName = ""
                }
                
                Button("保存") {
                    saveParameters()
                }
            } message: {
                Text("为这组参数设置一个名称")
            }
        }
    }
    
    // 保存参数 - Save parameters
    private func saveParameters() {
        var parametersToSave = currentParameters
        parametersToSave.name = parameterName
        
        historyManager.saveParameter(parametersToSave)
        parameterName = ""
    }
    
    // 重置参数 - Reset parameters
    private func resetParameters() {
        currentParameters = ShootingParameters()
    }
}

// 参数输入卡片 - Parameter Input Card
struct ParameterInputCard: View {
    // 绑定参数 - Binding parameters
    @Binding var parameters: ShootingParameters
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { // 减少间距
            // 光线条件选择器 - Light condition selector
            VStack(alignment: .leading, spacing: 8) { // 减少间距
                Text("光线条件")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                Picker("", selection: $parameters.lightCondition) {
                    ForEach(ShootingParameters.LightCondition.allCases) { condition in
                        Text(LocalizedString(condition.rawValue, comment: "Light condition"))
                            .tag(condition)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: parameters.lightCondition) { _ in
                    updateCalculatedParameters()
                }
            }
            
            // ISO值调节滑块 - ISO value adjustment slider
            VStack(alignment: .leading, spacing: 8) { // 减少间距
                HStack {
                    Text("ISO")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.black)
                    Spacer()
                    Text("\(Int(parameters.iso))")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                Slider(
                    value: $parameters.iso,
                    in: 100...3200,
                    step: 100
                ) {
                    Text("ISO")
                } minimumValueLabel: {
                    Text("100")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                } maximumValueLabel: {
                    Text("3200")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                .tint(Color(hex: "#FF7648")) // 橙色
                .onChange(of: parameters.iso) { _ in
                    updateCalculatedParameters()
                }
            }
            
            // 场景模式选择器 - Scene mode selector
            VStack(alignment: .leading, spacing: 8) { // 减少间距
                Text("场景模式")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                Picker("", selection: $parameters.sceneMode) {
                    ForEach(ShootingParameters.SceneMode.allCases) { mode in
                        Text(LocalizedString(mode.rawValue, comment: "Scene mode"))
                            .tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: parameters.sceneMode) { _ in
                    updateCalculatedParameters()
                }
            }
        }
        .padding(16) // 减少内边距
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // 更新计算参数 - Update calculated parameters
    private func updateCalculatedParameters() {
        let calculator = ParameterCalculator.shared
        let result = calculator.calculateParameters(
            lightCondition: parameters.lightCondition,
            iso: parameters.iso,
            sceneMode: parameters.sceneMode
        )
        
        parameters.aperture = result.aperture
        parameters.shutterSpeed = result.shutterSpeed
        parameters.meteringMode = result.meteringMode
        parameters.exposureCompensation = result.exposureCompensation
    }
}

// 参数结果仪表盘 - Parameter Results Dashboard
struct ParameterResultDashboard: View {
    // 参数 - Parameters
    var parameters: ShootingParameters
    
    var body: some View {
        VStack(spacing: 16) { // 减少间距
            // 参数显示布局修改为两行两列网格 - Update layout to 2x2 grid (2 columns, 2 rows)
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) { // 增加网格项之间的间距
                // 光圈值 - Aperture value
                ParameterIndicator(
                    title: "光圈",
                    value: parameters.formattedAperture,
                    icon: "camera.aperture",
                    color: Color(hex: "#FF7648") // 橙色
                )
                
                // 快门速度 - Shutter speed
                ParameterIndicator(
                    title: "快门",
                    value: parameters.formattedShutterSpeed,
                    icon: "timer",
                    color: Color(hex: "#FF7648") // 橙色
                )
                
                // ISO - ISO
                ParameterIndicator(
                    title: "ISO",
                    value: "\(Int(parameters.iso))",
                    icon: "camera.metering.center.weighted",
                    color: Color(hex: "#FF7648") // 橙色
                )
                
                // 曝光补偿 - Exposure compensation
                ParameterIndicator(
                    title: "曝光",
                    value: shortExposureValue(parameters.formattedExposureCompensation),
                    icon: "plusminus",
                    color: Color(hex: "#FF7648") // 橙色
                )
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 12)
            
            // 附加信息 - Additional info
            HStack(spacing: 12) {
                // 测光模式 - Metering mode
                HStack(spacing: 6) {
                    Image(systemName: "viewfinder")
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#FF7648")) // 橙色
                    
                    Text("测光模式：")
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    
                    Text(LocalizedString(parameters.meteringMode.rawValue, comment: "Metering mode"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // 场景模式 - Scene mode
                HStack(spacing: 6) {
                    Image(systemName: getSceneModeIcon(parameters.sceneMode))
                        .font(.system(size: 15))
                        .foregroundColor(Color(hex: "#FF7648")) // 橙色
                    
                    Text(LocalizedString(parameters.sceneMode.rawValue, comment: "Scene mode"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 16)
        }
        .padding(16) // 减少内边距
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
    
    // 短格式的曝光补偿 - Short exposure compensation
    private func shortExposureValue(_ fullValue: String) -> String {
        return fullValue.replacingOccurrences(of: " EV", with: "")
    }
    
    // 获取场景模式图标 - Get scene mode icon
    private func getSceneModeIcon(_ mode: ShootingParameters.SceneMode) -> String {
        switch mode {
        case .sport: return "figure.run"
        case .portrait: return "person.fill"
        case .landscape: return "mountain.2.fill"
        case .macro: return "flower"
        case .night: return "moon.stars.fill"
        }
    }
}

// 参数指示器 - Parameter Indicator
struct ParameterIndicator: View {
    var title: String
    var value: String
    var icon: String
    var color: Color = Color(hex: "#FF7648") // 默认为橙色
    
    var body: some View {
        VStack(spacing: 8) { // 减少垂直间距
            Image(systemName: icon)
                .font(.system(size: 24)) // 增大图标尺寸
                .foregroundColor(color)
                .frame(height: 28) // 固定高度，保持对齐
            
            Text(value)
                .font(.system(size: 20, weight: .bold)) // 增大字体尺寸
                .foregroundColor(.black)
                .lineLimit(1) // 确保单行显示
                .minimumScaleFactor(0.8) // 允许缩小字体以适应空间
            
            Text(title)
                .font(.system(size: 14)) // 增大标题字体
                .foregroundColor(.gray)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(10) // 增加内边距
    }
}

#Preview {
    HomeView()
        .environmentObject(ParameterHistoryManager())
}
