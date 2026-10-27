# Kix App — iPhone Duo & iOS 27.1 适配方案

> 文档版本：2026-10-27 | 项目：Kix Sneaker Store (SwiftUI)
> 基于实际代码审计更新，修正了上一版（2026-10-26）中多处与源码不符的描述

---

## 一、总体适配策略

参照 DuoAdaptDemo 参考项目，采用三层适配策略：

| 层级 | 目标 | 核心手段 |
|------|------|----------|
| **L0 — 基线合规** | 移除硬编码尺寸、废弃 API | 去掉固定 padding、按钮 `maxWidth` 限制、`NavigationView` → `NavigationStack` |
| **L1 — 系统自适应** | 利用系统容器自动适配 | `@Environment(\.horizontalSizeClass)` 判断布局；`NavigationSplitView` 宽屏侧边栏；`LazyVGrid` 自适应列数 |
| **L2 — Duo 增强** | iOS 27.1 专属 API | `UIArrangementViewController`（通过 `UIViewControllerRepresentable` 桥接）；`reservedRegions` 避让铰链/遮挡区 |

### 实际代码审计摘要

| 问题类型 | 数量 | 涉及文件 |
|----------|------|----------|
| `NavigationView`（已废弃） | **11 处** | HomeView(2)、EditProductSheet(1)、FavoritesView(2)、NotesView(1)、NoteDetailView(1)、MenuView(1)、CartView(1)、CheckoutSuccessView(1)、AddTestCardSheet(1) |
| `@Environment(\.presentationMode)`（已废弃） | 1 处 | NotesView:10 |
| 硬编码 `.padding(.horizontal, 35)` | 2 处 | LoginView:139、RegisterView:133 |
| 硬编码 `.padding(.bottom, 100)` | 3 处 | HomeView:68、FavoritesView:62、NotesView:102 |
| 按钮 `.frame(maxWidth: .infinity)` | 7 处 | LoginView:113、RegisterView:107、MenuView:91、CartView:245、CartView:429、NoteDetailView:268/283 |
| 固定图片尺寸 `.frame(height:)` | 5 处 | HomeView:164/176、ProductDetailView:26、FavoritesView:96、ProductCard:33 |
| 固定容器尺寸 | 2 处 | KixLogoView:57(1024x1024)、CheckoutSuccessView:373(120x120) |

### 全局改动清单

1. **废弃 API 迁移**：全部 11 处 `NavigationView` → `NavigationStack`
2. **废弃环境值迁移**：`@Environment(\.presentationMode)` → `@Environment(\.dismiss)`（NotesView:10）
3. **版本门控**：所有 iOS 27.1 API 使用 `if #available(iOS 27.1, *)` 门控
4. **内容最大宽度**：所有卡片、按钮、输入框加 `maxWidth` 限制，防止宽屏拉伸
5. **新增文件**：
   - `Kix/Core/Theme/AdaptiveLayout.swift` — 自适应常量与容器
   - `Kix/Core/Components/DuoArrangementView.swift` — iOS 27.1 桥接

---

## 二、新增基础设施文件

### 2.1 AdaptiveLayout.swift（自适应常量）

```swift
// ======== 新增文件 ========
// Kix/Core/Theme/AdaptiveLayout.swift

import SwiftUI

enum AdaptiveLayout {
    /// 内容区域最大宽度，超过此值后居中显示
    static let maxContentWidth: CGFloat = 600

    /// 按钮最大宽度
    static let maxButtonWidth: CGFloat = 400

    /// 宽屏判定断点（pt）
    static let wideBreakpoint: CGFloat = 700

    /// 卡片最大宽度
    static let maxCardWidth: CGFloat = 500

    /// 根据当前尺寸类返回列数
    static func columnCount(for sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 2 : 1
    }

    /// 收藏页宽屏列数（已有 2 列基线，宽屏可扩至 3 列）
    static func favoritesColumnCount(for sizeClass: UserInterfaceSizeClass?) -> Int {
        sizeClass == .regular ? 3 : 2
    }
}

/// 自适应内容容器：窄屏全宽，宽屏限宽居中
struct AdaptiveContent<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var sizeClass
    let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: sizeClass == .regular
                   ? AdaptiveLayout.maxContentWidth
                   : .infinity)
            .frame(maxWidth: .infinity) // 居中
    }
}
```

### 2.2 DuoArrangementView.swift（iOS 27.1 桥接）

