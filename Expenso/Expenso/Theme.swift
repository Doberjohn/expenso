//
//  Theme.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import UIKit

struct Theme {
    // MARK: - Colors
    static let coral       = UIColor(hex: "#FF6B6B")
    static let dark        = UIColor(hex: "#1A1A1A")
    static let muted       = UIColor(hex: "#9CA3AF")
    static let cardBg      = UIColor(hex: "#F6F7F8")
    static let white       = UIColor.white
    static let purple      = UIColor(hex: "#8B5CF6")
    static let indigo      = UIColor(hex: "#6366F1")
    static let green       = UIColor(hex: "#22C55E")
    static let amber       = UIColor(hex: "#D97706")
    static let amberBg     = UIColor(hex: "#FFFBEB")
    static let indigoBg    = UIColor(hex: "#F0F5FF")
    static let greenBg     = UIColor(hex: "#F0FDF4")
    static let red         = UIColor(hex: "#EF4444")
    static let redBg       = UIColor(hex: "#FEF2F2")
    static let border      = UIColor(hex: "#E5E7EB")

    // MARK: - Spacing
    static let contentPadding: CGFloat = 24
    static let gap: CGFloat = 12
    static let sectionGap: CGFloat = 24

    // MARK: - Radii
    static let cardRadius: CGFloat = 20
    static let inputRadius: CGFloat = 16
    static let iconContainerRadius: CGFloat = 12
    static let badgeRadius: CGFloat = 12
    static let buttonRadius: CGFloat = 16
    static let sheetRadius: CGFloat = 28

    // MARK: - Fonts
    static func headingFont(size: CGFloat) -> UIFont {
        UIFont(name: "BricolageGrotesque-96ptExtraBold_Bold", size: size)
            ?? .systemFont(ofSize: size, weight: .bold)
    }

    static func headingBlackFont(size: CGFloat) -> UIFont {
        UIFont(name: "BricolageGrotesque-96ptExtraBold_ExtraBold", size: size)
            ?? .systemFont(ofSize: size, weight: .heavy)
    }

    static func bodyFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-9ptRegular_Regular", size: size)
            ?? .systemFont(ofSize: size, weight: .regular)
    }

    static func bodyMediumFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-9ptRegular_Medium", size: size)
            ?? .systemFont(ofSize: size, weight: .medium)
    }

    static func bodySemiBoldFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-9ptRegular_SemiBold", size: size)
            ?? .systemFont(ofSize: size, weight: .semibold)
    }

    static func bodyBoldFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-9ptRegular_Bold", size: size)
            ?? .systemFont(ofSize: size, weight: .bold)
    }
}

// MARK: - UIColor hex extension
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255,
                  blue: CGFloat(b) / 255, alpha: 1)
    }
}
