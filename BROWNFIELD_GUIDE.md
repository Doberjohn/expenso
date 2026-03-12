# Brownfield Rebuild: Expenso as Native Swift + Embedded RN Transaction List

A step-by-step guide to rebuild Expenso as a **native UIKit app** with an **embedded React Native transaction list**.

**Prerequisites:** Xcode 15+, Node.js 18+, CocoaPods, Ruby (for CocoaPods)

---

## Architecture

```
┌─────────────────────────────────────┐
│  Native iOS App (UIKit + Swift)     │
│                                     │
│  BalanceCardView (purple card)      │
│  [Expense btn]  [Income btn]        │
│  "Transactions" header              │
│  ┌─────────────────────────────┐    │
│  │  RCTRootView                │    │  ← React Native
│  │  TransactionList + swipe    │    │
│  └─────────────────────────────┘    │
│                                     │
│  Bottom Sheet (AddEntry - native)   │
└─────────────────────────────────────┘
```

**Swift side:** Balance card, buttons, bottom sheet, Firebase
**RN side:** Transaction list only (FlatList + swipe-to-delete)

---

## Phase 1: Create the Xcode Project

### Step 1.1 — New Project
1. Open Xcode → File → New → Project
2. Choose **App** (iOS)
3. Product Name: `ExpensoNative`
4. Interface: **Storyboard** (we'll go programmatic, but this gives us AppDelegate)
5. Language: **Swift**
6. Uncheck "Include Tests" (optional for this exercise)
7. Save it wherever you keep projects on your Mac

### Step 1.2 — Go Storyboard-less
1. Delete `Main.storyboard`
2. In the project target → General → Deployment Info → remove "Main" from **Main Interface** (or clear the "Main storyboard file base name" in Info.plist)
3. In `Info.plist`, under `UIApplicationSceneManifest` → `UISceneConfigurations` → `UIWindowSceneSessionRoleApplication` → Item 0, delete the `UISceneStoryboardFile` key

4. Update `SceneDelegate.swift`:

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = MainViewController()
        window?.makeKeyAndVisible()
    }
}
```

### Step 1.3 — Create a Placeholder MainViewController

Create `MainViewController.swift`:

```swift
import UIKit

class MainViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let label = UILabel()
        label.text = "ExpensoNative"
        label.font = .boldSystemFont(ofSize: 24)
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
```

**Checkpoint:** Build and run (Cmd+R). You should see "ExpensoNative" centered on screen.

---

## Phase 2: Add Firebase

### Step 2.1 — Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Open the existing project `family-expenses-tracker-cf311`
3. Click **Add app** → iOS
4. Bundle ID: use your Xcode bundle identifier (e.g., `com.yourname.ExpensoNative`)
5. Download `GoogleService-Info.plist`
6. Drag it into the Xcode project (check "Copy items if needed")

### Step 2.2 — Add Firebase SDK via SPM
1. In Xcode: File → Add Package Dependencies
2. URL: `https://github.com/firebase/firebase-ios-sdk`
3. Version: Up to Next Major (latest)
4. Add these packages:
   - `FirebaseFirestore`

### Step 2.3 — Initialize Firebase

Update `AppDelegate.swift`:

```swift
import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration",
                                    sessionRole: connectingSceneSession.role)
    }
}
```

**Checkpoint:** Build and run. No crashes = Firebase is connected.

---

## Phase 3: Theme & Models

### Step 3.1 — Create `Theme.swift`

```swift
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

    // MARK: - Fonts
    // You need to bundle DM Sans + Bricolage Grotesque .ttf files
    // and register them in Info.plist under "Fonts provided by application"
    // For now, use system fonts as fallback:
    static func headingFont(size: CGFloat) -> UIFont {
        UIFont(name: "BricolageGrotesque-Bold", size: size)
            ?? .systemFont(ofSize: size, weight: .bold)
    }

    static func headingBlackFont(size: CGFloat) -> UIFont {
        UIFont(name: "BricolageGrotesque-ExtraBold", size: size)
            ?? .systemFont(ofSize: size, weight: .heavy)
    }

    static func bodyFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-Regular", size: size)
            ?? .systemFont(ofSize: size, weight: .regular)
    }

    static func bodyMediumFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-Medium", size: size)
            ?? .systemFont(ofSize: size, weight: .medium)
    }

    static func bodySemiBoldFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-SemiBold", size: size)
            ?? .systemFont(ofSize: size, weight: .semibold)
    }

    static func bodyBoldFont(size: CGFloat) -> UIFont {
        UIFont(name: "DMSans-Bold", size: size)
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
```

