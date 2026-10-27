import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var favoritesManager: FavoritesManager
    @EnvironmentObject var cartManager: CartManager
    @EnvironmentObject var tabSelection: TabSelection
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedProduct: Product? = nil

    var body: some View {
        NavigationStack {
            VStack(alignment: .center, spacing: 0) {
                // 头部居中，使用渐变效果与首页风格一致
                Text("收藏")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .italic()
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple, .pink.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.top, 24)
                    .accessibilityIdentifier("favorites_title")
                
                if favoritesManager.favorites.isEmpty {
                    // 空状态提示，居中显示
                    VStack(spacing: 8) {
                        Image(systemName: "heart")
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundColor(.purple.opacity(0.7))
                        Text("暂无收藏")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                            .accessibilityIdentifier("favorites_empty_label")
                        Text("去首页添加你喜欢的鞋子吧")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    GeometryReader { geometry in
                        let horizontalPadding: CGFloat = 16
                        let spacing: CGFloat = 12
                        let columnCount = sizeClass == .regular ? 3 : 2
                        let availableWidth = geometry.size.width - (horizontalPadding * 2)
                        let totalSpacing = spacing * CGFloat(columnCount - 1)
                        let cardWidth = (availableWidth - totalSpacing) / CGFloat(columnCount)

                        ScrollView {
                            LazyVGrid(columns: Array(repeating: GridItem(.fixed(cardWidth), spacing: spacing), count: columnCount), spacing: 12) {
                                ForEach(favoritesManager.favorites) { product in
                                    FavoriteCard(
                                        product: product,
                                        cardWidth: cardWidth,
                                        onRemove: {
                                            favoritesManager.toggleFavorite(product)
                                        },
                                        onTap: {
                                            selectedProduct = product
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                            .padding(.top, 16)
                            .padding(.bottom, 100)
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedProduct) { product in
                NavigationStack {
                    ProductDetailView(product: product)
                        .environmentObject(favoritesManager)
                        .environmentObject(cartManager)
                        .environmentObject(tabSelection)
                }
            }
        }
    }
}

// MARK: - 收藏卡片组件
struct FavoriteCard: View {
    let product: Product
    let cardWidth: CGFloat
    var onRemove: () -> Void
    var onTap: () -> Void
    
    @State private var isPressed = false
    
    private let brandGradient = LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
    private let bgGradient = LinearGradient(colors: [.purple.opacity(0.06), .blue.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 图片区域
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(bgGradient)
                    .frame(height: 140)
                
                if let uiImage = UIImage(named: product.imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cardWidth, height: 140)
                        .clipped()
                        .cornerRadius(16)
                } else {
                    VStack {
                        Image(systemName: "shoeprints.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.35))
                    }
                    .frame(width: cardWidth, height: 140)
                }
                
                // 删除按钮
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 3, x: 0, y: 2)
                }
                .padding(8)
                .accessibilityIdentifier("remove_favorite_button_\(product.id)")
            }
            
            // 商品信息
            VStack(alignment: .leading, spacing: 6) {
                Text(product.brand.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.purple)
                
                Text(product.name)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(String(format: "$%.0f", product.price))
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(brandGradient)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
                onTap()
            }
        }
        .frame(width: cardWidth)
    }
}

#Preview {
    FavoritesView()
        .environmentObject(FavoritesManager())
        .environmentObject(CartManager())
        .environmentObject(TabSelection())
}
