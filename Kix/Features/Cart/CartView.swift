import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartManager
    @StateObject private var paymentManager = PaymentManager()
    @State private var showCheckoutAlert = false
    @State private var showAddCardSheet = false
    @State private var showingDeleteAlert: PaymentMethod? = nil
    @State private var showClearCartAlert = false
    @State private var selectedItemIDs: Set<UUID> = []
    @State private var showCheckoutProcessing = false
    @State private var showCheckoutSuccess = false
    @State private var orderTotal: Double = 0
    @State private var orderItemCount: Int = 0
    @State private var showNoPaymentAlert = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                // 头部
                HStack { Spacer() }
                Text("购物车")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .italic()
                    .foregroundStyle(
                        LinearGradient(colors: [.blue, .purple, .pink.opacity(0.9)],
                                       startPoint: .leading,
                                       endPoint: .trailing)
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 24)
                    .padding(.horizontal, 16)
                    .accessibilityIdentifier("cart_header")
                
                if cartManager.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "cart")
                            .font(.system(size: 42))
                            .foregroundColor(.secondary)
                        Text("购物车是空的")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .accessibilityIdentifier("cart_empty_label")
                        Text("去首页添加你喜欢的鞋子吧")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 12)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // 商品列表
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("商品")
                                        .font(.headline)
                                    Spacer()
                                    Button(action: {
                                        if selectedItemIDs.count == cartManager.items.count {
                                            selectedItemIDs.removeAll()
                                        } else {
                                            selectedItemIDs = Set(cartManager.items.map { $0.id })
                                        }
                                    }) {
                                        Text(selectedItemIDs.count == cartManager.items.count ? "取消全选" : "全选")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    }
                                    .accessibilityIdentifier("select_all_button")
                                }
                                .padding(.horizontal)
                                
                                ForEach(cartManager.items) { item in
                                    HStack(spacing: 12) {
                                        // 选中按钮
                                        Button(action: {
                                            if selectedItemIDs.contains(item.id) {
                                                selectedItemIDs.remove(item.id)
                                            } else {
                                                selectedItemIDs.insert(item.id)
                                            }
                                        }) {
                                            Image(systemName: selectedItemIDs.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedItemIDs.contains(item.id) ? .blue : .gray)
                                                .font(.system(size: 24))
                                        }
                                        .accessibilityIdentifier("select_item_button_\(item.id)")
                                        
                                        if let uiImage = UIImage(named: item.product.imageName) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 60, height: 60)
                                                .clipped()
                                                .cornerRadius(10)
                                        } else {
                                            ZStack {
                                                Color(.systemGray6)
                                                Image(systemName: "shoeprints.fill")
                                                    .font(.system(size: 20))
                                                    .foregroundColor(.secondary)
                                            }
                                            .frame(width: 60, height: 60)
                                            .cornerRadius(10)
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text(item.product.name)
                                                .font(.headline)
                                            Text(item.product.brand)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            Text("$\(String(format: "%.2f", item.product.price))")
                                                .font(.caption)
                                        }
                                        Spacer()
                                        HStack(spacing: 8) {
                                            Button(action: { cartManager.decreaseQuantity(item: item) }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.purple)
                                                    .font(.system(size: 24))
                                            }
                                            .accessibilityIdentifier("decrease_quantity_button_\(item.id)")
                                            Text("\(item.quantity)")
                                                .frame(width: 24)
                                                .font(.headline)
                                            Button(action: { cartManager.increaseQuantity(item: item) }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .font(.system(size: 24))
                                            }
                                            .accessibilityIdentifier("increase_quantity_button_\(item.id)")
                                        }
                                        Button(action: { cartManager.removeFromCart(item: item) }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .font(.system(size: 20))
                                        }
                                        .accessibilityIdentifier("remove_cart_item_button_\(item.id)")
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(Color(.systemBackground))
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                                }
                            }
                            
                            // 支付方式
                            VStack(alignment: .leading, spacing: 12) {
                                Text("支付方式")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                if paymentManager.methods.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("暂无支付方式")
                                            .foregroundColor(.secondary)
                                        Button {
                                            showAddCardSheet = true
                                        } label: {
                                            Label("添加测试卡片", systemImage: "creditcard")
                                        }
                                        .accessibilityIdentifier("add_test_card_button")
                                    }
                                    .padding(.horizontal)
                                } else {
                                    ForEach(paymentManager.methods) { method in
                                        HStack {
                                            Image(systemName: iconName(for: method.brand))
                                                .foregroundColor(.blue)
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(method.brand.rawValue + " • " + method.numberMasked)
                                                    .font(.subheadline)
                                                Text(method.holderName)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            if paymentManager.selectedMethodID == method.id {
                                                Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                                            }
                                        }
                                        .contentShape(Rectangle())
                                        .onTapGesture { paymentManager.select(method) }
                                        .padding(.horizontal)
                                        .padding(.vertical, 8)
                                    }
                                    Button {
                                        showAddCardSheet = true
                                    } label: {
                                        Label("再添加一张测试卡片", systemImage: "plus.circle")
                                    }
                                    .accessibilityIdentifier("add_another_test_card_button")
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .onChange(of: cartManager.items) { newItems in
                        let existingIDs = Set(newItems.map { $0.id })
                        selectedItemIDs = selectedItemIDs.intersection(existingIDs)
                    }
                    .onAppear {
                        // 自动选中所有加载的商品
                        if selectedItemIDs.isEmpty && !cartManager.items.isEmpty {
                            selectedItemIDs = Set(cartManager.items.map { $0.id })
                        }
                    }
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("合计：").font(.title2)
                            Spacer()
                            Text("$\(String(format: "%.2f", selectedTotalPrice()))")
                                .font(.title2).bold()
                                .accessibilityIdentifier("cart_total_price")
                        }
                        Button(action: { 
                            // 检查是否有支付方式
                            if paymentManager.selectedMethod == nil {
                                showNoPaymentAlert = true
                                return
                            }
                            
                            // 开始结算流程
                            orderTotal = selectedTotalPrice()
                            orderItemCount = cartManager.items.filter { selectedItemIDs.contains($0.id) }.reduce(0) { $0 + $1.quantity }
                            showCheckoutProcessing = true
                            
                            // 模拟结算延迟
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                // 移除已结算的商品
                                cartManager.items.removeAll { selectedItemIDs.contains($0.id) }
                                selectedItemIDs.removeAll()
                                showCheckoutProcessing = false
                                showCheckoutSuccess = true
                            }
                        }) {
                            Text("去结算")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .kerning(1)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                                )
                                .cornerRadius(16)
                                .shadow(color: .purple.opacity(0.35), radius: 10, y: 6)
                        }
                        .disabled(selectedItemIDs.isEmpty)
                        .opacity(selectedItemIDs.isEmpty ? 0.6 : 1)
                        .accessibilityIdentifier("checkout_button")
                    }
                    .padding([.horizontal, .bottom])
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !cartManager.items.isEmpty {
                        Button(role: .destructive) {
                            showClearCartAlert = true
                        } label: {
                            Label("清空购物车", systemImage: "trash")
                        }
                        .accessibilityIdentifier("clear_cart_button")
                    }
                }
            }
        }
        .sheet(isPresented: $showAddCardSheet) {
            AddTestCardSheet { brand in
                paymentManager.addTestCard(brand: brand)
            }
            .presentationDetents([.height(300), .medium])
        }
        .sheet(isPresented: $showCheckoutProcessing) {
            CheckoutProcessingView()
        }
        .sheet(isPresented: $showCheckoutSuccess) {
            CheckoutSuccessView(
                totalAmount: orderTotal,
                itemCount: orderItemCount,
                onDismiss: {
                    showCheckoutSuccess = false
                }
            )
        }
        .alert(item: $showingDeleteAlert) { method in
            Alert(title: Text("移除卡片？"), message: Text("将移除尾号为 \(method.numberMasked.suffix(4)) 的 \(method.brand.rawValue)。"), primaryButton: .destructive(Text("移除"), action: {
                paymentManager.remove(method)
            }), secondaryButton: .cancel())
        }
        .alert("清空所有商品？", isPresented: $showClearCartAlert) {
            Button("取消", role: .cancel) {}
            Button("全部移除", role: .destructive) {
                cartManager.clearCart()
            }
        } message: {
            Text("将清空购物车中的所有商品。")
        }
        .alert("请先添加支付方式", isPresented: $showNoPaymentAlert) {
            Button("知道了") {}
        } message: {
            Text("结算前需要先添加支付方式，请向下滚动到支付方式区域添加。")
        }
    }
    
    private func iconName(for brand: CardBrand) -> String {
        switch brand {
        case .visa: return "v.circle.fill"
        case .masterCard: return "m.circle.fill"
        case .amex: return "a.circle.fill"
        case .other: return "creditcard"
        }
    }
    
    private func selectedTotalPrice() -> Double {
        cartManager.items
            .filter { selectedItemIDs.contains($0.id) }
            .reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
    }
}

