import SwiftUI

struct ProductDetailView: View {
    @State private var isFavorite: Bool
    @State private var showAddedToCart: Bool = false
    let product: Product
    
    private let brandGradient = LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
    
    init(product: Product) {
        self.product = product
        self._isFavorite = State(initialValue: product.isFavorite)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(20)
                    .padding(.top, 16)
                Text(product.name)
                    .font(AppFont.title)
                    .padding(.top, 8)
                
                // 品牌（渐变）+ 右侧价格胶囊
                HStack {
                    Text(product.brand.uppercased())
                        .font(AppFont.sectionTitle)
                        .bold() // 稍微加粗
                        .foregroundStyle(brandGradient)
                    Spacer()
                    Text(String(format: "$%.2f", product.price))
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(brandGradient)
                        .clipShape(Capsule())
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
                
                // 加入购物车按钮，右对齐，位于价格下方，使用品牌配色
                HStack {
                    Spacer()
                    Button(action: {
                        showAddedToCart = true
                        // TODO: 添加购物车逻辑
                    }) {
                        Label("Add to Cart", systemImage: "cart.badge.plus")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .foregroundColor(.white)
                            .background(brandGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 4)
                    }
                    .accessibilityIdentifier("detail_add_to_cart_button")
                }
                
                // 描述区域
                VStack(alignment: .leading, spacing: 8) {
                    Text("DESCRIPTION")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(product.description)
                        .font(AppFont.body)
                        .foregroundColor(.primary)
                    Text("Purpose: Built for runners who want a confident daily trainer — mixing cushioned comfort with stable transitions. Great for road mileage, recovery days, and tempo efforts. The engineered upper provides breathable support; the midsole geometry keeps your stride smooth and efficient.")
                        .font(AppFont.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
                
                if showAddedToCart {
                    Text("Added to cart!")
                        .foregroundColor(.accentGreen)
                        .font(.caption)
                        .transition(.opacity)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 16)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle(product.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProductDetailView(product: MockData.products.first!)
}
