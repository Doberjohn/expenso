//
//  MainViewController.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import UIKit
import React
import React_RCTAppDelegate

class ReactNativeDelegate: RCTDefaultReactNativeFactoryDelegate {
    override func sourceURL(for bridge: RCTBridge) -> URL? {
        return bundleURL()
    }

    override func bundleURL() -> URL? {
        #if DEBUG
        return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index")
        #else
        return Bundle.main.url(forResource: "main", withExtension: "jsbundle")
        #endif
    }
}

class MainViewController: UIViewController, AddEntryDelegate {

    private let balanceCard = BalanceCardView()
    private let rnContainer = UIView()
    private var reactNativeFactory: RCTReactNativeFactory?
    private var reactNativeDelegate: ReactNativeDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startFirestore()
        setupReactNative()
    }

    private func setupUI() {
        // Header
        let greetingLabel = UILabel()
        greetingLabel.text = "Good morning,"
        greetingLabel.font = Theme.bodyFont(size: 13)
        greetingLabel.textColor = Theme.muted

        let namesLabel = UILabel()
        namesLabel.text = "John & Christina"
        namesLabel.font = Theme.headingFont(size: 24)
        namesLabel.textColor = Theme.dark

        let headerTextStack = UIStackView(arrangedSubviews: [greetingLabel, namesLabel])
        headerTextStack.axis = .vertical
        headerTextStack.spacing = 2

        let bellButton = UIButton(type: .system)
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = Theme.dark

        let headerStack = UIStackView(arrangedSubviews: [headerTextStack, bellButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing
        headerStack.alignment = .center
        headerStack.setContentHuggingPriority(.required, for: .vertical)

        // Balance card
        balanceCard.translatesAutoresizingMaskIntoConstraints = false
        balanceCard.setContentHuggingPriority(.required, for: .vertical)

        // Action buttons
        let expenseBtn = ActionButton(title: "Expense", sfSymbol: "minus",
                                      color: Theme.red, bgColor: Theme.redBg)
        expenseBtn.addTarget(self, action: #selector(expenseTapped), for: .touchUpInside)

        let incomeBtn = ActionButton(title: "Income", sfSymbol: "plus",
                                     color: Theme.green, bgColor: Theme.greenBg)
        incomeBtn.addTarget(self, action: #selector(incomeTapped), for: .touchUpInside)

        let buttonsStack = UIStackView(arrangedSubviews: [incomeBtn, expenseBtn])
        buttonsStack.axis = .horizontal
        buttonsStack.spacing = Theme.gap
        buttonsStack.distribution = .fillEqually

        // Transactions header
        let txnTitle = UILabel()
        txnTitle.text = "Transactions"
        txnTitle.font = Theme.headingFont(size: 18)
        txnTitle.textColor = Theme.dark

        let seeAllLabel = UILabel()
        seeAllLabel.text = "See all"
        seeAllLabel.font = Theme.bodyMediumFont(size: 13)
        seeAllLabel.textColor = Theme.coral

        let txnHeaderStack = UIStackView(arrangedSubviews: [txnTitle, seeAllLabel])
        txnHeaderStack.axis = .horizontal
        txnHeaderStack.distribution = .equalSpacing

        // RN container — should expand to fill remaining space
        rnContainer.translatesAutoresizingMaskIntoConstraints = false
        rnContainer.backgroundColor = .clear
        rnContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
        rnContainer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        // Main stack
        let mainStack = UIStackView(arrangedSubviews: [
            headerStack, balanceCard, buttonsStack, txnHeaderStack, rnContainer
        ])
        mainStack.axis = .vertical
        mainStack.spacing = Theme.sectionGap
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.contentPadding),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.contentPadding),
            mainStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            rnContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
        ])
    }

    // MARK: - React Native

    private func setupReactNative() {
        reactNativeDelegate = ReactNativeDelegate()
        reactNativeFactory = RCTReactNativeFactory(delegate: reactNativeDelegate!)

        let initialTransactions = FirestoreService.shared.transactions.map { $0.toDictionary() }
        let rootView = reactNativeFactory!.rootViewFactory.view(
            withModuleName: "TransactionList",
            initialProperties: ["transactions": initialTransactions]
        )

        rootView.translatesAutoresizingMaskIntoConstraints = false
        rnContainer.addSubview(rootView)
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: rnContainer.topAnchor),
            rootView.leadingAnchor.constraint(equalTo: rnContainer.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: rnContainer.trailingAnchor),
            rootView.bottomAnchor.constraint(equalTo: rnContainer.bottomAnchor),
        ])
    }

    // MARK: - Firestore

    private func startFirestore() {
        FirestoreService.shared.onTotalsUpdate = { [weak self] current, previous in
            DispatchQueue.main.async {
                self?.balanceCard.update(total: current, previousMonthTotal: previous)
            }
        }

        FirestoreService.shared.onTransactionsUpdate = { txns in
            DispatchQueue.main.async {
                TransactionBridge.shared?.sendTransactions(txns)
            }
        }

        FirestoreService.shared.startListening()
    }

    // MARK: - Actions

    @objc private func expenseTapped() {
        presentAddEntry(type: .expense)
    }

    @objc private func incomeTapped() {
        presentAddEntry(type: .income)
    }

    private func presentAddEntry(type: TransactionType) {
        let addVC = AddEntryViewController(type: type)
        addVC.delegate = self

        if let sheet = addVC.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = Theme.sheetRadius
        }

        present(addVC, animated: true)
    }

    // MARK: - AddEntryDelegate

    func didAddEntry() {
        // Firestore listener automatically updates everything
    }
}
