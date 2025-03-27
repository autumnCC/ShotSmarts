import Foundation
import SwiftUI

// 参数历史记录管理器 - Parameter History Manager
class ParameterHistoryManager: ObservableObject {
    // 存储的参数记录 - Stored parameter records
    @Published var savedParameters: [ShootingParameters] = []
    
    // 文件保存路径 - File save path
    private let savePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("savedParameters.json")
    
    // 初始化方法 - Initialization method
    init() {
        loadParameters()
    }
    
    // 保存参数记录 - Save parameter record
    func saveParameter(_ parameter: ShootingParameters) {
        var parameterToSave = parameter
        
        // 如果名称为空，则提供默认名称 - Provide default name if empty
        if parameterToSave.name.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            parameterToSave.name = "拍摄 \(dateFormatter.string(from: Date()))"
        }
        
        // 添加参数到列表开头 - Add parameter to the beginning of the list
        savedParameters.insert(parameterToSave, at: 0)
        saveToFile()
    }
    
    // 删除参数记录 - Delete parameter record
    func deleteParameter(at indexSet: IndexSet) {
        savedParameters.remove(atOffsets: indexSet)
        saveToFile()
    }
    
    // 更新参数记录 - Update parameter record
    func updateParameter(_ parameter: ShootingParameters) {
        if let index = savedParameters.firstIndex(where: { $0.id == parameter.id }) {
            savedParameters[index] = parameter
            saveToFile()
        }
    }
    
    // 重命名参数 - Rename parameter
    func renameParameter(_ parameter: ShootingParameters, to newName: String) {
        if let index = savedParameters.firstIndex(where: { $0.id == parameter.id }) {
            var updatedParameter = parameter
            updatedParameter.name = newName
            savedParameters[index] = updatedParameter
            saveToFile()
        }
    }
    
    // 保存到文件 - Save to file
    private func saveToFile() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedParameters)
            try data.write(to: savePath)
        } catch {
            print("保存参数记录失败: \(error.localizedDescription)") // Failed to save parameters
        }
    }
    
    // 从文件加载 - Load from file
    private func loadParameters() {
        guard FileManager.default.fileExists(atPath: savePath.path) else { return }
        
        do {
            let data = try Data(contentsOf: savePath)
            let decoder = JSONDecoder()
            savedParameters = try decoder.decode([ShootingParameters].self, from: data)
            
            // 按日期排序，最新的排在最前面 - Sort by date, newest first
            savedParameters.sort { $0.date > $1.date }
        } catch {
            print("加载参数记录失败: \(error.localizedDescription)") // Failed to load parameters
        }
    }
} 