```swift
// ======== 新增文件 ========
// Kix/Core/Components/DuoArrangementView.swift

import SwiftUI
import UIKit

/// iOS 27.1+ 使用 UIArrangementViewController 实现双栏；
/// 旧版本回退到 UISplitViewController。
struct DuoArrangementView<Primary: View, Secondary: View>: UIViewControllerRepresentable {
    let primary: Primary
    let secondary: Secondary

    init(@ViewBuilder primary: () -> Primary,
         @ViewBuilder secondary: () -> Secondary) {
        self.primary = primary()
        self.secondary = secondary()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        if #available(iOS 27.1, *) {
            return makeArrangement()
        }
        return makeLegacySplit()
    }

    func updateUIViewController(_ vc: UIViewController, context: Context) {}

    @available(iOS 27.1, *)
    private func makeArrangement() -> UIViewController {
        let arrangement = UIArrangementViewController()
        let primaryVC = UIHostingController(rootView: primary)
        let secondaryVC = UIHostingController(rootView: secondary)
        let primaryNav = UINavigationController(rootViewController: primaryVC)
        let secondaryNav = UINavigationController(rootViewController: secondaryVC)
        arrangement.setViewController(primaryNav, for: .primary)
        arrangement.setViewController(secondaryNav, for: .secondary)
        arrangement.updateArrangement(.split)
        return arrangement
    }

    private func makeLegacySplit() -> UIViewController {
        let split = UISplitViewController(style: .doubleColumn)
        let primaryVC = UIHostingController(rootView: primary)
        let secondaryVC = UIHostingController(rootView: secondary)
        split.setViewController(UINavigationController(rootViewController: primaryVC),
                                for: .primary)
        split.setViewController(UINavigationController(rootViewController: secondaryVC),
                                for: .secondary)
        split.preferredDisplayMode = .oneBesideSecondary
        return split
    }
}
```

---

## 三、逐页改动对比

---

### 3.1 MainTabView — 标签栏（核心改动）

**文件：** `Kix/Navigation/MainTabView.swift`

**现状：** 5 个 Tab 使用 `TabView`。`TabSelection` 类定义在此文件（第 4 行），被多个子视图通过 `@EnvironmentObject` 引用。HomeView 和 FavoritesView 同时注入 `favoritesManager` + `cartManager` + `tabSelection`，NotesView 注入 `tabSelection`，CartView 注入 `cartManager`，MenuView 无额外注入。

```swift
// ======== 改动后 ========

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var tabSelection = TabSelection()
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            // 宽屏（Duo 展开态）：侧边栏导航
            NavigationSplitView {
                List(selection: $tabSelection.selectedTab) {
                    Label("首页", systemImage: "house.fill").tag(0)
                    Label("笔记", systemImage: "note.text").tag(1)
                    Label("收藏", systemImage: "heart.fill").tag(2)
                    Label("菜单", systemImage: "line.3.horizontal").tag(3)
                    Label("购物车", systemImage: "cart.fill").tag(4)
                }
                .navigationTitle("KIX")
            } detail: {
                currentTabView
            }
            .tint(.purple)
        } else {
            // 窄屏（折叠态 / 普通 iPhone）：保持底部标签栏（原代码不变）
            TabView(selection: $tabSelection.selectedTab) {
                // ... 保持现有 5 个 Tab 及其 environmentObject 注入 ...
            }
            .accentColor(.purple)
            .onAppear { configureTabBarAppearance() }
        }
    }

    @ViewBuilder
    private var currentTabView: some View {
        switch tabSelection.selectedTab {
        case 0: HomeView()
                .environmentObject(appState.favoritesManager)
                .environmentObject(appState.cartManager)
                .environmentObject(tabSelection)
        case 1: NotesView().environmentObject(tabSelection)
        case 2: FavoritesView()
                .environmentObject(appState.favoritesManager)
                .environmentObject(appState.cartManager)
                .environmentObject(tabSelection)
        case 3: MenuView()
        case 4: CartView().environmentObject(appState.cartManager)
        default: HomeView()
                .environmentObject(appState.favoritesManager)
                .environmentObject(appState.cartManager)
                .environmentObject(tabSelection)
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.shadowColor = UIColor.black.withAlphaComponent(0.1)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
```

---

### 3.2 HomeView — 首页商品列表

**文件：** `Kix/Features/Home/HomeView.swift`

