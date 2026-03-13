//
//  BalanceCardView.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import UIKit

class BalanceCardView: UIView {

    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let badgeContainer = UIView()
    private let badgeIcon = UIImageView()
    private let badgeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        let titleH = titleLabel.font.lineHeight
        let amountH = amountLabel.font.lineHeight
        let badgeH: CGFloat = 28
        // 20 top + title + 12 + amount + 12 + badge + 20 bottom
        let height = 20 + titleH + 12 + amountH + 12 + badgeH + 20
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    private func setupUI() {
        backgroundColor = Theme.purple
        layer.cornerRadius = Theme.cardRadius
        clipsToBounds = true

        // Title
        titleLabel.font = Theme.bodyMediumFont(size: 13)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Amount
        amountLabel.font = Theme.headingBlackFont(size: 32)
        amountLabel.textColor = .white
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(amountLabel)

        // Badge
        badgeContainer.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        badgeContainer.layer.cornerRadius = Theme.badgeRadius
        badgeContainer.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.isHidden = true
        addSubview(badgeContainer)

        badgeIcon.tintColor = .white
        badgeIcon.contentMode = .scaleAspectFit
        badgeIcon.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.addSubview(badgeIcon)

        badgeLabel.font = Theme.bodySemiBoldFont(size: 11)
        badgeLabel.textColor = .white
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeContainer.addSubview(badgeLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            amountLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            amountLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            badgeContainer.topAnchor.constraint(equalTo: amountLabel.bottomAnchor, constant: 12),
            badgeContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            badgeIcon.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 10),
            badgeIcon.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            badgeIcon.widthAnchor.constraint(equalToConstant: 14),
            badgeIcon.heightAnchor.constraint(equalToConstant: 14),

            badgeLabel.leadingAnchor.constraint(equalTo: badgeIcon.trailingAnchor, constant: 4),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -10),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            badgeContainer.heightAnchor.constraint(equalToConstant: 28),
        ])

        let bottom = badgeContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        bottom.priority = .defaultHigh
        bottom.isActive = true
    }

    func update(total: Double, previousMonthTotal: Double) {
        defer { invalidateIntrinsicContentSize() }
        let monthNames = ["January", "February", "March", "April", "May", "June",
                          "July", "August", "September", "October", "November", "December"]
        let shortMonths = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                           "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let month = Calendar.current.component(.month, from: Date()) - 1

        titleLabel.text = "Total Balance — \(monthNames[month])"
        amountLabel.text = String(format: "€%.2f", total)

        if previousMonthTotal != 0 {
            let diff = ((total - previousMonthTotal) / abs(previousMonthTotal)) * 100
            let absDiff = Int(abs(diff.rounded()))
            if absDiff > 0 {
                let isMore = diff > 0
                let prevMonthName = shortMonths[(month + 11) % 12]
                let symbolName = isMore ? "arrow.up.right" : "arrow.down.right"
                badgeIcon.image = UIImage(systemName: symbolName)
                badgeLabel.text = "\(absDiff)% \(isMore ? "more" : "less") than \(prevMonthName)"
                badgeContainer.isHidden = false
            } else {
                badgeContainer.isHidden = true
            }
        } else {
            badgeContainer.isHidden = true
        }
    }
}
