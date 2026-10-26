import Foundation
import SwiftUI
import Combine

class AppState: ObservableObject {
    @Published var isAuthenticated: Bool {
        didSet {
            UserDefaults.standard.set(isAuthenticated, forKey: Self.authKey)
        }
    }
    @Published var user: MenuUser? {
        didSet {
            if let user = user, let data = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(data, forKey: Self.userKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.userKey)
            }
        }
    }
    var cartManager = CartManager()
    var favoritesManager = FavoritesManager()

    private static let authKey = "kix_is_authenticated"
    private static let userKey = "kix_logged_in_user"

    init() {
        let defaults = UserDefaults.standard
        self.isAuthenticated = defaults.bool(forKey: Self.authKey)
        if let data = defaults.data(forKey: Self.userKey),
           let user = try? JSONDecoder().decode(MenuUser.self, from: data) {
            self.user = user
        } else {
            self.user = MenuUser(username: "张三", email: "zhangsan@kixapp.com")
        }
    }
}
