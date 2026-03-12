//
//  ActionButton.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import UIKit

class ActionButton: UIButton {

    init(title: String, sfSymbol: String, color: UIColor, bgColor: UIColor) {
        super.init(frame: .zero)

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = bgColor
        config.baseForegroundColor = color
        config.cornerStyle = .fixed
        config.background.cornerRadius = Theme.buttonRadius
        config.image = UIImage(systemName: sfSymbol)?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        config.imagePadding = 8
        config.attributedTitle = AttributedString(title, attributes: .init([
            .font: Theme.bodySemiBoldFont(size: 14),
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

        self.configuration = config
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
