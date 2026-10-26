import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel = AuthViewModel()
    @State private var showRegister: Bool = false
    @State private var showPassword: Bool = false
    
    // 品牌渐变色
    let brandGradient = LinearGradient(
        colors: [Color.blue, Color.purple, Color.pink.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    var body: some View {
        ZStack {
            // 柔和背景，顶部带有微光效果
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Spacer()
                
                // 1. 改进版 KIX 标志（SwiftUI 绘制，非图片）
                VStack(spacing: -15) {
                    Text("KIX")
                        .font(.system(size: 100, weight: .black, design: .rounded))
                        .italic()
                        .foregroundStyle(brandGradient)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 10)
                        // 镜面高光效果
                        .overlay(
                            Text("KIX")
                                .font(.system(size: 100, weight: .black, design: .rounded))
                                .italic()
                                .foregroundColor(.white.opacity(0.4))
                                .offset(y: -3)
                                .mask(LinearGradient(colors: [.white, .clear], startPoint: .top, endPoint: .center))
                        )
                    
                    Text("球鞋商店")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(8)
                        .foregroundColor(.gray.opacity(0.6))
                }
                .padding(.bottom, 30)
                
                // 2. 欢迎文字
                Text("欢迎回来")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                
                // 3. "液态"风格输入框（柔和圆角）
                VStack(spacing: 18) {
                    customField(title: "邮箱", text: $viewModel.email, isSecure: false)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .keyboardType(.emailAddress)
                        .accessibilityIdentifier("login_email_field")
                    
                    // 密码输入框，带显示/隐藏切换
                    HStack(spacing: 12) {
                        Group {
                            if showPassword {
                                TextField("密码", text: $viewModel.password)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            } else {
                                SecureField("密码", text: $viewModel.password)
                                    .textContentType(.password)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled(true)
                            }
                        }
                        .accessibilityIdentifier("login_password_field")
                        
                        Button(action: { showPassword.toggle() }) {
                            Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                .foregroundColor(.gray)
                                .accessibilityLabel(showPassword ? "隐藏密码" : "显示密码")
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
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.system(.caption, design: .rounded))
                }
                
                // 4. 带液态镜面效果的登录按钮
                Button(action: {
                    viewModel.login { user in
                        if let user = user {
                            appState.user = MenuUser(username: user.username, email: user.email)
                        }
                        appState.isAuthenticated = true
                    }
                }) {
                    Text("登录")
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
                .accessibilityIdentifier("login_button")
                
                // 5. 注册按钮
                Button(action: { showRegister = true }) {
                    HStack {
                        Text("第一次来？")
                            .foregroundColor(.gray)
                        Text("创建账号")
                            .fontWeight(.bold)
                            .foregroundStyle(brandGradient)
                    }
                    .font(.system(size: 14, design: .rounded))
                }
                .padding(.top, 10)
                .accessibilityIdentifier("register_nav_button")
                
                Spacer()
                Spacer()
            }
            .padding(.horizontal, 35)
        }
        .sheet(isPresented: $showRegister) {
            RegisterView(onRegister: { email, username, password in
                viewModel.email = email
                viewModel.password = password
                showRegister = false
            })
            .environmentObject(viewModel)
        }
    }
    
    // 辅助函数：样式化输入框
    @ViewBuilder
    private func customField(title: String, text: Binding<String>, isSecure: Bool) -> some View {
        Group {
            if isSecure {
                SecureField(title, text: text)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
            } else {
                TextField(title, text: text)
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
