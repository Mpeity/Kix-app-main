//
//  KixTests.swift
//  KixTests
//
//  由 Konstanty Halets 创建于 2026/01/06。
//

import XCTest
@testable import Kix

final class KixTests: XCTestCase {

    override func setUpWithError() throws {
        // 在此处放置初始化代码。此方法在类中每个测试方法调用之前执行。
    }

    override func tearDownWithError() throws {
        // 在此处放置清理代码。此方法在类中每个测试方法调用之后执行。
    }

    func testExample() throws {
        // 这是一个功能测试用例的示例。
        // 使用 XCTAssert 及相关函数来验证测试是否产生正确结果。
        // 你编写的任何 XCTest 测试都可以标记为 throws 和 async。
        // 标记 throws 可在测试遇到未捕获错误时产生意外失败。
        // 标记 async 可等待异步代码完成。之后通过断言检查结果。
    }

    func testPerformanceExample() throws {
        // 这是一个性能测试用例的示例。
        self.measure {
            // 在此处放置你想要测量执行时间的代码。
        }
    }

    func testCartCalculations() throws {
        let cartManager = CartManager()
        let product1 = Product(id: UUID(), name: "Test Shoe 1", brand: "BrandA", price: 100, imageName: "", isFavorite: false, description: "")
        let product2 = Product(id: UUID(), name: "Test Shoe 2", brand: "BrandB", price: 200, imageName: "", isFavorite: false, description: "")
        cartManager.addToCart(product: product1)
        cartManager.addToCart(product: product2)
        cartManager.addToCart(product: product2)
        XCTAssertEqual(cartManager.items.count, 2)
        XCTAssertEqual(cartManager.items.first(where: { $0.product.id == product1.id })?.quantity, 1)
        XCTAssertEqual(cartManager.items.first(where: { $0.product.id == product2.id })?.quantity, 2)
        XCTAssertEqual(cartManager.totalPrice(), 500)
        cartManager.decreaseQuantity(item: cartManager.items.first(where: { $0.product.id == product2.id })!)
        XCTAssertEqual(cartManager.items.first(where: { $0.product.id == product2.id })?.quantity, 1)
        cartManager.clearCart()
        XCTAssertEqual(cartManager.items.count, 0)
    }

    func testFavoritesLogic() throws {
        let favoritesManager = FavoritesManager()
        let product = Product(id: UUID(), name: "Test Shoe", brand: "BrandA", price: 100, imageName: "", isFavorite: false, description: "")
        XCTAssertFalse(favoritesManager.isFavorite(product))
        favoritesManager.toggleFavorite(product)
        XCTAssertTrue(favoritesManager.isFavorite(product))
        favoritesManager.toggleFavorite(product)
        XCTAssertFalse(favoritesManager.isFavorite(product))
    }

    func testNotesCRUD() throws {
        let notesManager = NotesManager()
        notesManager.addNote(text: "First note")
        XCTAssertEqual(notesManager.notes.count, 1)
        let note = notesManager.notes.first!
        notesManager.updateNote(note, newText: "Updated note")
        XCTAssertEqual(notesManager.notes.first?.text, "Updated note")
        notesManager.deleteNote(note)
        XCTAssertEqual(notesManager.notes.count, 0)
    }

}
