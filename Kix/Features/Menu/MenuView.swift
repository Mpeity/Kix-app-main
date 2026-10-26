import SwiftUI

struct MenuUser {
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

    var user: MenuUser = MenuUser(username: "JohnDoe", email: "john.doe@example.com")

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 头部样式与首页一致
                Text("Menu")
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
                    Section(header: Text("Profile")) {
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
                    Section(header: Text("Settings")) {
                        Toggle(isOn: $isDarkMode) {
                            Text("Dark Mode")
                        }
                        .accessibilityIdentifier("dark_mode_toggle")

                        Picker("Currency", selection: $selectedCurrency) {
                            Text("USD").tag("USD")
                            Text("EUR").tag("EUR")
                            Text("GBP").tag("GBP")
                            Text("UAH").tag("UAH")
                        }
                        .accessibilityIdentifier("currency_picker")

                        Button(action: { showAddCardAlert = true }) {
                            HStack {
                                Image(systemName: "creditcard")
                                Text("Add Credit Card")
                            }
                        }
                        .accessibilityIdentifier("add_credit_card_button")
                        .alert("Add Card", isPresented: $showAddCardAlert) {
                            Button("OK") {}
                        } message: {
                            Text("Mock: card entry flow will be implemented later.")
                        }
                    }

                    // 将登出按钮下推，使用样式化按钮
                    Section {
                        Button(action: { showLogoutAlert = true }) {
                            Text("Logout")
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
                                title: Text("Logout"),
                                message: Text("Are you sure you want to logout?"),
                                primaryButton: .destructive(Text("Logout")) {
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
            Section(header: Text("User")) {
                HStack {
                    Text("Name")
                    Spacer()
                    Text(user.username)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Email")
                    Spacer()
                    Text(user.email)
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Shoe Size")
                    Spacer()
                    Text(String(format: "%.1f", user.shoeSize))
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    MenuView()
        .environmentObject(AppState())
}
