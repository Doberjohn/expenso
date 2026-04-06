//
//  FirestoreService.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()
    private let collectionName = "transactions"
    private var listener: ListenerRegistration?

    var onTransactionsUpdate: (([Transaction]) -> Void)?
    var onTotalsUpdate: ((Double, Double) -> Void)?

    private(set) var transactions: [Transaction] = []

    private init() {}

    // MARK: - Listener

    func startListening() {
        let query = db.collection(collectionName)
            .order(by: "createdAt", descending: true)

        listener = query.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self, let docs = snapshot?.documents else {
                print("Firestore error: \(error?.localizedDescription ?? "unknown")")
                return
            }

            self.transactions = docs.compactMap { doc in
                let data = doc.data()
                guard let amount = data["amount"] as? Double,
                      let typeStr = data["type"] as? String,
                      let type = TransactionType(rawValue: typeStr),
                      let categoryName = data["category"] as? String,
                      let paidByStr = data["paidBy"] as? String,
                      let paidBy = PaidBy(rawValue: paidByStr),
                      let dateTS = data["date"] as? Timestamp,
                      let createdAtTS = data["createdAt"] as? Timestamp
                else { return nil }

                return Transaction(
                    id: doc.documentID,
                    amount: amount,
                    type: type,
                    categoryName: categoryName,
                    note: data["note"] as? String ?? "",
                    paidBy: paidBy,
                    date: dateTS.dateValue(),
                    createdAt: createdAtTS.dateValue()
                )
            }

            self.onTransactionsUpdate?(self.transactions)
            self.onTotalsUpdate?(self.grandTotal, self.currentMonthTotal)
        }
    }

    func stopListening() {
        listener?.remove()
    }

    // MARK: - CRUD

    func addTransaction(amount: Double, type: TransactionType, categoryName: String,
                        note: String, paidBy: PaidBy) {
        db.collection(collectionName).addDocument(data: [
            "amount": amount,
            "type": type.rawValue,
            "category": categoryName,
            "note": note,
            "paidBy": paidBy.rawValue,
            "date": Timestamp(date: Date()),
            "createdAt": Timestamp(date: Date()),
        ])
    }

    func deleteTransaction(id: String) {
        db.collection(collectionName).document(id).delete()
    }

    // MARK: - Totals

    var grandTotal: Double {
        transactions.reduce(0.0) { sum, t in
            t.type == .income ? sum + t.amount : sum - t.amount
        }
    }

    var currentMonthTotal: Double {
        let now = Date()
        let cal = Calendar.current
        let month = cal.component(.month, from: now)
        let year = cal.component(.year, from: now)

        return transactions
            .filter {
                cal.component(.month, from: $0.date) == month &&
                cal.component(.year, from: $0.date) == year
            }
            .reduce(0.0) { sum, t in
                t.type == .income ? sum + t.amount : sum - t.amount
            }
    }

    var previousMonthTotal: Double {
        let now = Date()
        let cal = Calendar.current
        guard let prevDate = cal.date(byAdding: .month, value: -1, to: now) else { return 0 }
        let month = cal.component(.month, from: prevDate)
        let year = cal.component(.year, from: prevDate)

        return transactions
            .filter {
                cal.component(.month, from: $0.date) == month &&
                cal.component(.year, from: $0.date) == year
            }
            .reduce(0.0) { sum, t in
                t.type == .income ? sum + t.amount : sum - t.amount
            }
    }
}
