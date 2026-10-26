import Foundation
import SwiftUI
import Combine

class FavoritesManager: ObservableObject {
    @Published var favorites: [Product] = [] {
        didSet { saveFavorites() }
    }
    
    private let favoritesKey = "kix_favorites"

    init() {
        loadFavorites()
    }
    
    func toggleFavorite(_ product: Product) {
        if let index = favorites.firstIndex(where: { $0.id == product.id }) {
            favorites.remove(at: index)
        } else {
            var newProduct = product
            newProduct.isFavorite = true
            favorites.append(newProduct)
        }
    }
    
    func isFavorite(_ product: Product) -> Bool {
        favorites.contains(where: { $0.id == product.id })
    }
    
    private func saveFavorites() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: favoritesKey)
        } catch {
            print("保存收藏数据失败：\(error)")
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: favoritesKey) else {
            // 首次加载，使用默认的模拟收藏数据
            self.favorites = MockData.products.filter { $0.isFavorite }
            return
        }
        
        do {
            favorites = try JSONDecoder().decode([Product].self, from: data)
        } catch {
            print("加载收藏数据失败：\(error)")
            // 回退到默认模拟数据
            self.favorites = MockData.products.filter { $0.isFavorite }
        }
    }
}
