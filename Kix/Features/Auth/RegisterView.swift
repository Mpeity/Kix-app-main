import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    var onRegister: ((String, String, String) -> Void)? = nil
    
    // 品牌渐变色（与 LoginView 一致）
    let brandGradient = LinearGradient(
        colors: [Color.blue, Color.purple, Color.pink.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ZStack {
            // 柔和白色背景（与 LoginView 一致）
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Spacer()
                
                // 1. 改进版 KIX 标志（SwiftUI 绘制，与 LoginView 一致）
                VStack(spacing: -15) {
                    Text("KIX")
                        .font(.system(size: 80, weight: .black, design: .rounded))
                        .italic()
                        .foregroundStyle(brandGradient)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 10)
                        // 镜面高光效果
                        .overlay(
                            Text("KIX")
                                .font(.system(size: 80, weight: .black, design: .rounded))
                                .italic()
                                .foregroundColor(.white.opacity(0.4))
                                .offset(y: -3)
                                .mask(LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .center))
                        )
                    
                    Text("球鞋商店")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .tracking(6)
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.bottom, 20)
                
                // 2. 欢迎文字
                Text("加入 KIX 大家庭")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                
                // 3. "液态"风格输入框（与 LoginView 一致）
                VStack(spacing: 18) {
                    customField(title: "邮箱", text: $email, isSecure: false)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .accessibilityIdentifier("register_email_field")
                    
                    customField(title: "用户名", text: $username, isSecure: false)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .accessibilityIdentifier("register_username_field")
                    
                    customField(title: "密码", text: $password, isSecure: true)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .accessibilityIdentifier("register_password_field")
                    
                    customField(title: "确认密码", text: $confirmPassword, isSecure: true)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .accessibilityIdentifier("register_confirm_password_field")
                }
                
                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(.caption, design: .rounded))
                }
                
                // 4. 带液态镜面效果的注册按钮（与 LoginView 一致）
                Button(action: {
                    if email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty {
                        errorMessage = "请填写所有字段。"
                    } else if password != confirmPassword {
                        errorMessage = "两次密码不一致。"
                    } else if UserStore.shared.userExists(email: email) {
                        errorMessage = "用户已存在。"
                    } else {
                        let user = User(email: email, username: username, password: password)
                        UserStore.shared.addUser(user)
                        errorMessage = nil
                        onRegister?(email, username, password)
                        dismiss()
                    }
                }) {
                    Text("创建账号")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .kerning(2)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(brandGradient)
                        .cornerRadius(20)
                        .shadow(color: .blue.opacity(0.4), radius: 15, y: 8)
                }
                .padding(.top, 10)
                .accessibilityIdentifier("register_button")
                
                // 5. 登录按钮
                Button(action: { dismiss() }) {
                    HStack {
                        Text("已有账号？")
                            .foregroundColor(.gray)
                        Text("去登录")
                            .fontWeight(.bold)
                            .foregroundStyle(brandGradient)
                    }
                    .font(.system(size: 14, design: .rounded))
                }
                .padding(.top, 10)
                .accessibilityIdentifier("back_to_login_button")
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 35)
        }
        .onAppear {
            // 页面出现时清空输入框
            email = ""
            username = ""
            password = ""
            confirmPassword = ""
            errorMessage = nil
        }
    }
    
    // 辅助函数：样式化输入框（与 LoginView 一致）
    @ViewBuilder
    private func customField(title: String, text: Binding<String>, isSecure: Bool) -> some View {
        Group {
            if isSecure {
                SecureField(title, text: text)
            } else {
                TextField(title, text: text)
                    .keyboardType(title == "邮箱" ? .emailAddress : .default)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.5)
        )
    }
}

#Preview {
    RegisterView().environmentObject(AuthViewModel())
}
