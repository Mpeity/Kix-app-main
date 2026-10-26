import Foundation
import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String? = nil
    
    func login(completion: @escaping (User?) -> Void) {
        let normalizedEmail = email.lowercased()
        if normalizedEmail.isEmpty || password.isEmpty {
            errorMessage = "请输入邮箱和密码。"
        } else {
            let user = UserStore.shared.user(email: normalizedEmail, password: password)
            if user != nil {
                errorMessage = nil
                completion(user)
            } else {
                errorMessage = "邮箱或密码错误。"
            }
        }
    }
    
    func register(completion: () -> Void) {
        if email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
            errorMessage = "请填写所有字段。"
        } else if password != confirmPassword {
            errorMessage = "两次密码不一致。"
        } else {
            errorMessage = nil
            // 模拟注册成功
            completion()
        }
    }
    
    func reset() {
        email = ""
        password = ""
        username = ""
        confirmPassword = ""
        errorMessage = nil
    }
}
