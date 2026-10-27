import SwiftUI

struct HomeView: View {
    @State private var products: [Product] = MockData.products
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var tabSelection: TabSelection
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedProduct: Product? = nil
    // 品牌渐变（紫色 → 蓝色），卡片中带有微妙的绿色点缀
    let brandGradient = LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)
    
    @State private var showAddSheet: Bool = false
    @State private var newName: String = ""
    @State private var newBrand: String = ""
    @State private var newPriceText: String = ""
    @State private var newDescription: String = ""
    @State private var newImageName: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    // --- 头部 ---
                    VStack(alignment: .center, spacing: 4) {
                        Text("KIX 精选")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .italic()
                            .foregroundStyle(
                                LinearGradient(colors: [.blue, .purple, .pink.opacity(0.9)],
                                               startPoint: .leading,
                                               endPoint: .trailing)
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                        Text("精选高性能跑鞋")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 15)

                    GeometryReader { geometry in
                        let isLandscape = geometry.size.width > geometry.size.height
                        let isRegular = sizeClass == .regular
                        let horizontalPadding: CGFloat = 16
                        let gridSpacing: CGFloat = 16

                        if isRegular && isLandscape {
                            // 展开态横屏：左右分栏
                            HStack(spacing: 0) {
                                ScrollView {
                                    LazyVStack(spacing: 25) {
                                        ForEach(products) { product in
                                            NewProductCard(
                                                product: product,
                                                onEdit: { updated in
                                                    if let idx = products.firstIndex(where: { $0.id == updated.id }) {
                                                        products[idx] = updated
                                                    }
                                                },
                                                onDelete: {
                                                    if let idx = products.firstIndex(where: { $0.id == product.id }) {
                                                        products.remove(at: idx)
                                                    }
                                                },
                                                onCardTap: { selectedProduct = product }
                                            )
                                            .padding(.horizontal)
                                            .accessibilityIdentifier("home_product_card_\(product.id.uuidString)")
                                            .environmentObject(appState.favoritesManager)
                                            .environmentObject(appState.cartManager)
                                            .environmentObject(tabSelection)
                                        }
                                    }
                                    .padding(.top, 10)
                                    .padding(.bottom, 100)
                                }
                                .frame(width: geometry.size.width * 0.45)

                                Divider()

                                // 右侧详情面板
                                if let product = selectedProduct {
                                    ProductDetailView(product: product)
                                        .environmentObject(appState.cartManager)
                                        .environmentObject(tabSelection)
                                } else {
                                    VStack(spacing: 12) {
                                        Image(systemName: "hand.tap")
                                            .font(.system(size: 40))
                                            .foregroundColor(.secondary)
                                        Text("选择一个商品查看详情")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                }
                            }
                        } else if isRegular {
                            // 展开态竖屏：两列网格
                            let availableWidth = geometry.size.width - (horizontalPadding * 2)
                            let totalSpacing = gridSpacing * 1
                            let cardWidth = (availableWidth - totalSpacing) / 2

                            ScrollView {
                                LazyVGrid(columns: Array(repeating: GridItem(.fixed(cardWidth), spacing: gridSpacing), count: 2), spacing: 25) {
                                    ForEach(products) { product in
                                        NewProductCard(
                                            product: product,
                                            onEdit: { updated in
                                                if let idx = products.firstIndex(where: { $0.id == updated.id }) {
                                                    products[idx] = updated
                                                }
                                            },
                                            onDelete: {
                                                if let idx = products.firstIndex(where: { $0.id == product.id }) {
                                                    products.remove(at: idx)
                                                }
                                            }
                                        )
                                        .frame(width: cardWidth)
                                        .accessibilityIdentifier("home_product_card_\(product.id.uuidString)")
                                        .environmentObject(appState.favoritesManager)
                                        .environmentObject(appState.cartManager)
                                        .environmentObject(tabSelection)
                                    }
                                }
                                .padding(.horizontal, horizontalPadding)
                                .padding(.top, 10)
                                .padding(.bottom, 100)
                                .frame(maxWidth: .infinity)
                            }
                        } else {
                            // 折叠态：单列
                            ScrollView {
                                LazyVStack(spacing: 25) {
                                    ForEach(products) { product in
                                        NewProductCard(
                                            product: product,
                                            onEdit: { updated in
                                                if let idx = products.firstIndex(where: { $0.id == updated.id }) {
                                                    products[idx] = updated
                                                }
                                            },
                                            onDelete: {
                                                if let idx = products.firstIndex(where: { $0.id == product.id }) {
                                                    products.remove(at: idx)
                                                }
                                            }
                                        )
                                        .padding(.horizontal)
                                        .accessibilityIdentifier("home_product_card_\(product.id.uuidString)")
                                        .environmentObject(appState.favoritesManager)
                                        .environmentObject(appState.cartManager)
                                        .environmentObject(tabSelection)
                                    }
                                }
                                .padding(.top, 10)
                                .padding(.bottom, 100) // 为标签栏预留间距
                            }
                        }
                    }
                }
            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: { showAddSheet = true }) {
//                        Image(systemName: "plus")
//                    }
//                    .accessibilityIdentifier("home_add_product_button")
//                }
//            }
            .sheet(isPresented: $showAddSheet) {
                NavigationStack {
                    Form {
                        Section(header: Text("名称")) {
                            TextField("例如 Vaporfly 3", text: $newName)
                        }
                        Section(header: Text("品牌")) {
                            TextField("例如 Nike", text: $newBrand)
                        }
                        Section(header: Text("价格")) {
                            TextField("例如 199.99", text: $newPriceText)
                                .keyboardType(.decimalPad)
                        }
                        Section(header: Text("描述")) {
                            TextEditor(text: $newDescription)
                                .frame(minHeight: 100)
                        }
                        Section(header: Text("图片名称（资源）")) {
                            TextField("例如 vaporfly3", text: $newImageName)
                        }
                    }
                    .navigationTitle("新增球鞋")
                    .navigationBarTitleDisplayMode(.inline)
                    .presentationSizing(.form)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("取消") {
                                showAddSheet = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("保存") {
                                let trimmedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                                let trimmedBrand = newBrand.trimmingCharacters(in: .whitespacesAndNewlines)
                                let price = Double(newPriceText.replacingOccurrences(of: ",", with: ".")) ?? -1
                                guard !trimmedName.isEmpty, !trimmedBrand.isEmpty, price >= 0 else { return }
                                let product = Product(
                                    id: UUID(),
                                    name: trimmedName,
                                    brand: trimmedBrand,
                                    price: price,
                                    imageName: newImageName.trimmingCharacters(in: .whitespacesAndNewlines),
                                    isFavorite: false,
                                    description: newDescription
                                )
                                products.insert(product, at: 0)
                                // 重置输入框
                                newName = ""; newBrand = ""; newPriceText = ""; newDescription = ""; newImageName = ""
                                showAddSheet = false
                            }
                            .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || newBrand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || Double(newPriceText.replacingOccurrences(of: ",", with: ".")) == nil)
                        }
                    }
                }
            }
        }
    }
}

