//
//  TransactionType.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import Foundation
import FirebaseFirestore

enum TransactionType: String, Codable {
    case expense
    case income
}

enum PaidBy: String, Codable {
    case John
    case Christina
}

struct Transaction: Identifiable {
    let id: String
    let amount: Double
    let type: TransactionType
    let categoryName: String
    let note: String
    let paidBy: PaidBy
    let date: Date
    let createdAt: Date

    var category: Category {
        resolveCategory(name: categoryName)
    }

    /// Serialize for passing to React Native later
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "amount": amount,
            "type": type.rawValue,
            "category": [
                "name": category.name,
                "icon": lucideIconName,
                "color": category.color.hexString,
                "bgColor": category.bgColor.hexString,
                "type": category.type.rawValue,
            ],
            "note": note,
            "paidBy": paidBy.rawValue,
            "date": date.timeIntervalSince1970 * 1000,
        ]
    }

    private var lucideIconName: String {
        let map: [String: String] = [
            "Λαϊκή": "ShoppingBasket",
            "Supermarket": "ShoppingCart",
            "Βενζίνη": "Fuel",
            "Διατροφολόγος": "Apple",
            "Φαγητό": "Utensils",
            "Καφές": "Coffee",
            "Εύα": "Dumbbell",
            "Ανανέωση υπολοίπου": "RefreshCw",
            "Άλλο": "MoreHorizontal",
        ]
        return map[categoryName] ?? "MoreHorizontal"
    }
}

extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
