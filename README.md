# Kabiz

An offline-first AI Business Assistant designed for Small and Medium Enterprises (SMEs).

---

## 📌 Project Overview

**Kabiz** is a mobile and web application built with Flutter to streamline daily business operations for micro, small, and medium businesses. It operates completely offline using SQLite, ensuring zero dependency on active internet connections while recording sales, tracking inventory, managing customer debts, and generating real-time financial insights.

---

## ✨ Key Features

- 🛒 **Sales Recording & Checkout**: Quick product selection, quantity adjustment, payment calculation, and instant transaction recording.
- 📦 **Inventory & Stock Management**: Real-time product inventory tracking, low-stock warnings, and transaction logs.
- 💳 **Debt & Credit Tracking**: Record customer credit/debts, manage repayment histories, and monitor outstanding balances.
- 💸 **Expense Tracking**: Categorize daily operating expenses to keep track of store cash flow and net profits.
- 📊 **Business Analytics & Dashboard**: Summarized revenue, expense, and debt statistics with clear visual metrics.
- 🤖 **Kabiz AI Assistant**: Intelligent business guidance interface tailored for local enterprise insights.
- 📱 **Cross-Platform Support**: Optimized for Android devices and responsive Web browsers.

---

## 🛠️ Technology Stack

| Component | Technology | Version |
| :--- | :--- | :--- |
| **Framework** | Flutter | `3.44.8` |
| **Language** | Dart | `3.12.2` |
| **Database** | SQLite (`sqflite`) | `^2.3.0` |
| **State Management** | Provider | `^6.1.2` |
| **Android SDK Target** | API Level | `35` (Android 15) |
| **Gradle / AGP** | Gradle / Android Gradle Plugin | `8.10.2` / `8.7.3` |
| **Kotlin** | Kotlin Compiler | `2.0.21` |

---

## 🚀 Installation & Prerequisites

### Prerequisites
Ensure Flutter SDK (`>=3.0.0`) and Git are installed on your system.

Verify your local environment:
```bash
flutter doctor
```

### Clone & Install
```bash
git clone https://github.com/xenyinnaya/Kabiz.git
cd Kabiz
flutter pub get
```

---

## 💻 Development Workflow

1. **Feature Branching**: Create feature branches off `main`.
2. **Local Testing**: Run the app locally on an Android emulator or Chrome:
   ```bash
   flutter run -d chrome
   ```
3. **Static Analysis & Formatting**:
   ```bash
   flutter analyze
   ```
4. **Commit Guidelines**: Use standard conventional commits (e.g. `feat:`, `fix:`, `chore:`).

---

## 🏗️ Build Instructions

### Run Debug Mode
```bash
flutter run
```

### Build Android Release APK
```bash
flutter build apk --release
```

### Build Android App Bundle (AAB for Google Play)
```bash
flutter build appbundle --release
```
The generated bundle will be located at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 📱 Google Play Deployment Process

1. **Signing Configuration**:
   Ensure `android/key.properties` and keystore (`upload-keystore.jks`) are present locally (excluded from Git version control).

2. **Generate Release App Bundle**:
   ```bash
   flutter build appbundle --release
   ```

3. **Google Play Console Upload**:
   - Log in to the [Google Play Console](https://play.google.com/console).
   - Select the **Kabiz** application.
   - Navigate to **Production** or **Testing (Internal/Closed)** track.
   - Create a new release and upload `build/app/outputs/bundle/release/app-release.aab`.
   - Complete release notes and roll out release.

---

## 📄 License

This project is released under the **MIT License**.
