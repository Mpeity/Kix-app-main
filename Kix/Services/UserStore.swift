import Foundation

struct User: Codable, Equatable {
    let email: String
    let username: String
    let password: String
}

class UserStore {
    static let shared = UserStore()
    private let key = "kix_users"
    private var users: [User] = []
    
    private init() {
        load()
    }
    
    func load() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([User].self, from: data) {
            // 将之前存储的邮箱统一转为小写，以确保不区分大小写的行为
            users = decoded.map { user in
                let lowercasedEmail = user.email.lowercased()
                if lowercasedEmail != user.email {
                    return User(email: lowercasedEmail, username: user.username, password: user.password)
                }
                return user
            }
            save()
        } else {
            // 添加默认用户（邮箱以小写存储）
            users = [
                User(email: "test@kixapp.com", username: "测试用户", password: "password"),
                // 如需取消注释或扩展默认用户
                // User(email: "manager@kixapp.com", username: "管理员", password: "password"),
                // User(email: "guest@kixapp.com", username: "访客", password: "password"),
            ]
            save()
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func addUser(_ user: User) {
        // 确保邮箱以小写存储
        let normalized = User(email: user.email.lowercased(), username: user.username, password: user.password)
        users.append(normalized)
        save()
    }
    
    func user(email: String, password: String) -> User? {
        let normalizedEmail = email.lowercased()
        return users.first { $0.email.lowercased() == normalizedEmail && $0.password == password }
    }
    
    func userExists(email: String) -> Bool {
        let normalizedEmail = email.lowercased()
        return users.contains { $0.email.lowercased() == normalizedEmail }
    }
    
    func reset() {
        users = [User(email: "test@kixapp.com", username: "测试用户", password: "password")]
        save()
    }
}
