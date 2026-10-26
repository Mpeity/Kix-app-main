//
//  KixUITestsLaunchTests.swift
//  KixUITests
//
//  由 Konstanty Halets 创建于 2026/01/06。
//

import XCTest

final class KixUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // 在此处插入应用启动后、截图前需要执行的步骤，
        // 例如登录测试账户或在应用中导航到某个页面

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