**现状：**
- 主视图 `NavigationView`（第 18 行）+ 新增商品 Sheet `NavigationView`（第 81 行）+ `EditProductSheet` 内 `NavigationView`（第 304 行）= **共 3 处**
- 商品列表使用 `LazyVStack` 单列（第 45 行），`.padding(.bottom, 100)` 硬编码（第 68 行）
- `NewProductCard` 图片区域 `.frame(height: 200)`（第 164 行）/ `.frame(height: 170)`（第 176 行）

#### 改动 1：NavigationStack 替换 + 双列网格

```swift
// ======== 原代码（第 18 行） ========
NavigationView {

// ======== 改动后 ========
NavigationStack {
```

```swift
// ======== 新增：自适应列数 ========
@Environment(\.horizontalSizeClass) private var sizeClass

private var columns: [GridItem] {
    if sizeClass == .regular {
        return [GridItem(.flexible(), spacing: 20),
                GridItem(.flexible(), spacing: 20)]
    }
    return [GridItem(.flexible())]
}

// ======== 原代码（第 43-68 行） ========
ScrollView {
    LazyVStack(spacing: 25) {
        ForEach(products) { product in
            NewProductCard(product: product, ...)
                .padding(.horizontal)
        }
    }
    .padding(.top, 10)
    .padding(.bottom, 100) // 为标签栏预留间距
}

// ======== 改动后 ========
ScrollView {
    LazyVGrid(columns: columns, spacing: 20) {
        ForEach(products) { product in
            NewProductCard(product: product, ...)
                .frame(maxWidth: AdaptiveLayout.maxCardWidth)
        }
    }
    .padding(.horizontal)
    .padding(.top, 10)
    .padding(.bottom, 10)
}
```

#### 改动 2：NewProductCard 图片区域自适应

```swift
// ======== 原代码（第 161-178 行） ========
ZStack {
    RoundedRectangle(cornerRadius: 25)
        .fill(bgGradient)
        .frame(height: 200)
    // ...
    Image(uiImage: uiImage)
        .resizable()
        .scaledToFill()
        .frame(height: 170)
        .clipped()
        .padding(.horizontal, 12)
}

// ======== 改动后 ========
ZStack {
    RoundedRectangle(cornerRadius: 25)
        .fill(bgGradient)
        .aspectRatio(1.2, contentMode: .fit)
    // ...
    Image(uiImage: uiImage)
        .resizable()
        .scaledToFill()
        .frame(maxHeight: .infinity)
        .clipped()
        .padding(.horizontal, 12)
}
```

#### 改动 3：Sheet 内 NavigationView 替换（第 81 行、第 304 行）

```swift
// ======== 原代码 ========
.sheet(isPresented: $showAddSheet) {
    NavigationView {
        Form { ... }
        .navigationTitle("新增球鞋")

// ======== 改动后 ========
.sheet(isPresented: $showAddSheet) {
    NavigationStack {
        Form { ... }
        .navigationTitle("新增球鞋")
    }
    .presentationSizing(.form)
```

```swift
// ======== EditProductSheet（第 304 行） ========
// 原代码：NavigationView {
// 改动后：NavigationStack { ... }.presentationSizing(.form)
```

---

### 3.3 ProductCard — 商品卡片组件（旧版/遗留）

**文件：** `Kix/Features/Home/ProductCard.swift`

**现状：** 此组件是旧版卡片。**HomeView 当前使用 `NewProductCard`（定义在 HomeView.swift:139）**，`ProductCard` 仅在 Preview 中引用，可能为遗留代码。

**建议：** 如确认不再使用可暂不改动。若保留，修改如下：

```swift
// ======== 原代码（第 33-34 行） ========
.frame(height: 180)
.cornerRadius(16)

// ======== 改动后 ========
.aspectRatio(1.0, contentMode: .fit)
.frame(maxHeight: 250)
.cornerRadius(16)
.frame(maxWidth: AdaptiveLayout.maxCardWidth)
```

---

### 3.4 ProductDetailView — 商品详情页

**文件：** `Kix/Features/Home/ProductDetailView.swift`

**现状：**
- 无自身 `NavigationView`（由父视图提供）
- 图片区域 `.frame(height: 300)` 硬编码（第 26 行）
- "加入购物车"按钮通过 `Spacer()` 右对齐（第 51-71 行），非全宽
- 单列 `VStack` 布局，宽屏下内容偏左