### Step 3.2 — Add Custom Fonts (optional but recommended)

1. Download **DM Sans** (.ttf files: Regular, Medium, SemiBold, Bold) from Google Fonts
2. Download **Bricolage Grotesque** (.ttf files: Bold, ExtraBold) from Google Fonts
3. Add them to the Xcode project (Create a `Fonts` group)
4. In `Info.plist`, add key `Fonts provided by application` (array) with entries:
   - `DMSans-Regular.ttf`
   - `DMSans-Medium.ttf`
   - `DMSans-SemiBold.ttf`
   - `DMSans-Bold.ttf`
   - `BricolageGrotesque-Bold.ttf`
   - `BricolageGrotesque-ExtraBold.ttf`
5. Make sure each .ttf file has "Target Membership" checked for ExpensoNative

### Step 3.3 — Create `Models/Category.swift`

```swift
import UIKit

enum CategoryType: String {
    case expense
    case income
    case both
}

struct Category {
    let name: String
    let sfSymbol: String    // SF Symbol name (replaces lucide icons)
    let color: UIColor
    let bgColor: UIColor
    let type: CategoryType
}

let categories: [Category] = [
    Category(name: "Λαϊκή",       sfSymbol: "basket.fill",        color: Theme.amber,  bgColor: Theme.amberBg,  type: .expense),
    Category(name: "Supermarket",  sfSymbol: "cart.fill",          color: Theme.indigo,  bgColor: Theme.indigoBg, type: .expense),
    Category(name: "Διατροφολόγος", sfSymbol: "leaf.fill",         color: Theme.green,  bgColor: Theme.greenBg,  type: .expense),
    Category(name: "Φαγητό",       sfSymbol: "fork.knife",         color: Theme.indigo,  bgColor: Theme.indigoBg, type: .expense),
    Category(name: "Καφές",        sfSymbol: "cup.and.saucer.fill", color: Theme.amber,  bgColor: Theme.amberBg,  type: .expense),
    Category(name: "Εύα",          sfSymbol: "dumbbell.fill",       color: Theme.coral,  bgColor: Theme.redBg,    type: .expense),
    Category(name: "Ανανέωση υπολοίπου", sfSymbol: "arrow.clockwise", color: Theme.green, bgColor: Theme.greenBg, type: .income),
    Category(name: "Άλλο",         sfSymbol: "ellipsis",            color: Theme.muted,  bgColor: Theme.cardBg,   type: .both),
]

func resolveCategory(name: String) -> Category {
    categories.first(where: { $0.name == name }) ?? categories[0]
}
```

### Step 3.4 — Create `Models/Transaction.swift`

```swift
import Foundation
import FirebaseFirestore

enum TransactionType: String, Codable {
    case expense
    case income
}

enum PaidBy: String, Codable {
    case John
    case Christina
}

struct Transaction: Identifiable {
    let id: String
    let amount: Double
    let type: TransactionType
    let categoryName: String   // raw string from Firestore
    let note: String
    let paidBy: PaidBy
    let date: Date
    let createdAt: Date

    var category: Category {
        resolveCategory(name: categoryName)
    }

    /// Serialize for passing to React Native
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "amount": amount,
            "type": type.rawValue,
            "category": [
                "name": category.name,
                "icon": lucideIconName,  // RN side uses lucide names
                "color": category.color.hexString,
                "bgColor": category.bgColor.hexString,
                "type": category.type.rawValue,
            ],
            "note": note,
            "paidBy": paidBy.rawValue,
            "date": date.timeIntervalSince1970 * 1000, // JS timestamp
        ]
    }

    /// Map SF Symbol back to lucide icon name for RN
    private var lucideIconName: String {
        let map: [String: String] = [
            "Λαϊκή": "ShoppingBasket",
            "Supermarket": "ShoppingCart",
            "Διατροφολόγος": "Apple",
            "Φαγητό": "Utensils",
            "Καφές": "Coffee",
            "Εύα": "Dumbbell",
            "Ανανέωση υπολοίπου": "RefreshCw",
            "Άλλο": "MoreHorizontal",
        ]
        return map[categoryName] ?? "MoreHorizontal"
    }
}

// MARK: - UIColor → hex string (for passing to RN)
extension UIColor {
    var hexString: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return String(format: "#%02X%02X%02X",
                      Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
```

