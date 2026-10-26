//
//  KixUITests.swift
//  KixUITests
//
//  由 Konstanty Halets 创建于 2026/01/06。
//

import XCTest

final class KixUITests: XCTestCase {

    override func setUpWithError() throws {
        // 在此处放置初始化代码。此方法在类中每个测试方法调用之前执行。

        // 在 UI 测试中，通常最好在发生失败时立即停止。
        continueAfterFailure = false

        // 在 UI 测试中，在测试运行之前设置所需的初始状态（如界面方向）非常重要。setUp 方法是进行此操作的好地方。
    }

    override func tearDownWithError() throws {
        // 在此处放置清理代码。此方法在类中每个测试方法调用之后执行。
    }

    @MainActor
    func testExample() throws {
        // UI 测试必须启动它们所测试的应用程序。
        let app = XCUIApplication()
        app.launch()

        // 使用 XCTAssert 及相关函数来验证测试是否产生正确结果。
    }

    @MainActor
    func testLaunchPerformance() throws {
        // 此测试测量应用程序启动所需的时间。
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }

    @MainActor
    func testLoginFlow() throws {
        let app = XCUIApplication()
        app.launch()
        let emailField = app.textFields["login_email_field"]
        let passwordField = app.secureTextFields["login_password_field"]
        let loginButton = app.buttons["login_button"]
        XCTAssertTrue(emailField.exists)
        XCTAssertTrue(passwordField.exists)
        XCTAssertTrue(loginButton.exists)
        emailField.tap()
        emailField.typeText("test@example.com")
        passwordField.tap()
        passwordField.typeText("password")
        loginButton.tap()
        // 登录后检查主标签栏
        XCTAssertTrue(app.tabBars.buttons["tab_home"].exists)
    }

    @MainActor
    func testAddToCart() throws {
        let app = XCUIApplication()
        app.launch()
        // 先登录
        let emailField = app.textFields["login_email_field"]
        if emailField.exists {
            emailField.tap()
            emailField.typeText("test@example.com")
            let passwordField = app.secureTextFields["login_password_field"]
            passwordField.tap()
            passwordField.typeText("password")
            app.buttons["login_button"].tap()
        }
        // 从第一个商品卡片添加到购物车
        let addToCartButton = app.buttons.matching(identifier: "add_to_cart_button_").firstMatch
        XCTAssertTrue(addToCartButton.waitForExistence(timeout: 2))
        addToCartButton.tap()
        app.tabBars.buttons["tab_cart"].tap()
        XCTAssertTrue(app.staticTexts["cart_total_price"].exists)
    }

    @MainActor
    func testSwitchTabs() throws {
        let app = XCUIApplication()
        app.launch()
        // 先登录
        let emailField = app.textFields["login_email_field"]
        if emailField.exists {
            emailField.tap()
            emailField.typeText("test@example.com")
            let passwordField = app.secureTextFields["login_password_field"]
            passwordField.tap()
            passwordField.typeText("password")
            app.buttons["login_button"].tap()
        }
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.buttons["tab_home"].exists)
        XCTAssertTrue(tabBar.buttons["tab_notes"].exists)
        XCTAssertTrue(tabBar.buttons["tab_favorites"].exists)
        XCTAssertTrue(tabBar.buttons["tab_menu"].exists)
        XCTAssertTrue(tabBar.buttons["tab_cart"].exists)
        tabBar.buttons["tab_favorites"].tap()
        XCTAssertTrue(app.staticTexts["favorites_title"].exists)
    }

    @MainActor
    func testFavoriteProduct() throws {
        let app = XCUIApplication()
        app.launch()
        // 先登录
        let emailField = app.textFields["login_email_field"]
        if emailField.exists {
            emailField.tap()
            emailField.typeText("test@example.com")
            let passwordField = app.secureTextFields["login_password_field"]
            passwordField.tap()
            passwordField.typeText("password")
            app.buttons["login_button"].tap()
        }
        let favoriteButton = app.buttons.matching(identifier: "favorite_button_").firstMatch
        XCTAssertTrue(favoriteButton.waitForExistence(timeout: 2))
        favoriteButton.tap()
        app.tabBars.buttons["tab_favorites"].tap()
        XCTAssertTrue(app.staticTexts["favorites_title"].exists)
    }

    @MainActor
    func testCheckoutButtonTap() throws {
        let app = XCUIApplication()
        app.launch()
        // 先登录
        let emailField = app.textFields["login_email_field"]
        if emailField.exists {
            emailField.tap()
            emailField.typeText("test@example.com")
            let passwordField = app.secureTextFields["login_password_field"]
            passwordField.tap()
            passwordField.typeText("password")
            app.buttons["login_button"].tap()
        }
        // 如需要则添加到购物车
        let addToCartButton = app.buttons.matching(identifier: "add_to_cart_button_").firstMatch
        if addToCartButton.exists {
            addToCartButton.tap()
        }
        app.tabBars.buttons["tab_cart"].tap()
        let checkoutButton = app.buttons["checkout_button"]
        XCTAssertTrue(checkoutButton.exists)
        checkoutButton.tap()
        // 可选：检查确认界面
    }
}