```swift
// ======== 改动后 ========
@Environment(\.horizontalSizeClass) private var sizeClass

var body: some View {
    ScrollView {
        Group {
            if sizeClass == .regular {
                // 宽屏：左图右文双栏布局
                HStack(alignment: .top, spacing: 30) {
                    Image(product.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 500)
                        .cornerRadius(20)
                        .frame(maxWidth: .infinity)

                    detailContent
                        .frame(maxWidth: AdaptiveLayout.maxContentWidth)
                }
                .padding()
            } else {
                // 窄屏：保持原有单列布局
                VStack(alignment: .leading, spacing: 20) {
                    Image(product.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                        .cornerRadius(20)
                        .padding(.top, 16)
                    detailContent
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
            }
        }
    }
    .background(Color.backgroundPrimary)
}

// 提取公共内容区域
@ViewBuilder
private var detailContent: some View {
    VStack(alignment: .leading, spacing: 20) {
        Text(product.name).font(AppFont.title).padding(.top, 8)
        HStack { /* 品牌 + 价格 */ }
        // 加入购物车按钮（居中，限宽）
        Button(action: { ... }) {
            Label("加入购物车", systemImage: "cart.badge.plus")
                .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
        }
        .frame(maxWidth: .infinity)
        VStack(alignment: .leading, spacing: 8) { /* 描述区域 */ }
    }
}
```

---

### 3.5 LoginView — 登录页

**文件：** `Kix/Features/Auth/LoginView.swift`

**现状：**
- 无 `NavigationView`（作为根视图呈现）
- `.padding(.horizontal, 35)` 硬编码（第 139 行）
- 登录按钮 `.frame(maxWidth: .infinity)`（第 113 行）
- Logo 字号 100pt（第 27 行）
- `customField` 辅助函数（第 152-173 行）输入框 `height: 60`

```swift
// ======== 原代码（第 109-118 行） ========
Text("登录")
    .font(.system(size: 18, weight: .bold, design: .rounded))
    .kerning(2)
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)    // ← 宽屏下按钮拉满
    .frame(height: 60)
    .background(brandGradient)
    .cornerRadius(20)

// ======== 改动后 ========
Text("登录")
    .font(.system(size: 18, weight: .bold, design: .rounded))
    .kerning(2)
    .foregroundColor(.white)
    .frame(maxWidth: AdaptiveLayout.maxButtonWidth)  // ← 限制最大宽度
    .frame(height: 60)
    .background(brandGradient)
    .cornerRadius(20)
.frame(maxWidth: .infinity)  // 居中
```

```swift
// ======== 原代码（第 139 行） ========
.padding(.horizontal, 35)

// ======== 改动后 ========
.padding(.horizontal)
.frame(maxWidth: AdaptiveLayout.maxContentWidth)
.frame(maxWidth: .infinity)  // 居中
```

**customField 辅助函数（第 152-173 行）：**

```swift
// ======== 原代码 ========
.padding(.horizontal, 20)
.frame(height: 60)
.background(Color(.systemGray6).opacity(0.5))
.cornerRadius(18)

// ======== 改动后 ========
.padding(.horizontal, 20)
.frame(height: 60)
.frame(maxWidth: AdaptiveLayout.maxContentWidth)
.background(Color(.systemGray6).opacity(0.5))
.cornerRadius(18)
```

---

### 3.6 RegisterView — 注册页

**文件：** `Kix/Features/Auth/RegisterView.swift`

**现状：**
- 无 `NavigationView`（作为 `.sheet` 呈现）
- `.padding(.horizontal, 35)` 硬编码（第 133 行）
- 注册按钮 `.frame(maxWidth: .infinity)`（第 107 行）
- Logo 字号 80pt（第 31 行）
- `customField` 辅助函数（第 147-166 行）与 LoginView 结构一致

**改动与 LoginView 完全一致：**

```swift
// ======== 原代码（第 133 行） ========
.padding(.horizontal, 35)

// ======== 改动后 ========
.padding(.horizontal)
.frame(maxWidth: AdaptiveLayout.maxContentWidth)
.frame(maxWidth: .infinity)

// ======== 原代码（第 103-108 行） ========
Text("创建账号")
    .frame(maxWidth: .infinity)
    .frame(height: 60)

// ======== 改动后 ========
Text("创建账号")
    .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
    .frame(height: 60)
.frame(maxWidth: .infinity)  // 居中
```

---

### 3.7 FavoritesView — 收藏页

**文件：** `Kix/Features/Favorites/FavoritesView.swift`

