[README.md](https://github.com/user-attachments/files/25970785/README.md)
# Expenso

A shared expense tracker for couples, built with Swift (UIKit) and React Native.

## What it does

Expenso lets two people track shared expenses and income in real time. Each transaction records who paid, the category, amount (EUR), and an optional note. A balance card shows the current month's total with a month-over-month comparison.

### Features

- Add expenses and income with category, payer, and notes
- Real-time sync via Firebase Firestore
- Monthly balance with percentage change vs previous month
- Swipe-to-delete transactions with animated feedback
- Categorized spending (Supermarket, Coffee, Food, Gym, etc.)

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Native shell | Swift, UIKit, Auto Layout |
| Transaction list | React Native 0.79, TypeScript |
| Animations | React Native Reanimated 3 |
| Database | Firebase Firestore (real-time listener) |
| JS Engine | Hermes |
| Icons | Lucide (RN), SF Symbols (native) |
| Fonts | DM Sans, Bricolage Grotesque |

## Project Structure

```
expenso/
├── ReactNativeModule/          # React Native module
│   └── src/
│       ├── index.js            # Registers TransactionList component
│       ├── TransactionList.tsx  # Transaction list with real-time updates
│       ├── TransactionRow.tsx   # Swipeable row with delete gesture
│       ├── Icon.tsx             # Lucide icon wrapper
│       └── theme.ts            # Shared colors, fonts, spacing
│
├── Expenso/                    # Native iOS Xcode project
│   ├── Expenso/
│   │   ├── AppDelegate.swift           # App entry, Firebase init
│   │   ├── SceneDelegate.swift         # Window scene setup
│   │   ├── MainViewController.swift    # Main screen layout
│   │   ├── AddEntryViewController.swift # Add transaction sheet
│   │   ├── BalanceCardView.swift       # Balance card with month comparison
│   │   ├── FirestoreService.swift      # Firestore CRUD + listener
│   │   ├── RNBridge.swift              # Native → RN event emitter
│   │   ├── TransactionType.swift       # Data models & enums
│   │   ├── CategoryType.swift          # Category definitions
│   │   └── Theme.swift                 # Design tokens
│   ├── Fonts/                  # DM Sans, Bricolage Grotesque
│   ├── Podfile                 # CocoaPods dependencies
│   └── .xcode.env              # Build environment
│
├── package.json                # Root config with codegen settings
└── react-native.config.js     # Links iOS project to RN dependencies
```

## Architecture

```
Firestore (real-time listener)
    ↓
FirestoreService (Swift)
    ↓
BalanceCardView (native)  +  TransactionBridge (event emitter)
                                     ↓
                             TransactionList (React Native)
```

The native layer owns data, navigation, and the balance UI. The React Native layer renders the scrollable transaction list, receiving updates via the bridge event emitter.

## Setup

### Prerequisites

- Xcode 26+
- Node.js 22+
- CocoaPods

### Install

```bash
# Install RN dependencies
cd ReactNativeModule
npm install

# Install iOS pods
cd ../Expenso
pod install
```

### Build

Open `Expenso/Expenso.xcworkspace` in Xcode and build to a device or simulator.
