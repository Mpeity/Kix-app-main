import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartManager
    @StateObject private var paymentManager = PaymentManager()
    @State private var showCheckoutAlert = false
    @State private var showAddCardSheet = false
    @State private var showingDeleteAlert: PaymentMethod? = nil
    @State private var showClearCartAlert = false
    
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
                                Text("商品")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                ForEach(cartManager.items) { item in
                                    HStack(spacing: 12) {
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
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("合计：").font(.title2)
                            Spacer()
                            Text("$\(String(format: "%.2f", cartManager.totalPrice()))")
                                .font(.title2).bold()
                                .accessibilityIdentifier("cart_total_price")
                        }
                        Button(action: { showCheckoutAlert = true }) {
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
                        .disabled(paymentManager.selectedMethod == nil)
                        .opacity(paymentManager.selectedMethod == nil ? 0.6 : 1)
                        .accessibilityIdentifier("checkout_button")
                    }
                    .padding([.horizontal, .bottom])
                    .alert(isPresented: $showCheckoutAlert) {
                        Alert(title: Text("结算"), message: Text(checkoutMessage()), dismissButton: .default(Text("确定"), action: {
                            cartManager.clearCart()
                        }))
                    }
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
    }
    
    private func iconName(for brand: CardBrand) -> String {
        switch brand {
        case .visa: return "v.circle.fill"
        case .masterCard: return "m.circle.fill"
        case .amex: return "a.circle.fill"
        case .other: return "creditcard"
        }
    }
    
    private func checkoutMessage() -> String {
        guard let method = paymentManager.selectedMethod else {
            return "请先添加并选择一种支付方式。"
        }
        return "已通过 \(method.brand.rawValue)（\(method.numberMasked)）支付。下单成功！（模拟）"
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
