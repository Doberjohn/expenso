//
//  TransactionBridge.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import Foundation
import React

@objc(TransactionBridge)
class TransactionBridge: RCTEventEmitter {

    static var shared: TransactionBridge?

    override init() {
        super.init()
        TransactionBridge.shared = self

        // Firestore data may have arrived before the bridge was ready — send it now
        let txns = FirestoreService.shared.transactions
        if !txns.isEmpty {
            DispatchQueue.main.async {
                self.sendTransactions(txns)
            }
        }
    }

    override func supportedEvents() -> [String]! {
        return ["onTransactionsUpdate"]
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc func deleteTransaction(_ id: String) {
        FirestoreService.shared.deleteTransaction(id: id)
    }

    func sendTransactions(_ transactions: [Transaction]) {
        let data = transactions.map { $0.toDictionary() }
        sendEvent(withName: "onTransactionsUpdate", body: data)
    }
}
