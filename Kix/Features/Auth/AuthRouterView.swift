import SwiftUI

struct AuthRouterView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        if appState.isAuthenticated {
            MainTabView()
        } else {
            LoginView()
        }
    }
}

#Preview {
    // 预览中不包含 FavoritesManager，因为重复的类型定义会导致 init() 歧义。
    // 如需重新启用，请先去重项目中的 FavoritesManager.swift 文件，然后添加：
    // .environmentObject(FavoritesManager())
    AuthRouterView()
        .environmentObject(AppState())
        .environmentObject(AuthViewModel())
}
