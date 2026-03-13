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
    private var headerTopConstraint: NSLayoutConstraint!
    private var rnBottomConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startFirestore()
        setupReactNative()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Use the window's safe area (device-level) to bypass any
        // additionalSafeAreaInsets injected by RCTReactNativeFactory.
        let safeTop = view.window?.safeAreaInsets.top ?? 59
        let safeBottom = view.window?.safeAreaInsets.top != nil
            ? view.window!.safeAreaInsets.bottom : 34
        headerTopConstraint.constant = safeTop + 16
        rnBottomConstraint.constant = -safeBottom
    }

    private func setupUI() {
        let pad = Theme.contentPadding
        let gap = Theme.sectionGap

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
        headerTextStack.translatesAutoresizingMaskIntoConstraints = false

        let bellButton = UIButton(type: .system)
        bellButton.setImage(UIImage(systemName: "bell"), for: .normal)
        bellButton.tintColor = Theme.dark
        bellButton.translatesAutoresizingMaskIntoConstraints = false

        // Balance card
        balanceCard.translatesAutoresizingMaskIntoConstraints = false
        balanceCard.setContentHuggingPriority(.required, for: .vertical)
        balanceCard.setContentCompressionResistancePriority(.required, for: .vertical)

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
        buttonsStack.translatesAutoresizingMaskIntoConstraints = false

        // Transactions header
        let txnTitle = UILabel()
        txnTitle.text = "Transactions"
        txnTitle.font = Theme.headingFont(size: 18)
        txnTitle.textColor = Theme.dark
        txnTitle.translatesAutoresizingMaskIntoConstraints = false

        let seeAllLabel = UILabel()
        seeAllLabel.text = "See all"
        seeAllLabel.font = Theme.bodyMediumFont(size: 13)
        seeAllLabel.textColor = Theme.coral
        seeAllLabel.translatesAutoresizingMaskIntoConstraints = false

        // RN container
        rnContainer.translatesAutoresizingMaskIntoConstraints = false
        rnContainer.backgroundColor = .clear

        // Add subviews directly — avoids UIStackView ambiguity with views
        // that lack intrinsic content size (balanceCard, rnContainer)
        view.addSubview(headerTextStack)
        view.addSubview(bellButton)
        view.addSubview(balanceCard)
        view.addSubview(buttonsStack)
        view.addSubview(txnTitle)
        view.addSubview(seeAllLabel)
        view.addSubview(rnContainer)

        // Pin to view.topAnchor / bottomAnchor (not safeAreaLayoutGuide)
        // because RCTReactNativeFactory inflates additionalSafeAreaInsets.
        // The correct offsets are applied in viewDidLayoutSubviews using
        // the window's device-level safe area insets.
        headerTopConstraint = headerTextStack.topAnchor.constraint(equalTo: view.topAnchor, constant: 75)
        rnBottomConstraint = rnContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -34)

        NSLayoutConstraint.activate([
            headerTopConstraint,
            headerTextStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            bellButton.centerYAnchor.constraint(equalTo: headerTextStack.centerYAnchor),
            bellButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            // Balance card
            balanceCard.topAnchor.constraint(equalTo: headerTextStack.bottomAnchor, constant: gap),
            balanceCard.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            balanceCard.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            // Action buttons
            buttonsStack.topAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: gap),
            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            // Transactions header
            txnTitle.topAnchor.constraint(equalTo: buttonsStack.bottomAnchor, constant: gap),
            txnTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            seeAllLabel.centerYAnchor.constraint(equalTo: txnTitle.centerYAnchor),
            seeAllLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

            // RN container fills remaining space
            rnContainer.topAnchor.constraint(equalTo: txnTitle.bottomAnchor, constant: Theme.gap),
            rnContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            rnContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),
            rnBottomConstraint,
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