**现状（与上一版方案描述不同）：**
- **已使用 `LazyVGrid` 双列布局**（第 44-47 行），并非 `List` + `HStack`
- `FavoriteCard` 组件（第 80-157 行），图片区 `.frame(height: 140)` 硬编码（第 96 行）
- 主视图 `NavigationView`（第 10 行）+ Sheet `NavigationView`（第 68 行）= **共 2 处**
- `.padding(.bottom, 100)` 硬编码（第 62 行）

```swift
// ======== 原代码（第 10 行） ========
NavigationView {

// ======== 改动后 ========
NavigationStack {
```

```swift
// ======== 原代码（第 44-62 行） ========
LazyVGrid(columns: [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible(), spacing: 12)
], spacing: 12) {
    ForEach(favoritesManager.favorites) { product in
        FavoriteCard(product: product, ...)
    }
}
.padding(.horizontal, 16)
.padding(.top, 16)
.padding(.bottom, 100)

// ======== 改动后 ========
@Environment(\.horizontalSizeClass) private var sizeClass

private var favoriteColumns: [GridItem] {
    if sizeClass == .regular {
        return [GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)]
    }
    return [GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)]
}

LazyVGrid(columns: favoriteColumns, spacing: 16) {
    ForEach(favoritesManager.favorites) { product in
        FavoriteCard(product: product, ...)
            .frame(maxWidth: AdaptiveLayout.maxCardWidth)
    }
}
.padding(.horizontal, 16)
.padding(.top, 16)
.padding(.bottom, 10)
```

```swift
// ======== 原代码（第 68 行，Sheet 内） ========
.sheet(item: $selectedProduct) { product in
    NavigationView {
        ProductDetailView(product: product)

// ======== 改动后 ========
.sheet(item: $selectedProduct) { product in
    NavigationStack {
        ProductDetailView(product: product)
    }
    .presentationSizing(.form)
```

```swift
// ======== FavoriteCard 图片区域（第 94-96 行） ========
// 原代码：
RoundedRectangle(cornerRadius: 16)
    .fill(bgGradient)
    .frame(height: 140)

// 改动后：
RoundedRectangle(cornerRadius: 16)
    .fill(bgGradient)
    .aspectRatio(1.0, contentMode: .fit)
```

---

### 3.8 NotesView — 笔记页

**文件：** `Kix/Features/Notes/NotesView.swift`

**现状（与上一版方案描述不同）：**
- 主视图 `NavigationView`（第 14 行）
- `NoteDetailView` 内 `NavigationView`（第 235 行）= **共 2 处**
- **使用已废弃的 `@Environment(\.presentationMode)`**（第 10 行）→ 需改为 `@Environment(\.dismiss)`
- 空状态使用 `.frame(maxWidth: .infinity, maxHeight: .infinity)`（第 80 行），**并非** `.padding(.bottom, 40)` 硬编码
- `.padding(.bottom, 100)` 在笔记列表区域（第 102 行）
- 输入区域使用 `TextField` + 图标按钮 `HStack`（第 32-50 行），无宽度限制

```swift
// ======== 原代码（第 10 行） ========
@Environment(\.presentationMode) var presentationMode

// ======== 改动后 ========
@Environment(\.dismiss) private var dismiss
```

```swift
// ======== 原代码（第 14 行） ========
NavigationView {

// ======== 改动后 ========
NavigationStack {
```

```swift
// ======== 原代码（第 31-63 行，输入区域） ========
VStack(spacing: 12) {
    HStack(spacing: 8) {
        TextField("快来写点什么吧...", text: $newNoteText, axis: .vertical)
            ...
        Button(action: addOrUpdateNote) {
            Image(systemName: editingNote == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                .font(.system(size: 32))
                ...
        }
    }
    // ...
}
.padding(.horizontal, 16)
.padding(.top, 16)

// ======== 改动后 ========
VStack(spacing: 12) {
    HStack(spacing: 8) {
        TextField("快来写点什么吧...", text: $newNoteText, axis: .vertical)
            ...
        Button(action: addOrUpdateNote) { ... }
    }
}
.frame(maxWidth: AdaptiveLayout.maxContentWidth)
.frame(maxWidth: .infinity)  // 居中
.padding(.horizontal, 16)
.padding(.top, 16)
```

```swift
// ======== 原代码（第 100-102 行） ========
.padding(.horizontal, 16)
.padding(.top, 16)
.padding(.bottom, 100)

// ======== 改动后 ========
.padding(.horizontal, 16)
.padding(.top, 16)
.padding(.bottom, 10)
```

