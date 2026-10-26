//
//  Persistence.swift
//  Kix
//
//  由 Konstanty Halets 创建于 2026/01/06。
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // 用适当的错误处理代码替换此实现。
            // fatalError() 会导致应用生成崩溃日志并终止。你不应在正式发布的应用中使用此函数，尽管在开发阶段可能会有用。
            #if DEBUG
            assertionFailure("未解决的错误：\(error)")
            #else
            print("未解决的错误：\(error)")
            #endif
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Kix")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // 用适当的错误处理代码替换此实现。
                // fatalError() 会导致应用生成崩溃日志并终止。你不应在正式发布的应用中使用此函数，尽管在开发阶段可能会有用。

                /*
                 此处出现错误的典型原因包括：
                 * 父目录不存在、无法创建或不允许写入。
                 * 由于权限或设备锁定时的数据保护，持久化存储不可访问。
                 * 设备存储空间不足。
                 * 存储无法迁移到当前模型版本。
                 请检查错误信息以确定实际问题。
                 */
                #if DEBUG
                assertionFailure("未解决的错误：\(error)，信息：\(error.userInfo)")
                #else
                print("未解决的错误：\(error)，信息：\(error.userInfo)")
                #endif
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