// --- 带品牌颜色和溢出菜单的卡片 ---
struct NewProductCard: View {
    let product: Product
    var onEdit: (Product) -> Void
    var onDelete: () -> Void
    var onCardTap: (() -> Void)? = nil

    @EnvironmentObject private var favoritesManager: FavoritesManager
    @EnvironmentObject private var cartManager: CartManager
    @EnvironmentObject private var tabSelection: TabSelection

    @State private var isPressed = false
    @State private var showMenu = false
    @State private var showDeleteConfirm = false
    @State private var showDetail = false
    @State private var showEditSheet = false

    // 与品牌风格一致的本地渐变
    private let bgGradient = LinearGradient(colors: [.purple.opacity(0.06), .blue.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
    private let priceGradient = LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 商品图片区域
            ZStack {
                RoundedRectangle(cornerRadius: 25)
                    .fill(bgGradient)
                    .frame(height: 200)
                
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .blur(radius: 40)
                    .offset(x: 50, y: -30)

                Group {
                    if let uiImage = UIImage(named: product.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 170)
                            .clipped()
                            .padding(.horizontal, 12)
                    } else {
                        VStack {
                            Image(systemName: "shoeprints.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray.opacity(0.35))
                            Text("暂无图片")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.gray.opacity(0.45))
                        }
                    }
                }

                // 右上角心形收藏按钮
                VStack {
                    HStack {
                        Spacer()
                        Button(action: { favoritesManager.toggleFavorite(product) }) {
                            Image(systemName: favoritesManager.isFavorite(product) ? "heart.fill" : "heart")
                                .foregroundColor(favoritesManager.isFavorite(product) ? .pink : .gray)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .accessibilityIdentifier("home_card_favorite_\(product.id.uuidString)")
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }

            // 商品信息
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(product.brand.uppercased())
                        .font(.system(size: 12, weight: .black))
                        .foregroundColor(.purple)
                    Spacer()
                    Text(String(format: "$%.0f", product.price))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                }
                
                Text(product.name)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(product.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 6)

            // 价格下方的省略号菜单
            HStack {
                Spacer()
                Button(action: { showMenu = true }) {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(priceGradient)
                }
                .accessibilityIdentifier("home_product_menu_\(product.id.uuidString)")
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 8)
        }
        .background(Color.white)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) { isPressed = false }
                if let onCardTap {
                    onCardTap()
                } else {
                    showDetail = true
                }
            }
        }
        .confirmationDialog("操作", isPresented: $showMenu, titleVisibility: .automatic) {
            Button("查看") { showDetail = true }
            Button("编辑") { showEditSheet = true }
            Button("删除", role: .destructive) { showDeleteConfirm = true }
            Button("取消", role: .cancel) {}
        }
        .alert("删除商品？", isPresented: $showDeleteConfirm) {
            Button("删除", role: .destructive) { onDelete() }
            Button("取消", role: .cancel) {}
        } message: {
            Text("此操作无法撤销。")
        }
        .sheet(isPresented: $showDetail) {
            ProductDetailView(product: product)
                .environmentObject(cartManager)
                .environmentObject(tabSelection)
        }
        .sheet(isPresented: $showEditSheet) {
            EditProductSheet(original: product) { updated in
                onEdit(updated)
            }
        }
    }
}

// 简易编辑表单（名称/价格/描述）
private struct EditProductSheet: View {
    let original: Product
    var onSave: (Product) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var priceText: String
    @State private var desc: String

    init(original: Product, onSave: @escaping (Product) -> Void) {
        self.original = original
        self.onSave = onSave
        _name = State(initialValue: original.name)
        _priceText = State(initialValue: String(format: "%.2f", original.price))
        _desc = State(initialValue: original.description)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("名称")) {
                    TextField("名称", text: $name)
                }
                Section(header: Text("价格")) {
                    TextField("例如 159.99", text: $priceText)
                        .keyboardType(.decimalPad)
                }
                Section(header: Text("描述")) {
                    TextEditor(text: $desc)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("编辑球鞋")
            .navigationBarTitleDisplayMode(.inline)
            .presentationSizing(.form)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let price = Double(priceText.replacingOccurrences(of: ",", with: ".")) ?? original.price
                        let updated = Product(
                            id: original.id,
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? original.name : name,
                            brand: original.brand,
                            price: price,
                            imageName: original.imageName,
                            isFavorite: original.isFavorite,
                            description: desc
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState().favoritesManager)
        .environmentObject(AppState().cartManager)
        .environmentObject(TabSelection())
}