```swift
// ======== NoteDetailView（第 235 行） ========
// 原代码：NavigationView {
// 改动后：NavigationStack {

// ======== NoteDetailView 编辑/删除按钮（第 268/283 行） ========
// 原代码：.frame(maxWidth: .infinity)
// 改动后：.frame(maxWidth: AdaptiveLayout.maxButtonWidth)
//         .frame(maxWidth: .infinity)  // 居中
```

---

### 3.9 MenuView — 菜单页

**文件：** `Kix/Features/Menu/MenuView.swift`

**现状：**
- `NavigationView`（第 19 行）= **1 处**
- 使用 `NavigationLink` 导航到 `ProfileDetailView`（第 36 行）
- 退出按钮 `.frame(maxWidth: .infinity)`（第 91 行）
- `Form` 内 `Section` 布局，图标 `width: 48, height: 48`（第 40 行）

```swift
// ======== 原代码（第 19 行） ========
NavigationView {

// ======== 改动后 ========
NavigationStack {
```

```swift
// ======== 原代码（第 88-99 行） ========
Button(action: { showLogoutAlert = true }) {
    Text("退出登录")
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .frame(maxWidth: .infinity)
        .padding(12)
        ...
}

// ======== 改动后 ========
Button(action: { showLogoutAlert = true }) {
    Text("退出登录")
        .font(.system(size: 18, weight: .bold, design: .rounded))
        .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
        .frame(maxWidth: .infinity)  // 居中
        .padding(12)
        ...
}
```

```swift
// ======== 新增：Form 限宽居中 ========
Form {
    // ... 保持现有 Section 不变 ...
}
.frame(maxWidth: AdaptiveLayout.maxContentWidth)
.frame(maxWidth: .infinity)  // 居中
```

---

### 3.10 CartView — 购物车页

**文件：** `Kix/Features/Cart/CartView.swift`

**现状（比上一版方案描述更复杂）：**
- 主视图 `NavigationView`（第 18 行）
- `CheckoutSuccessView` 内 `NavigationView`（第 365 行）
- `AddTestCardSheet` 内 `NavigationView`（第 453 行）
- = **共 3 处**
- 结算按钮 `.frame(maxWidth: .infinity)`（第 245 行）
- `CheckoutSuccessView` 成功图标 `Circle().frame(width: 120, height: 120)`（第 373 行）
- `.padding(.horizontal, 32)` 硬编码（第 417/437 行）
- 商品缩略图 `width: 60, height: 60`（第 94 行）

```swift
// ======== 原代码（第 18/365/453 行） ========
NavigationView {

// ======== 改动后（全部 3 处） ========
NavigationStack {
```

```swift
// ======== 原代码（第 241-253 行，结算按钮） ========
Text("去结算")
    .font(.system(size: 18, weight: .bold, design: .rounded))
    .kerning(1)
    .frame(maxWidth: .infinity)
    .padding()
    ...

// ======== 改动后 ========
Text("去结算")
    .font(.system(size: 18, weight: .bold, design: .rounded))
    .kerning(1)
    .frame(maxWidth: AdaptiveLayout.maxButtonWidth)
    .frame(maxWidth: .infinity)  // 居中
    .padding()
    ...
```

```swift
// ======== 原代码（第 213-258 行，底部结算区域） ========
VStack(spacing: 12) {
    HStack {
        Text("合计：").font(.title2)
        Spacer()
        Text("$...").font(.title2).bold()
    }
    Button(action: { ... }) { ... }
}
.padding([.horizontal, .bottom])

// ======== 改动后 ========
VStack(spacing: 12) {
    HStack {
        Text("合计：").font(.title2)
        Spacer()
        Text("$...").font(.title2).bold()
    }
    Button(action: { ... }) { ... }
}
.frame(maxWidth: AdaptiveLayout.maxContentWidth)
.frame(maxWidth: .infinity)  // 居中
.padding([.horizontal, .bottom])
```

```swift
// ======== CheckoutSuccessView（第 373 行） ========
// 原代码：
Circle()
    .fill(Color.green.opacity(0.2))
    .frame(width: 120, height: 120)

// 改动后：
Circle()
    .fill(Color.green.opacity(0.2))
    .aspectRatio(1, contentMode: .fit)
    .frame(maxWidth: 150)
```

```swift
// ======== AddTestCardSheet（第 453 行） ========
// 改动后加：
.presentationSizing(.form)
```

---