**Checkpoint:** Build. No errors = models are correct.

---

## Phase 4: Firebase Service

### Step 4.1 — Create `Services/FirestoreService.swift`

```swift
import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()

    private let db = Firestore.firestore()
    private let collectionName = "transactions"
    private var listener: ListenerRegistration?

    // Callbacks
    var onTransactionsUpdate: (([Transaction]) -> Void)?
    var onTotalsUpdate: ((Double, Double) -> Void)?  // (currentMonth, previousMonth)

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
            self.onTotalsUpdate?(self.currentMonthTotal, self.previousMonthTotal)
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
```

**Checkpoint:** Build. Add a test print in `MainViewController.viewDidLoad`:
```swift
FirestoreService.shared.onTransactionsUpdate = { txns in
    print("Got \(txns.count) transactions")
}
FirestoreService.shared.startListening()
```
Run the app — you should see your existing transactions count in the console.

---

## Phase 5: Native UI

### Step 5.1 — Create `Views/BalanceCardView.swift`

```swift
import UIKit

class BalanceCardView: UIView {

    private let titleLabel = UILabel()
    private let amountLabel = UILabel()
    private let badgeStack = UIStackView()
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
            badgeContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            badgeIcon.leadingAnchor.constraint(equalTo: badgeContainer.leadingAnchor, constant: 10),
            badgeIcon.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            badgeIcon.widthAnchor.constraint(equalToConstant: 14),
            badgeIcon.heightAnchor.constraint(equalToConstant: 14),

            badgeLabel.leadingAnchor.constraint(equalTo: badgeIcon.trailingAnchor, constant: 4),
            badgeLabel.trailingAnchor.constraint(equalTo: badgeContainer.trailingAnchor, constant: -10),
            badgeLabel.centerYAnchor.constraint(equalTo: badgeContainer.centerYAnchor),
            badgeContainer.heightAnchor.constraint(equalToConstant: 28),
        ])
    }

    func update(total: Double, previousMonthTotal: Double) {
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
```

### Step 5.2 — Create `Views/ActionButton.swift`

```swift
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
        config.title = title
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
```

### Step 5.3 — Create `ViewControllers/AddEntryViewController.swift`

```swift
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
        amountRow.alignment = .firstBaseline
        amountRow.spacing = 4

        let amountContainer = UIStackView(arrangedSubviews: [amountLabel, amountRow])
        amountContainer.axis = .vertical
        amountContainer.alignment = .center
        amountContainer.spacing = 6

        // Category
        categoryButton.backgroundColor = Theme.cardBg
        categoryButton.layer.cornerRadius = Theme.inputRadius
        categoryButton.contentHorizontalAlignment = .left
        categoryButton.addTarget(self, action: #selector(cycleCategoryTapped), for: .touchUpInside)
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        // Note
        noteField.placeholder = "Add a note..."
        noteField.font = Theme.bodyFont(size: 14)
        noteField.textColor = Theme.dark

        noteContainer.backgroundColor = Theme.cardBg
        noteContainer.layer.cornerRadius = Theme.inputRadius
        noteContainer.isHidden = true // only shown for Άλλο

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

    @objc private func cycleCategoryTapped() {
        categoryIndex = (categoryIndex + 1) % relevantCategories.count
        updateCategoryDisplay()
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

    private func updateCategoryDisplay() {
        let cat = relevantCategories[categoryIndex]
        let image = UIImage(systemName: cat.sfSymbol)?
            .withTintColor(cat.color, renderingMode: .alwaysOriginal)

        var config = UIButton.Configuration.plain()
        config.image = image
        config.imagePadding = 10
        config.title = cat.name
        config.baseForegroundColor = Theme.dark
        config.attributedTitle = AttributedString(cat.name, attributes: .init([
            .font: Theme.bodyMediumFont(size: 14),
        ]))
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        categoryButton.configuration = config

        // Show/hide note for Άλλο
        noteContainer.isHidden = cat.name != "Άλλο"
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
```

