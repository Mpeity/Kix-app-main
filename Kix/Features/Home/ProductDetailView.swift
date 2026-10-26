import SwiftUI

struct ProductDetailView: View {
    @State private var isFavorite: Bool
    @State private var showAddedToCart: Bool = false
    @State private var showAddResultAlert: Bool = false
    @State private var addResultMessage: String = ""
    let product: Product
    @EnvironmentObject private var cartManager: CartManager
    @EnvironmentObject private var tabSelection: TabSelection
    @Environment(\.dismiss) private var dismiss
    
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
                        cartManager.addToCart(product: product)
                        addResultMessage = "已成功将「\(product.name)」加入购物车！"
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showAddedToCart = true
                        }
                        showAddResultAlert = true
                    }) {
                        Label("加入购物车", systemImage: "cart.badge.plus")
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
                    Text("商品描述")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Text(product.description)
                        .font(AppFont.body)
                        .foregroundColor(.primary)
                    Text("用途：为追求自信日常训练的跑者打造——融合缓震舒适与稳定过渡。适合公路跑量、恢复跑和节奏跑。工程网面鞋面提供透气支撑；中底几何结构让步伐流畅高效。")
                        .font(AppFont.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 4)
                
                if showAddedToCart {
                    Text("已加入购物车！")
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
        .alert("提示", isPresented: $showAddResultAlert) {
            HStack {
                Button("继续购物", role: .cancel) {
                    dismiss()
                }
                Button("查看购物车") {
                    tabSelection.selectedTab = 4
                    dismiss()
                }
            }
        } message: {
            Text(addResultMessage)
        }
    }
}

#Preview {
    ProductDetailView(product: MockData.products.first!)
        .environmentObject(CartManager())
        .environmentObject(TabSelection())
}