### 3.11 KixLogoView — Logo 组件（低优先级）

**文件：** `Kix/Core/Components/KixLogoView.swift`

**现状：** 此组件是 **App 图标生成器**（1024x1024），仅在 Preview 中使用，**未被任何 UI 页面引用**。

**建议：** 暂不改动。如未来用于启动画面，需做如下修改：

```swift
// ======== 原代码（第 57-58 行） ========
.frame(width: 1024, height: 1024)
.clipShape(RoundedRectangle(cornerRadius: 220, style: .continuous))

// ======== 改动后（仅当用于 UI 时） ========
.aspectRatio(1, contentMode: .fit)
.frame(maxWidth: 400)
.clipShape(RoundedRectangle(cornerRadius: 220, style: .continuous))
```

---

### 3.12 AuthRouterView — 认证路由

**文件：** `Kix/Features/Auth/AuthRouterView.swift`

**无需改动。** 仅做条件判断（`if appState.isAuthenticated`），子视图的尺寸类环境会自动传递。

---

## 四、iOS 27.1 & iPhone Duo 适配总方案

### 4.1 三层架构总览

```
┌─────────────────────────────────────────────────────────┐
│  L2 — Duo 增强（iOS 27.1+）                              │
│  • UIArrangementViewController（primary/secondary 分栏）  │
│  • reservedRegions(kind: .division / .occlusion)          │
│  • 通过 DuoArrangementView 桥接到 SwiftUI                 │
├─────────────────────────────────────────────────────────┤
│  L1 — 系统自适应（iOS 16+）                                │
│  • NavigationSplitView / NavigationStack                  │
│  • @Environment(\.horizontalSizeClass)                    │
│  • LazyVGrid 自适应列数                                   │
│  • AdaptiveContent 容器自动限宽居中                        │
├─────────────────────────────────────────────────────────┤
│  L0 — 基线合规                                            │
│  • 移除 UIScreen.main 引用                                │
│  • 移除硬编码宽度/高度/padding                              │
│  • 按钮/卡片/输入框加 maxWidth 约束                        │
│  • 图片使用 aspectRatio 替代固定 height                    │
│  • NavigationView → NavigationStack（11 处）               │
│  • @Environment(\.presentationMode) → .dismiss（1 处）     │
└─────────────────────────────────────────────────────────┘
```

### 4.2 版本兼容策略

```swift
// 部署目标保持 iOS 16.0
// 所有 iOS 27.1 API 调用使用版本门控：

if #available(iOS 27.1, *) {
    // 使用 UIArrangementViewController
    return AdaptiveListDetailViewController()
}
// 回退到 NavigationSplitView 或 UISplitViewController
return LegacySplitListDetailViewController()
```

### 4.3 各页面适配等级

| 页面 | L0 基线 | L1 自适应 | L2 Duo 增强 |
|------|---------|-----------|-------------|
| MainTabView | 无硬编码问题 | TabView → NavigationSplitView | 可选 Arrangement |
| HomeView | 卡片限宽、图片自适应、3 处 NavigationView | 单列 → 双列网格 | — |
| ProductCard（遗留） | 图片 aspectRatio | 限宽 | — |
| ProductDetailView | 按钮限宽 | 单栏 → 双栏（左图右文） | 可选 Arrangement |
| LoginView | padding 自适应、按钮限宽 | 内容居中限宽 | — |
| RegisterView | 同 LoginView | 同 LoginView | — |
| FavoritesView | 2 处 NavigationView、图片自适应 | 2 列 → 3 列网格 | — |
| NotesView | 2 处 NavigationView、废弃 API、输入行限宽 | 内容居中 | — |
| MenuView | 1 处 NavigationView、Form/按钮限宽 | 内容居中 | — |
| CartView | 3 处 NavigationView、按钮/结算区限宽 | 内容居中 | — |
| KixLogoView | **低优先级：图标生成器，未被 UI 引用** | — | — |

### 4.4 禁止事项（反模式）