### Step 5.4 — Build the Full `MainViewController.swift`

```swift
import UIKit

class MainViewController: UIViewController, AddEntryDelegate {

    private let balanceCard = BalanceCardView()
    private let rnContainer = UIView()  // placeholder for React Native
    private let scrollView = UIScrollView()
    private var sheetType: TransactionType = .expense

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        startFirestore()
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

        // Balance card
        balanceCard.translatesAutoresizingMaskIntoConstraints = false

        // Action buttons
        let expenseBtn = ActionButton(title: "Expense", sfSymbol: "minus",
                                      color: Theme.red, bgColor: Theme.redBg)
        expenseBtn.addTarget(self, action: #selector(expenseTapped), for: .touchUpInside)

        let incomeBtn = ActionButton(title: "Income", sfSymbol: "plus",
                                     color: Theme.green, bgColor: Theme.greenBg)
        incomeBtn.addTarget(self, action: #selector(incomeTapped), for: .touchUpInside)

        let buttonsStack = UIStackView(arrangedSubviews: [expenseBtn, incomeBtn])
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

        // RN container (will host RCTRootView later)
        rnContainer.translatesAutoresizingMaskIntoConstraints = false
        rnContainer.backgroundColor = .clear

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

            // RN container should expand to fill remaining space
            rnContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
        ])
    }

    // MARK: - Firestore

    private func startFirestore() {
        FirestoreService.shared.onTotalsUpdate = { [weak self] current, previous in
            DispatchQueue.main.async {
                self?.balanceCard.update(total: current, previousMonthTotal: previous)
            }
        }

        // TODO: Phase 6 will add RN event emitter updates here
        FirestoreService.shared.onTransactionsUpdate = { [weak self] txns in
            DispatchQueue.main.async {
                // Will send to RN via event emitter
                print("Transactions updated: \(txns.count)")
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
            sheet.prefersGrabberIndicator = true
            sheet.preferredCornerRadius = 28
        }

        present(addVC, animated: true)
    }

    // MARK: - AddEntryDelegate

    func didAddEntry() {
        // Firestore listener will automatically update everything
    }
}
```

**Checkpoint:** Build and run. You should see:
- Header with "John & Christina"
- Purple balance card with your real Firestore data
- Expense/Income buttons that open the native bottom sheet
- Adding an entry should update the balance card (check the existing Expo app too — same data!)

---

## Phase 6: React Native Integration

This is the core brownfield part. We'll embed a RN view for the transaction list.

### Step 6.1 — Set Up the RN Module

In Terminal, from the project root:

```bash
mkdir ReactNativeModule
cd ReactNativeModule
```

Create `package.json`:

```json
{
  "name": "ExpensoRNModule",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "19.0.0",
    "react-native": "0.79.2",
    "react-native-gesture-handler": "^2.24.0",
    "react-native-reanimated": "^3.17.0",
    "react-native-svg": "^15.11.2",
    "lucide-react-native": "^0.475.0"
  }
}
```

> **Important:** Check the latest compatible versions. The RN version should match what's supported by gesture-handler and reanimated.

```bash
npm install
```

### Step 6.2 — Create RN Entry Point

Create `ReactNativeModule/index.js`:

```javascript
import { AppRegistry } from 'react-native';
import TransactionList from './TransactionList';

AppRegistry.registerComponent('TransactionList', () => TransactionList);
```

