# Bujumbura Business Assistant (Kabiz Smart Assistant)

An offline-first AI Business Assistant designed specifically for Small and Medium Enterprises (SMEs) in Bujumbura, Burundi, and surrounding regions.

---

## 📌 Project Overview

**Bujumbura Business Assistant** is a mobile and web application built with Flutter to streamline daily business operations for micro, small, and medium businesses. It operates completely offline using SQLite, ensuring zero dependency on active internet connections while recording sales, tracking inventory, managing customer debts, and generating real-time financial insights.

---

## ✨ Key Features

- 🛒 **Sales Recording & Checkout**: Quick product selection, quantity adjustment, payment calculation, and instant transaction recording.
- 📦 **Inventory & Stock Management**: Real-time product inventory tracking, low-stock warnings, and transaction logs.
- 💳 **Debt & Credit Tracking**: Record customer credit/debts, manage repayment histories, and monitor outstanding balances.
- 💸 **Expense Tracking**: Categorize daily operating expenses to keep track of store cash flow and net profits.
- 📊 **Business Analytics & Dashboard**: Summarized revenue, expense, and debt statistics with clear visual metrics.
- 🤖 **AI Assistant Interface**: Intelligent business guidance interface tailored for local Burundi business insights.
- 📱 **Cross-Platform Support**: Optimized for Android devices and responsive Web browsers.

---

## 🛠️ Technologies Used

| Technology | Purpose |
| :--- | :--- |
| **Flutter Framework** | Cross-platform UI development (Mobile & Web) |
| **Dart SDK** | Primary programming language (`>=3.0.0 <4.0.0`) |
| **SQLite (`sqflite`)** | Local persistent offline database storage |
| **Provider** | Reactive state management layer |
| **Google Fonts** | Modern typography styling (`Inter` / custom fonts) |
| **Font Awesome Flutter** | Vector icons and visual indicators |

---

## 📋 System Requirements

### Flutter & Dart Requirements
- **Flutter SDK**: `3.0.0` or higher
- **Dart SDK**: `3.0.0` or higher

### Android Requirements
- **Minimum SDK Level**: `API 21` (Android 5.0 Lollipop)
- **Target SDK Level**: `API 34` (Android 14)
- **Gradle Version**: `8.0` or higher
- **Java Development Kit (JDK)**: `17` or higher

---

## 🚀 Getting Started & Installation

### 1. Prerequisites
Ensure Flutter SDK and Git are installed on your machine. You can verify your environment by running:
```bash
flutter doctor
```

### 2. Clone the Repository
```bash
git clone https://github.com/username/bujumbura-business-assistant.git
cd bujumbura-business-assistant
```

### 3. Install Dependencies
```bash
flutter pub get
```

---

## 🏗️ Build & Run Instructions

### Run Locally (Debug Mode)
```bash
flutter run
```

### Run on Specific Device (e.g., Chrome Web or Android Device)
```bash
flutter run -d chrome
```

### Build Production Release (Android APK)
```bash
flutter build apk --release
```

### Build Android App Bundle (AAB)
```bash
flutter build appbundle --release
```

---

## 📁 Folder Structure

```
bujumbura_business_assistant/
├── android/               # Native Android configuration and gradle scripts
├── ios/                   # Native iOS project setup
├── web/                   # Web platform configuration and assets
├── lib/
│   ├── database/          # SQLite database helper & schema definitions
│   ├── models/            # Data models (Product, Sale, Debt, Expense, Customer)
│   ├── repositories/      # Data access repositories
│   ├── services/          # Business logic & state management providers
│   ├── theme/             # App typography, spacing, colors, and theme tokens
│   ├── views/             # Screen pages (Home, Dashboard, Sales, Products, Debt, Expenses, Assistant)
│   └── widgets/           # Reusable UI components & cards
├── test/                  # Unit and integration tests
├── assets/                # App icons, static resources, and images
├── pubspec.yaml           # Dependency management manifest
└── README.md              # Project documentation
```

---

## 🖼️ Screenshots

| Dashboard View | Record Sale | Inventory Management |
| :---: | :---: | :---: |
| *(Placeholder for Dashboard Screenshot)* | *(Placeholder for Record Sale Screenshot)* | *(Placeholder for Inventory Screenshot)* |

| Debt Tracking | Expense View | AI Assistant |
| :---: | :---: | :---: |
| *(Placeholder for Debt Screenshot)* | *(Placeholder for Expense Screenshot)* | *(Placeholder for Assistant Screenshot)* |

---

## 🔮 Future Improvements

- [ ] Multi-language support (Kirundi, French, English)
- [ ] Thermal Bluetooth printer integration for receipt printing
- [ ] Cloud backup & sync option (optional opt-in for multi-device setups)
- [ ] Advanced profit & loss reporting with export options (PDF/Excel)

---

## 📄 License

This project is released under the **MIT License**. See the `LICENSE` file for details.