| 禁止 | 原因 | 替代方案 |
|------|------|----------|
| `UIScreen.main.bounds` | Duo 多场景下不可靠 | `GeometryReader` / `sizeClass` |
| 固定 `.frame(width:)` | 无法适配不同屏幕宽度 | `.frame(maxWidth:)` |
| `UIDevice.current.orientation` | Duo 内屏不遵循传统方向语义 | `sizeClass` |
| `.frame(maxWidth: .infinity)` 用于按钮 | 宽屏下按钮拉伸到荒谬宽度 | `.frame(maxWidth: AdaptiveLayout.maxButtonWidth)` |
| 硬编码 `.padding(.horizontal, 35)` | 宽屏下内容区过宽 | `.padding(.horizontal)` + 内容限宽 |
| `.padding(.bottom, 100)` 预留标签栏 | 不同设备间距不一致 | 使用 `.safeAreaInset(edge: .bottom)` 或移除 |
| `NavigationView` | iOS 16+ 已废弃 | `NavigationStack` / `NavigationSplitView` |
| `@Environment(\.presentationMode)` | iOS 16+ 已废弃 | `@Environment(\.dismiss)` |

### 4.5 实施优先级

| 优先级 | 内容 | 预估工时 |
|--------|------|----------|
| P0 | 新建 AdaptiveLayout.swift + DuoArrangementView.swift | 1h |
| P0 | L0：全局 11 处 `NavigationView` → `NavigationStack` | 1h |
| P0 | L0：`@Environment(\.presentationMode)` → `.dismiss`（NotesView:10） | 0.2h |
| P0 | L0：移除 3 处 `.padding(.bottom, 100)` 硬编码 | 0.3h |
| P0 | L0：全局按钮/输入框加 `maxWidth` 约束（7 处） | 1h |
| P1 | L1：MainTabView 改为尺寸类判断（TabView ↔ NavigationSplitView） | 1.5h |
| P1 | L1：HomeView 单列 → 双列网格 + 图片 aspectRatio | 1h |
| P1 | L1：ProductDetailView 双栏布局 | 1h |
| P2 | L1：FavoritesView 2 列 → 3 列自适应 | 0.5h |
| P2 | L1：NotesView 输入行限宽居中 | 0.5h |
| P2 | L1：LoginView / RegisterView 限宽居中 | 0.5h |
| P2 | L1：MenuView / CartView 限宽居中 | 0.5h |
| P3 | L2：DuoArrangementView 集成测试 | 2h |
| P3 | 模拟器验证（折叠/展开两种状态） | 1h |
| **总计** | | **~12h** |

---

## 五、验证清单

- [ ] iPhone 16（窄屏）：所有页面布局不变
- [ ] iPhone Duo 折叠态（~6.3"）：等同于普通 iPhone
- [ ] iPhone Duo 展开态（~7.6" / regular width）：
  - [ ] MainTabView 显示侧边栏
  - [ ] HomeView 商品双列排列，卡片宽度不超过 500pt
  - [ ] ProductDetailView 左图右文
  - [ ] LoginView / RegisterView 内容居中不拉伸
  - [ ] 所有按钮宽度不超过 400pt
  - [ ] FavoritesView 显示 3 列卡片
  - [ ] NotesView 输入行居中限宽
  - [ ] CartView 结算区域居中限宽
- [ ] iOS 27.1 真机：`reservedRegions` 正确避让铰链区域
- [ ] iOS 16-26 回退：`NavigationSplitView` 正常工作
- [ ] 所有 11 处 `NavigationView` 已替换为 `NavigationStack`，无编译警告
- [ ] `@Environment(\.presentationMode)` 已替换为 `@Environment(\.dismiss)`

---

## 六、与上一版方案差异说明

| 差异项 | 上一版（2026-10-26） | 本版（2026-10-27） |
|--------|---------------------|-------------------|
| NavigationView 数量 | 8 处 | **11 处**（含 EditProductSheet、NoteDetailView、CheckoutSuccessView、AddTestCardSheet） |
| FavoritesView 原代码 | 描述为 `List` + `HStack` 行 | **实际已使用 `LazyVGrid` 双列**，改动为 2→3 列自适应 |
| NotesView 空状态 | 描述为 `.padding(.bottom, 40)` | **实际为 `.frame(maxWidth: .infinity, maxHeight: .infinity)`** |
| NotesView 废弃 API | 未提及 | **新增：`@Environment(\.presentationMode)` → `.dismiss`** |
| KixLogoView | 列为需改动组件 | **降级为低优先级：图标生成器，未被 UI 引用** |
| ProductCard | 列为主要改动 | **标注为遗留代码，HomeView 使用 NewProductCard** |
| CartView NavigationView | 1 处 | **实际 3 处**（主视图 + CheckoutSuccessView + AddTestCardSheet） |
| MainTabView environmentObject | 部分遗漏 | **补全：HomeView/FavoritesView 注入 favoritesManager + cartManager + tabSelection** |
