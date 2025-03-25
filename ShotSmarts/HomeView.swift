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
                VStack(spacing: 24) {
                    // 顶部标题 - Top title
                    Text("大师指南")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top)
                  
                    
                    // 参数输入卡片 - Parameter input card
                    ParameterInputCard(parameters: $currentParameters)
                    
                    // 参数结果仪表盘 - Parameter results dashboard
                    ParameterResultDashboard(parameters: currentParameters)
                    
                    // 底部按钮 - Bottom buttons
                    HStack(spacing: 20) {
                        // 重置按钮 - Reset button
                        Button(action: {
                            withAnimation {
                                resetParameters()
                            }
                        }) {
                            Text(LocalizedString("Reset", comment: "Reset button"))
                                .fontWeight(.medium)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(12)
                        }
                        
                        // 保存按钮 - Save button
                        Button(action: {
                            showingSaveDialog = true
                        }) {
                            Text(LocalizedString("Save", comment: "Save button"))
                                .fontWeight(.medium)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .navigationBarHidden(true)
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            
            // 保存对话框 - Save dialog
            .alert(LocalizedString("Save Parameters", comment: "Save parameters title"), isPresented: $showingSaveDialog) {
                TextField(LocalizedString("Parameter Name", comment: "Parameter name placeholder"), text: $parameterName)
                
                Button(LocalizedString("Cancel", comment: "Cancel button"), role: .cancel) {
                    parameterName = ""
                }
                
                Button(LocalizedString("Save", comment: "Save button")) {
                    saveParameters()
                }
            } message: {
                Text(LocalizedString("Enter a name for these parameters", comment: "Save parameters description"))
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
        VStack(alignment: .leading, spacing: 20) {
            // 光线条件选择器 - Light condition selector
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedString("Light Condition", comment: "Light condition label"))
                    .font(.headline)
                
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
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(LocalizedString("ISO", comment: "ISO label"))
                        .font(.headline)
                    Spacer()
                    Text("\(Int(parameters.iso))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Slider(
                    value: $parameters.iso,
                    in: 100...3200,
                    step: 100
                ) {
                    Text("ISO")
                } minimumValueLabel: {
                    Text("100")
                } maximumValueLabel: {
                    Text("3200")
                }
                .onChange(of: parameters.iso) { _ in
                    updateCalculatedParameters()
                }
            }
            
            // 场景模式选择器 - Scene mode selector
            VStack(alignment: .leading, spacing: 8) {
                Text(LocalizedString("Scene Mode", comment: "Scene mode label"))
                    .font(.headline)
                
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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
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
        VStack(spacing: 20) {
            // 主要参数显示 - Main parameter display
            HStack(spacing: 30) {
                // 光圈值 - Aperture value
                ParameterIndicator(
                    title: LocalizedString("Aperture", comment: "Aperture label"),
                    value: parameters.formattedAperture,
                    icon: "camera.aperture"
                )
                
                // 快门速度 - Shutter speed
                ParameterIndicator(
                    title: LocalizedString("Shutter", comment: "Shutter label"),
                    value: parameters.formattedShutterSpeed,
                    icon: "timer"
                )
            }
            
            Divider()
            
            // 次要参数显示 - Secondary parameter display
            HStack(spacing: 30) {
                // 测光模式 - Metering mode
                ParameterIndicator(
                    title: LocalizedString("Metering", comment: "Metering label"),
                    value: LocalizedString(parameters.meteringMode.rawValue, comment: "Metering mode"),
                    icon: "viewfinder"
                )
                
                // 曝光补偿 - Exposure compensation
                ParameterIndicator(
                    title: LocalizedString("Exp. Comp.", comment: "Exposure compensation label"),
                    value: parameters.formattedExposureCompensation,
                    icon: "plusminus"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// 参数指示器 - Parameter Indicator
struct ParameterIndicator: View {
    var title: String
    var value: String
    var icon: String
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.blue)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(minWidth: 0, maxWidth: .infinity)
    }
}

#Preview {
    HomeView()
        .environmentObject(ParameterHistoryManager())
    
}