### Step 6.3 — Create `ReactNativeModule/TransactionList.tsx`

```tsx
import React, { useState, useEffect } from 'react';
import { FlatList, NativeModules, NativeEventEmitter, StyleSheet, View } from 'react-native';
import { GestureHandlerRootView } from 'react-native-gesture-handler';
import TransactionRow from './TransactionRow';

const { TransactionBridge } = NativeModules;
const eventEmitter = new NativeEventEmitter(TransactionBridge);

interface Transaction {
  id: string;
  amount: number;
  type: 'expense' | 'income';
  category: {
    name: string;
    icon: string;
    color: string;
    bgColor: string;
    type: string;
  };
  note: string;
  paidBy: string;
  date: number; // JS timestamp
}

interface Props {
  transactions?: Transaction[];
}

export default function TransactionList({ transactions: initialTransactions }: Props) {
  const [transactions, setTransactions] = useState<Transaction[]>(
    initialTransactions || []
  );

  useEffect(() => {
    const subscription = eventEmitter.addListener(
      'onTransactionsUpdate',
      (data: Transaction[]) => {
        setTransactions(data);
      }
    );
    return () => subscription.remove();
  }, []);

  const handleDelete = (id: string) => {
    TransactionBridge.deleteTransaction(id);
  };

  return (
    <GestureHandlerRootView style={styles.root}>
      <FlatList
        data={transactions}
        keyExtractor={(item) => item.id}
        renderItem={({ item }) => (
          <TransactionRow
            transaction={{
              ...item,
              date: new Date(item.date),
            }}
            onDelete={handleDelete}
          />
        )}
        contentContainerStyle={styles.list}
        showsVerticalScrollIndicator={false}
      />
    </GestureHandlerRootView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  list: { gap: 12, paddingBottom: 24 },
});
```

### Step 6.4 — Copy TransactionRow & Icon

Copy `TransactionRow.tsx` and `Icon.tsx` from the current project into `ReactNativeModule/`.

