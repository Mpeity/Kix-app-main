import Foundation
import Combine

enum CardBrand: String, CaseIterable, Identifiable, Codable {
    case visa = "Visa"
    case masterCard = "Mastercard"
    case amex = "AmEx"
    case other = "Other"
    
    var id: String { rawValue }
    
    var testNumber: String {
        switch self {
        case .visa: return "4111 1111 1111 1111"
        case .masterCard: return "5555 5555 5555 4444"
        case .amex: return "3782 822463 10005"
        case .other: return "4000 0000 0000 0002"
        }
    }
}

struct PaymentMethod: Identifiable, Codable, Equatable {
    let id: UUID
    var brand: CardBrand
    var holderName: String
    var numberMasked: String
    var expiryMonth: Int
    var expiryYear: Int
    
    init(id: UUID = UUID(), brand: CardBrand, holderName: String, numberMasked: String, expiryMonth: Int, expiryYear: Int) {
        self.id = id
        self.brand = brand
        self.holderName = holderName
        self.numberMasked = numberMasked
        self.expiryMonth = expiryMonth
        self.expiryYear = expiryYear
    }
}

final class PaymentManager: ObservableObject {
    @Published private(set) var methods: [PaymentMethod] = [] {
        didSet {
            saveToDisk()
        }
    }
    @Published var selectedMethodID: UUID? = nil {
        didSet {
            saveToDisk()
        }
    }
    
    private let methodsKey = "kix_payment_methods"
    private let selectedMethodKey = "kix_selected_payment_method"
    
    init() {
        loadFromDisk()
    }
    
    func addTestCard(brand: CardBrand, holderName: String = "测试用户", expiryMonth: Int = 12, expiryYear: Int = 2030) {
        let masked = Self.mask(cardNumber: brand.testNumber)
        let method = PaymentMethod(brand: brand, holderName: holderName, numberMasked: masked, expiryMonth: expiryMonth, expiryYear: expiryYear)
        methods.append(method)
        selectedMethodID = method.id
    }
    
    func remove(_ method: PaymentMethod) {
        methods.removeAll { $0.id == method.id }
        if selectedMethodID == method.id { selectedMethodID = methods.first?.id }
    }
    
    func select(_ method: PaymentMethod) {
        selectedMethodID = method.id
    }
    
    var selectedMethod: PaymentMethod? {
        methods.first(where: { $0.id == selectedMethodID })
    }
    
    static func mask(cardNumber: String) -> String {
        let digits = cardNumber.replacingOccurrences(of: " ", with: "")
        guard digits.count >= 4 else { return cardNumber }
        let suffix = digits.suffix(4)
        return "•••• •••• •••• \(suffix)"
    }
    
    // MARK: - 本地缓存
    
    private func saveToDisk() {
        do {
            let methodsData = try JSONEncoder().encode(methods)
            UserDefaults.standard.set(methodsData, forKey: methodsKey)
            
            if let selectedID = selectedMethodID {
                let idData = try JSONEncoder().encode(selectedID)
                UserDefaults.standard.set(idData, forKey: selectedMethodKey)
            } else {
                UserDefaults.standard.removeObject(forKey: selectedMethodKey)
            }
        } catch {
            print("保存支付方式数据失败：\(error)")
        }
    }
    
    private func loadFromDisk() {
        // 加载支付方式列表
        if let methodsData = UserDefaults.standard.data(forKey: methodsKey) {
            do {
                methods = try JSONDecoder().decode([PaymentMethod].self, from: methodsData)
            } catch {
                print("加载支付方式数据失败：\(error)")
            }
        }
        
        // 加载选中的支付方式
        if let idData = UserDefaults.standard.data(forKey: selectedMethodKey) {
            do {
                selectedMethodID = try JSONDecoder().decode(UUID?.self, from: idData)
            } catch {
                print("加载选中支付方式失败：\(error)")
            }
        }
    }
}

