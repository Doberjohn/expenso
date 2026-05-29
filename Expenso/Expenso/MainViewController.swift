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
        additionalSafeAreaInsets = .zero
        setupUI()
        startFirestore()
        setupReactNative()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Debug: log safe area to verify correctness — remove once confirmed
        print("[Layout Debug] safeAreaInsets=\(view.safeAreaInsets), additional=\(additionalSafeAreaInsets)")
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Prevent any external code from inflating safe area
        if additionalSafeAreaInsets != .zero {
            print("[Layout Debug] Resetting additionalSafeAreaInsets from \(additionalSafeAreaInsets)")
            additionalSafeAreaInsets = .zero
        }
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

        // RN container
        rnContainer.translatesAutoresizingMaskIntoConstraints = false
        rnContainer.backgroundColor = .clear
        rnContainer.clipsToBounds = true

        // Add subviews directly — avoids UIStackView ambiguity with views
        // that lack intrinsic content size (balanceCard, rnContainer)
        view.addSubview(headerTextStack)
        view.addSubview(balanceCard)
        view.addSubview(buttonsStack)
        view.addSubview(txnTitle)
        view.addSubview(rnContainer)

        NSLayoutConstraint.activate([
            headerTextStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerTextStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            headerTextStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),

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

        ])

        // RN container constraints use lower priority to prevent the RN
        // layout cycle (RCTSurfaceHostingView.layoutSubviews → invalidate
        // IntrinsicContentSize) from disrupting the native constraint chain.
        let rnConstraints: [NSLayoutConstraint] = [
            rnContainer.topAnchor.constraint(equalTo: txnTitle.bottomAnchor, constant: Theme.gap),
            rnContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: pad),
            rnContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -pad),
            rnContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ]
        rnConstraints.forEach { $0.priority = .defaultHigh }
        NSLayoutConstraint.activate(rnConstraints)
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

        // Use autoresizing mask (not Auto Layout) for the RN root view.
        // RCTSurfaceHostingView.layoutSubviews recalculates viewport offset
        // and calls invalidateIntrinsicContentSize, which causes a cascading
        // layout loop when connected to the Auto Layout constraint solver.
        rootView.frame = rnContainer.bounds
        rootView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        rnContainer.addSubview(rootView)
    }

    // MARK: - Firestore

    private func startFirestore() {
        FirestoreService.shared.onTotalsUpdate = { [weak self] current, previous in
            DispatchQueue.main.async {
              self?.balanceCard.update(total: current, currentMonthTotal: previous)
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