The only change needed: update imports to use local paths (no `./src/` prefix since they're in the same directory).

In `TransactionRow.tsx`, change:
```typescript
import { colors, fonts, radii } from './theme';
```
to inline values or create a small `theme.ts` in the module:

```typescript
// ReactNativeModule/theme.ts
export const colors = {
  coral: '#FF6B6B',
  dark: '#1A1A1A',
  muted: '#9CA3AF',
  cardBg: '#F6F7F8',
  white: '#FFFFFF',
  green: '#22C55E',
  red: '#EF4444',
  border: '#E5E7EB',
} as const;

export const fonts = {
  bodyMedium: 'DMSans-Medium',
  bodySemiBold: 'DMSans-SemiBold',
  bodyBold: 'DMSans-Bold',
} as const;

export const radii = {
  input: 16,
  iconContainer: 12,
} as const;
```

> **Note:** In bare RN (not Expo), font names use the PostScript name format (e.g., `DMSans-Medium`), not the Expo Google Fonts format.

### Step 6.5 — Create the Native Module Bridge

Create `ExpensoNative/Services/RNBridge.swift`:

```swift
import Foundation
import React

@objc(TransactionBridge)
class TransactionBridge: RCTEventEmitter {

    static var shared: TransactionBridge?

    override init() {
        super.init()
        TransactionBridge.shared = self
    }

    override func supportedEvents() -> [String]! {
        return ["onTransactionsUpdate"]
    }

    override static func requiresMainQueueSetup() -> Bool {
        return true
    }

    // Called from RN when user swipes to delete
    @objc func deleteTransaction(_ id: String) {
        FirestoreService.shared.deleteTransaction(id: id)
    }

    // Called from Swift to push updates to RN
    func sendTransactions(_ transactions: [Transaction]) {
        let data = transactions.map { $0.toDictionary() }
        sendEvent(withName: "onTransactionsUpdate", body: data)
    }
}
```

Create the Objective-C bridging file `ExpensoNative/TransactionBridgeExport.m`:

```objc
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

@interface RCT_EXTERN_MODULE(TransactionBridge, RCTEventEmitter)
RCT_EXTERN_METHOD(deleteTransaction:(NSString *)id)
@end
```

### Step 6.6 — Create the Podfile

In the project root, create `Podfile`:

```ruby
require_relative 'ReactNativeModule/node_modules/react-native/scripts/react_native_pods'

platform :ios, '15.0'

prepare_react_native_project!

target 'ExpensoNative' do
  use_react_native!(
    :path => './ReactNativeModule/node_modules/react-native',
    :hermes_enabled => true
  )
end

post_install do |installer|
  react_native_post_install(installer)
end
```

Run:
```bash
cd ExpensoNative
pod install
```

From now on, open `ExpensoNative.xcworkspace` (not `.xcodeproj`).

### Step 6.7 — Host RN View in MainViewController

Update `MainViewController.swift` to embed the RN view:

Add to the top of the file:
```swift
import React
```

Add a property:
```swift
private var rnBridge: RCTBridge?
```

Add this method and call it from `viewDidLoad` after `setupUI()`:

```swift
private func setupReactNative() {
    let bundleURL: URL
    #if DEBUG
    bundleURL = RCTBundleURLProvider.sharedSettings()
        .jsBundleURL(forBundleRoot: "index")
    #else
    bundleURL = Bundle.main.url(forResource: "main", withExtension: "jsbundle")!
    #endif

    rnBridge = RCTBridge(bundleURLProvider: nil, moduleProvider: nil, launchOptions: nil)

    // Create RCTRootView
    let initialTransactions = FirestoreService.shared.transactions.map { $0.toDictionary() }
    let rootView = RCTRootView(
        bridge: rnBridge!,
        moduleName: "TransactionList",
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
```

Update the `onTransactionsUpdate` callback in `startFirestore()`:

```swift
FirestoreService.shared.onTransactionsUpdate = { [weak self] txns in
    DispatchQueue.main.async {
        TransactionBridge.shared?.sendTransactions(txns)
    }
}
```

### Step 6.8 — Start Metro Bundler (for development)

In Terminal:
```bash
cd ReactNativeModule
npx react-native start
```

Then build and run from Xcode.

---

## Phase 7: Final Verification Checklist

- [ ] App launches without crash
- [ ] Balance card shows correct total from Firestore
- [ ] Month comparison badge shows correct percentage
- [ ] Tapping "Expense" opens native bottom sheet
- [ ] Category cycles through expense categories on tap
- [ ] "Άλλο" shows the note field
- [ ] John/Christina toggle works
- [ ] Submitting adds transaction to Firestore
- [ ] Transaction list (RN) renders all transactions with icons
- [ ] Swipe-to-delete works and removes from Firestore
- [ ] Balance card updates after add/delete
- [ ] Open the original Expo app — same data appears (shared Firestore)
- [ ] Kill and reopen — data persists

---

## Troubleshooting

### Common Issues

| Problem | Fix |
|---|---|
| `No Firebase App` crash | Make sure `GoogleService-Info.plist` is in the target and `FirebaseApp.configure()` is in AppDelegate |
| RN view is blank | Check Metro is running, check bundleURL is correct |
| Pods don't install | Make sure Node path is correct, try `pod install --repo-update` |
| Bridge methods not found | Make sure the `.m` bridging file is included in the target |
| Fonts not loading | Check Info.plist entries match exact filenames, check target membership |
| Gesture handler crash | Make sure `GestureHandlerRootView` wraps the RN component |

### Debugging Bridge Communication

Add logging in `TransactionBridge.swift`:
```swift
func sendTransactions(_ transactions: [Transaction]) {
    let data = transactions.map { $0.toDictionary() }
    print("[RN Bridge] Sending \(data.count) transactions to RN")
    sendEvent(withName: "onTransactionsUpdate", body: data)
}
```

And in `TransactionList.tsx`:
```typescript
useEffect(() => {
    const subscription = eventEmitter.addListener('onTransactionsUpdate', (data) => {
        console.log('[RN] Received', data.length, 'transactions from Swift');
        setTransactions(data);
    });
    return () => subscription.remove();
}, []);
```
