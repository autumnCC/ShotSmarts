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
        print("初始化参数历史管理器...")
        print("参数保存路径: \(savePath.path)")
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
        
        // 确保ID唯一 - Ensure unique ID
        let uniqueID = UUID()
        parameterToSave.id = uniqueID
        
        // 确保日期是当前时间，以便正确排序 - Ensure date is current time for proper sorting
        let currentDate = Date()
        parameterToSave.date = currentDate
        print("保存新参数 ID: \(uniqueID.uuidString), 名称: \(parameterToSave.name), 使用当前日期: \(currentDate)")
        
        // 添加新参数到列表 - Add new parameter to the list
        // 不再查找已有ID，而是直接添加新纪录保证唯一性
        savedParameters.append(parameterToSave)
        
        // 按日期排序，最新的排在前面 - Sort by date, newest first
        sortParametersByDate()
        
        // 保存到文件
        if saveToFile() {
            // 打印调试信息 - Print debug info
            print("保存参数成功: \(parameterToSave.name)，当前参数数量: \(savedParameters.count)")
        } else {
            print("⚠️ 警告: 保存参数失败")
        }
    }
    
    // 删除参数记录 - Delete parameter record
    func deleteParameter(at indexSet: IndexSet) {
        // 保存删除前的数量
        let countBefore = savedParameters.count
        
        // 打印删除的记录
        for index in indexSet {
            if index < savedParameters.count {
                let param = savedParameters[index]
                print("删除参数: ID=\(param.id.uuidString), 名称=\(param.name)")
            }
        }
        
        // 删除参数
        savedParameters.remove(atOffsets: indexSet)
        
        // 保存更改
        if saveToFile() {
            print("删除参数成功: 从 \(countBefore) 条记录减少到 \(savedParameters.count) 条记录")
        } else {
            print("⚠️ 警告: 删除后保存失败")
        }
    }
    
    // 更新参数记录 - Update parameter record
    func updateParameter(_ parameter: ShootingParameters) {
        if let index = savedParameters.firstIndex(where: { $0.id == parameter.id }) {
            var updatedParameter = parameter
            
            // 比较并打印日期 - Compare and print dates
            let originalDate = savedParameters[index].date
            let originalName = savedParameters[index].name
            print("更新参数 ID: \(parameter.id.uuidString)")
            print("更新前: 名称=\(originalName), 日期=\(originalDate)")
            
            // 确保使用新的日期时间 - Ensure using new date and time
            updatedParameter.date = Date()
            
            print("更新后: 名称=\(updatedParameter.name), 日期=\(updatedParameter.date)")
            
            savedParameters[index] = updatedParameter
            
            // 重新排序 - Re-sort
            sortParametersByDate()
            
            // 保存更改
            if saveToFile() {
                print("更新参数成功: \(updatedParameter.name)")
            } else {
                print("⚠️ 警告: 更新参数后保存失败")
            }
        } else {
            print("⚠️ 错误: 未找到要更新的参数 ID: \(parameter.id.uuidString)")
        }
    }
    
    // 重命名参数 - Rename parameter
    func renameParameter(_ parameter: ShootingParameters, to newName: String) {
        if let index = savedParameters.firstIndex(where: { $0.id == parameter.id }) {
            var updatedParameter = parameter
            
            // 比较并打印日期 - Compare and print dates
            let originalDate = savedParameters[index].date
            let originalName = savedParameters[index].name
            print("重命名参数 ID: \(parameter.id.uuidString)")
            print("重命名前: 名称=\(originalName), 日期=\(originalDate)")
            
            updatedParameter.name = newName
            // 更新修改日期 - Update modification date
            updatedParameter.date = Date()
            
            print("重命名后: 名称=\(newName), 日期=\(updatedParameter.date)")
            
            savedParameters[index] = updatedParameter
            
            // 重新排序 - Re-sort
            sortParametersByDate()
            
            // 保存更改
            if saveToFile() {
                print("重命名参数成功: \(originalName) -> \(newName)")
            } else {
                print("⚠️ 警告: 重命名参数后保存失败")
            }
        } else {
            print("⚠️ 错误: 未找到要重命名的参数 ID: \(parameter.id.uuidString)")
        }
    }
    
    // 按日期排序参数 - Sort parameters by date
    private func sortParametersByDate() {
        // 排序前打印日期 - Print dates before sorting
        print("排序前参数数量: \(savedParameters.count)")
        
        // 确保日期使用相同的格式进行比较
        savedParameters.sort { first, second in
            // 比较日期，最新的排在最前面
            return first.date > second.date
        }
        
        // 排序后打印日期 - Print dates after sorting
        print("排序后参数顺序:")
        for (index, param) in savedParameters.enumerated() {
            print("  [\(index)] \(param.name): \(param.date)")
        }
    }
    
    // 验证参数排序并修复 - Validate parameter sorting and fix if needed
    private func validateAndFixParameterSorting() -> Bool {
        // 如果没有参数或只有一个参数，已经是排序的
        if savedParameters.count <= 1 {
            return true
        }
        
        // 检查是否有排序问题
        let isSorted = zip(savedParameters, savedParameters.dropFirst()).allSatisfy { $0.date > $1.date }
        
        if !isSorted {
            print("⚠️ 检测到排序问题，重新应用排序...")
            sortParametersByDate()
            return false
        }
        
        return true
    }
    
    // 保存到文件 - Save to file
    @discardableResult
    private func saveToFile() -> Bool {
        // 保存前验证并修复排序
        validateAndFixParameterSorting()
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(savedParameters)
            try data.write(to: savePath)
            
            // 打印保存状态
            print("参数保存到文件成功 - 路径: \(savePath.path)")
            print("保存的参数列表 (\(savedParameters.count)个):")
            for (index, param) in savedParameters.enumerated() {
                print("[\(index)] ID: \(param.id.uuidString), 名称: \(param.name), 日期: \(param.date)")
            }
            
            // 验证文件大小
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: savePath.path)
            let fileSize = fileAttributes[.size] as? UInt64 ?? 0
            print("保存文件大小: \(fileSize) 字节")
            
            return true
        } catch {
            print("保存参数记录失败: \(error.localizedDescription)")
            // 尝试记录更多错误信息
            if let err = error as NSError? {
                print("错误代码: \(err.code), 错误域: \(err.domain)")
                print("错误详情: \(err.userInfo)")
            }
            return false
        }
    }
    
    // 从文件加载 - Load from file
    @discardableResult
    private func loadParameters() -> Bool {
        guard FileManager.default.fileExists(atPath: savePath.path) else { 
            print("参数文件不存在，将创建新文件")
            return false
        }
        
        do {
            let data = try Data(contentsOf: savePath)
            
            // 打印加载的数据大小
            print("加载的文件大小: \(data.count) 字节")
            
            // 检查数据是否为空
            guard !data.isEmpty else {
                print("⚠️ 警告: 参数文件为空")
                savedParameters = []
                return false
            }
            
            // 解码数据
            let decoder = JSONDecoder()
            let loadedParameters = try decoder.decode([ShootingParameters].self, from: data)
            
            // 检查加载结果
            if loadedParameters.isEmpty {
                print("警告: 加载的参数列表为空")
                savedParameters = []
                return false
            } else {
                savedParameters = loadedParameters
                
                // 打印加载的参数日期 - Print loaded parameter dates
                print("加载的参数列表 (\(loadedParameters.count) 条记录):")
                for (index, param) in savedParameters.enumerated() {
                    print("[\(index)] ID: \(param.id.uuidString), 名称: \(param.name), 日期: \(param.date)")
                }
                
                // 按日期排序，最新的排在最前面 - Sort by date, newest first
                sortParametersByDate()
                
                // 验证排序后的结果 - Validate sorted results
                let isSorted = validateAndFixParameterSorting()
                print("参数列表排序正确: \(isSorted)")
                
                // 刷新UI
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
                print("成功加载参数记录，数量: \(savedParameters.count)")
                return true
            }
        } catch {
            print("加载参数记录失败: \(error.localizedDescription)")
            
            // 尝试记录更多错误信息
            if let err = error as NSError? {
                print("错误代码: \(err.code), 错误域: \(err.domain)")
                print("错误详情: \(err.userInfo)")
                
                // 如果是数据损坏，尝试恢复
                if err.domain == NSCocoaErrorDomain && (err.code == 3840 || err.code == 4864) {
                    print("检测到文件可能损坏，尝试创建备份并重置文件...")
                    
                    // 创建备份
                    let backupPath = savePath.deletingPathExtension().appendingPathExtension("bak.json")
                    try? FileManager.default.copyItem(at: savePath, to: backupPath)
                    
                    // 清空参数列表
                    savedParameters = []
                    saveToFile()
                }
            }
            
            // 如果加载失败，确保有一个空数组 - Ensure we have an empty array if loading fails
            savedParameters = []
            return false
        }
    }
    
    // 公开方法，允许重新排序参数 - Public method to allow re-sorting parameters
    func resortParameters() {
        print("主动请求重新排序参数列表")
        
        // 重新验证参数完整性
        if savedParameters.isEmpty {
            // 如果参数为空，尝试重新加载
            print("参数列表为空，尝试从文件加载")
            let success = loadParameters()
            
            if !success || savedParameters.isEmpty {
                print("重新加载后参数仍为空，检查文件是否存在...")
                // 检查文件是否存在
                if FileManager.default.fileExists(atPath: savePath.path) {
                    do {
                        // 尝试读取文件内容
                        let data = try Data(contentsOf: savePath)
                        print("文件存在，大小: \(data.count) 字节")
                        
                        if data.count > 0 {
                            // 尝试解析JSON结构
                            if let jsonString = String(data: data, encoding: .utf8) {
                                print("文件内容预览: \(String(jsonString.prefix(100)))...")
                            }
                        } else {
                            print("文件为空")
                        }
                    } catch {
                        print("检查文件内容时出错: \(error.localizedDescription)")
                    }
                } else {
                    print("参数文件不存在")
                }
            }
        }
        
        // 打印参数数量
        print("重排序前参数数量: \(savedParameters.count)")
        
        if savedParameters.isEmpty {
            print("没有参数可排序")
            return
        }
        
        // 排序参数
        sortParametersByDate()
        
        // 验证排序结果
        validateAndFixParameterSorting()
        
        // 刷新UI
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
        
        print("重排序完成，参数数量: \(savedParameters.count)")
    }
    
    // 测试方法: 创建示例参数 - Test method: Create sample parameters
    func createSampleParameters(count: Int) {
        print("创建 \(count) 个示例参数...")
        
        for i in 1...count {
            var parameter = ShootingParameters()
            parameter.name = "测试参数 #\(i)"
            parameter.lightCondition = ShootingParameters.LightCondition.allCases.randomElement() ?? .sunny
            parameter.sceneMode = ShootingParameters.SceneMode.allCases.randomElement() ?? .landscape
            parameter.iso = Double([100, 200, 400, 800, 1600, 3200].randomElement() ?? 100)
            
            // 计算参数
            let result = ParameterCalculator.shared.calculateParameters(
                lightCondition: parameter.lightCondition,
                iso: parameter.iso,
                sceneMode: parameter.sceneMode
            )
            
            parameter.aperture = result.aperture
            parameter.shutterSpeed = result.shutterSpeed
            parameter.meteringMode = result.meteringMode
            parameter.exposureCompensation = result.exposureCompensation
            
            // 随机日期 (最近7天内)
            let randomTimeInterval = TimeInterval(arc4random_uniform(7 * 24 * 60 * 60))
            parameter.date = Date().addingTimeInterval(-randomTimeInterval)
            
            // 保存参数
            saveParameter(parameter)
            
            // 短暂延迟，确保时间戳不同
            usleep(10000) // 10毫秒
        }
        
        print("示例参数创建完成，当前参数数量: \(savedParameters.count)")
    }
} 