// MARK: - 结算中视图
struct CheckoutProcessingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // 加载动画
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: .purple))
            
            VStack(spacing: 12) {
                Text("结算中...")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("正在处理您的订单")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - 结算成功视图
struct CheckoutSuccessView: View {
    let totalAmount: Double
    let itemCount: Int
    var onDismiss: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // 成功图标
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 12) {
                    Text("结算成功！")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("您的订单已确认")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                // 订单详情
                VStack(spacing: 16) {
                    HStack {
                        Text("商品数量")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(itemCount) 件")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("支付金额")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(String(format: "%.2f", totalAmount))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.purple)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // 完成按钮
                Button(action: {
                    onDismiss()
                    dismiss()
                }) {
                    Text("完成")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(16)
                        .shadow(color: .purple.opacity(0.35), radius: 10, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 添加测试卡片表单
struct AddTestCardSheet: View {
    var onAdd: (CardBrand) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBrand: CardBrand = .visa
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Picker("品牌", selection: $selectedBrand) {
                    ForEach([CardBrand.visa, .masterCard], id: \.id) { brand in
                        Text(brand.rawValue).tag(brand)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("测试卡号")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(selectedBrand.testNumber)
                        .font(.title3)
                        .monospacedDigit()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
                Button {
                    onAdd(selectedBrand)
                    dismiss()
                } label: {
                    Label("添加测试\(selectedBrand.rawValue)", systemImage: "creditcard.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(16)
                }
                .padding()
            }
            .navigationTitle("添加测试卡片")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("关闭") { dismiss() }
                }
            }
        }
    }
}
