//
//  AddEntryDelegate.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import UIKit

protocol AddEntryDelegate: AnyObject {
    func didAddEntry()
}

class AddEntryViewController: UIViewController {

    weak var delegate: AddEntryDelegate?

    private let entryType: TransactionType

    private let amountField = UITextField()
    private let categoryButton = UIButton(type: .system)
    private let noteField = UITextField()
    private let noteContainer = UIView()
    private var paidBy: PaidBy = .Christina
    private var categoryIndex = 0
    private let johnButton = UIButton(type: .system)
    private let christinaButton = UIButton(type: .system)

    private var relevantCategories: [Category] {
        categories.filter { $0.type == .both || $0.type.rawValue == entryType.rawValue }
    }

    init(type: TransactionType) {
        self.entryType = type
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        updateCategoryDisplay()
        updatePaidByDisplay()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        amountField.becomeFirstResponder()
    }

    private func setupUI() {
        let isExpense = entryType == .expense

        // Title
        let titleLabel = UILabel()
        titleLabel.text = isExpense ? "New Expense" : "New Income"
        titleLabel.font = Theme.headingFont(size: 20)
        titleLabel.textColor = Theme.dark

        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = Theme.muted
        closeButton.backgroundColor = Theme.cardBg
        closeButton.layer.cornerRadius = 16
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        let headerStack = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerStack.axis = .horizontal
        headerStack.distribution = .equalSpacing

        // Amount
        let amountLabel = UILabel()
        amountLabel.text = "Amount"
        amountLabel.font = Theme.bodyMediumFont(size: 12)
        amountLabel.textColor = Theme.muted
        amountLabel.textAlignment = .center

        let euroSign = UILabel()
        euroSign.text = "€"
        euroSign.font = Theme.headingBlackFont(size: 40)
        euroSign.textColor = Theme.dark

        amountField.font = Theme.headingBlackFont(size: 40)
        amountField.textColor = Theme.dark
        amountField.keyboardType = .decimalPad
        amountField.textAlignment = .center
        amountField.placeholder = "0.00"

        let amountRow = UIStackView(arrangedSubviews: [euroSign, amountField])
        amountRow.axis = .horizontal
        amountRow.alignment = .center
        amountRow.spacing = 4

        let amountContainer = UIStackView(arrangedSubviews: [amountLabel, amountRow])
        amountContainer.axis = .vertical
        amountContainer.alignment = .center
        amountContainer.spacing = 6

        // Category
        categoryButton.backgroundColor = Theme.cardBg
        categoryButton.layer.cornerRadius = Theme.inputRadius
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        buildCategoryMenu()

        // Note
        noteField.placeholder = "Add a note..."
        noteField.font = Theme.bodyFont(size: 14)
        noteField.textColor = Theme.dark

        noteContainer.backgroundColor = Theme.cardBg
        noteContainer.layer.cornerRadius = Theme.inputRadius
        noteContainer.isHidden = true

        let noteIcon = UIImageView(image: UIImage(systemName: "pencil"))
        noteIcon.tintColor = Theme.muted
        noteIcon.translatesAutoresizingMaskIntoConstraints = false

        noteField.translatesAutoresizingMaskIntoConstraints = false
        noteContainer.addSubview(noteIcon)
        noteContainer.addSubview(noteField)
        noteContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteContainer.heightAnchor.constraint(equalToConstant: 48),
            noteIcon.leadingAnchor.constraint(equalTo: noteContainer.leadingAnchor, constant: 16),
            noteIcon.centerYAnchor.constraint(equalTo: noteContainer.centerYAnchor),
            noteIcon.widthAnchor.constraint(equalToConstant: 18),
            noteField.leadingAnchor.constraint(equalTo: noteIcon.trailingAnchor, constant: 10),
            noteField.trailingAnchor.constraint(equalTo: noteContainer.trailingAnchor, constant: -16),
            noteField.centerYAnchor.constraint(equalTo: noteContainer.centerYAnchor),
        ])

        // Paid By
        johnButton.addTarget(self, action: #selector(johnTapped), for: .touchUpInside)
        christinaButton.addTarget(self, action: #selector(christinaTapped), for: .touchUpInside)
        johnButton.layer.cornerRadius = Theme.inputRadius
        christinaButton.layer.cornerRadius = Theme.inputRadius
        johnButton.clipsToBounds = true
        christinaButton.clipsToBounds = true
        johnButton.translatesAutoresizingMaskIntoConstraints = false
        christinaButton.translatesAutoresizingMaskIntoConstraints = false
        johnButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        christinaButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let paidByStack = UIStackView(arrangedSubviews: [johnButton, christinaButton])
        paidByStack.axis = .horizontal
        paidByStack.spacing = 8
        paidByStack.distribution = .fillEqually

        // Submit
        let submitButton = UIButton(type: .system)
        submitButton.backgroundColor = Theme.coral
        submitButton.layer.cornerRadius = Theme.cardRadius
        submitButton.setTitle(isExpense ? "  Add Expense" : "  Add Income", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.titleLabel?.font = Theme.bodyBoldFont(size: 16)
        submitButton.setImage(UIImage(systemName: "checkmark")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.heightAnchor.constraint(equalToConstant: 56).isActive = true

        // Main stack
        let fieldsStack = UIStackView(arrangedSubviews: [categoryButton, noteContainer, paidByStack])
        fieldsStack.axis = .vertical
        fieldsStack.spacing = 12

        let mainStack = UIStackView(arrangedSubviews: [
            headerStack, amountContainer, fieldsStack, submitButton
        ])
        mainStack.axis = .vertical
        mainStack.spacing = 20
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(mainStack)
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func johnTapped() {
        paidBy = .John
        updatePaidByDisplay()
    }

    @objc private func christinaTapped() {
        paidBy = .Christina
        updatePaidByDisplay()
    }

    @objc private func submitTapped() {
        guard let text = amountField.text, let amount = Double(text), amount > 0 else { return }
        let cat = relevantCategories[categoryIndex]

        FirestoreService.shared.addTransaction(
            amount: amount,
            type: entryType,
            categoryName: cat.name,
            note: noteField.text ?? "",
            paidBy: paidBy
        )

        delegate?.didAddEntry()
        dismiss(animated: true)
    }

    // MARK: - UI Updates

    private func buildCategoryMenu() {
        let actions = relevantCategories.enumerated().map { index, cat in
            UIAction(
                title: cat.name,
                image: UIImage(systemName: cat.sfSymbol)?.withTintColor(cat.color, renderingMode: .alwaysOriginal),
                state: index == categoryIndex ? .on : .off
            ) { [weak self] _ in
                self?.categoryIndex = index
                self?.updateCategoryDisplay()
            }
        }
        categoryButton.menu = UIMenu(children: actions)
    }

    private func updateCategoryDisplay() {
        let cat = relevantCategories[categoryIndex]
        let image = UIImage(systemName: cat.sfSymbol)?
            .withTintColor(cat.color, renderingMode: .alwaysOriginal)

        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePadding = 10
        config.baseForegroundColor = Theme.dark
        config.attributedTitle = AttributedString(cat.name, attributes: .init([
            .font: Theme.bodyMediumFont(size: 14),
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        categoryButton.configuration = config

        noteContainer.isHidden = cat.name != "Άλλο"
        buildCategoryMenu()
    }

    private func updatePaidByDisplay() {
        stylePaidByButton(johnButton, title: "John", initial: "J", isActive: paidBy == .John)
        stylePaidByButton(christinaButton, title: "Christina", initial: "C", isActive: paidBy == .Christina)
    }

    private func stylePaidByButton(_ button: UIButton, title: String, initial: String, isActive: Bool) {
        button.backgroundColor = isActive ? Theme.dark : Theme.cardBg
        button.setTitle("  \(initial)  \(title)", for: .normal)
        button.setTitleColor(isActive ? .white : Theme.muted, for: .normal)
        button.titleLabel?.font = isActive ? Theme.bodySemiBoldFont(size: 14) : Theme.bodyMediumFont(size: 14)
    }
}
