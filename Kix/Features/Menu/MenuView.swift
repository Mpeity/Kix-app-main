import SwiftUI

struct MenuUser: Codable {
    var username: String
    var email: String
    var shoeSize: Double = 42.0
}

struct MenuView: View {
    @EnvironmentObject var appState: AppState
    @State private var isDarkMode: Bool = false
    @State private var showLogoutAlert: Bool = false
    @State private var showAddCardAlert: Bool = false
    @State private var selectedCurrency: String = "USD"

    var user: MenuUser = MenuUser(username: "张三", email: "zhangsan@kixapp.com")

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 头部样式与首页一致
                Text("菜单")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .italic()
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple, .pink.opacity(0.9)],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .padding(.top, 16)
                    .accessibilityIdentifier("menu_header")

                Form {
                    // 个人资料区域，可导航至详情页
                    Section(header: Text("个人资料")) {
                        NavigationLink(destination: ProfileDetailView(user: user)) {
                            HStack {
                                Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.accentGreen)
                                VStack(alignment: .leading) {
                                    Text(user.username)
                                        .font(.headline)
                                    Text(user.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .accessibilityIdentifier("profile_nav_link")
                    }

                    // 设置区域
                    Section(header: Text("设置")) {
                        Toggle(isOn: $isDarkMode) {
                            Text("深色模式")
                        }
                        .accessibilityIdentifier("dark_mode_toggle")

                        Picker("货币", selection: $selectedCurrency) {
                            Text("USD").tag("USD")
                            Text("EUR").tag("EUR")
                            Text("GBP").tag("GBP")
                            Text("UAH").tag("UAH")
                        }
                        .accessibilityIdentifier("currency_picker")

                        Button(action: { showAddCardAlert = true }) {
                            HStack {
                                Image(systemName: "creditcard")
                                Text("添加信用卡")
                            }
                        }
                        .accessibilityIdentifier("add_credit_card_button")
                        .alert("添加卡片", isPresented: $showAddCardAlert) {
                            Button("确定") {}
                        } message: {
                            Text("模拟：卡片录入功能待实现。")
                        }
                    }

                    // 将登出按钮下推，使用样式化按钮
                    Section {
                        Button(action: { showLogoutAlert = true }) {
                            Text("退出登录")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(12)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(12)
                                .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
                        }
                        .accessibilityIdentifier("logout_button")
                        .alert(isPresented: $showLogoutAlert) {
                            Alert(
                                title: Text("退出登录"),
                                message: Text("确定要退出登录吗？"),
                                primaryButton: .destructive(Text("退出")) {
                                    appState.user = nil
                                    appState.isAuthenticated = false
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 个人资料详情页
struct ProfileDetailView: View {
    @State var user: MenuUser

    var body: some View {
        Form {
            Section(header: Text("用户")) {
                HStack {
                    Text("姓名")
                    Spacer()
                    Text(user.username)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("邮箱")
                    Spacer()
                    Text(user.email)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("鞋码")
                    Spacer()
                    Text(String(format: "%.1f", user.shoeSize))
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("个人资料")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MenuView()
        .environmentObject(AppState())
}
