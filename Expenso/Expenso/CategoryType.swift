//
//  CategoryType.swift
//  Expenso
//
//  Created by John Fanidis on 12/3/26.
//


import UIKit

enum CategoryType: String {
    case expense
    case income
    case both
}

struct Category {
    let name: String
    let sfSymbol: String
    let color: UIColor
    let bgColor: UIColor
    let type: CategoryType
}

let categories: [Category] = [
    Category(name: "Λαϊκή",       sfSymbol: "basket.fill",          color: Theme.amber,  bgColor: Theme.amberBg,  type: .expense),
    Category(name: "Supermarket",  sfSymbol: "cart.fill",            color: Theme.indigo,  bgColor: Theme.indigoBg, type: .expense),
    Category(name: "Βενζίνη",      sfSymbol: "fuelpump.fill",        color: Theme.purple,  bgColor: Theme.purpleBg, type: .expense),
    Category(name: "Διατροφολόγος", sfSymbol: "leaf.fill",           color: Theme.green,  bgColor: Theme.greenBg,  type: .expense),
    Category(name: "Φαγητό",       sfSymbol: "fork.knife",           color: Theme.indigo,  bgColor: Theme.indigoBg, type: .expense),
    Category(name: "Καφές",        sfSymbol: "cup.and.saucer.fill",  color: Theme.amber,  bgColor: Theme.amberBg,  type: .expense),
    Category(name: "Εύα",          sfSymbol: "dumbbell.fill",        color: Theme.coral,  bgColor: Theme.redBg,    type: .expense),
    Category(name: "Ανανέωση υπολοίπου", sfSymbol: "arrow.clockwise", color: Theme.green, bgColor: Theme.greenBg, type: .income),
    Category(name: "Άλλο",         sfSymbol: "ellipsis",             color: Theme.muted,  bgColor: Theme.cardBg,   type: .both),
]

func resolveCategory(name: String) -> Category {
    categories.first(where: { $0.name == name }) ?? categories[0]
}
