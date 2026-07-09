# MoneyLog

<p align="center">
  <img src="assets/images/logo.png" alt="MoneyLog Logo" width="140"/>
</p>

A simple and lightweight **Daily Expense Manager** built with Flutter. Record your day-to-day expenses quickly, organize them by category, and keep track of your spending with a clean and minimal interface.

## ✨ Features

* Google Sign-In with Supabase OAuth
* Secure user authentication
* Add daily expense records
* Categorize expenses
* Optional notes for each expense
* Simple grid view of all expenses
* Clean and responsive UI

## 📝 Expense Entry

Each expense includes:

* **Name**
* **Expense Amount**
* **Expense Type**
* **Category**
* **Notes (Optional)**

## 🛠 Tech Stack

* Flutter
* Dart
* Supabase
* Google OAuth
* flutter_bloc

## 📂 Project Structure

```text
lib/
├── core/
├── features/
│   ├── auth/
│   └── expenses/
├── shared/
└── main.dart
```

## 🚀 Getting Started

### Clone the repository

```bash
git clone https://github.com/your-username/moneylog.git
```

### Install dependencies

```bash
flutter pub get
```

### Create a `.env` file

```env
SUPABASE_URL=YOUR_SUPABASE_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Run the app

```bash
flutter run
```

## 📌 Current Version

The current version focuses on fast and simple daily expense tracking.

* Authentication
* Daily expense logging
* Expense list/grid view

## 🔮 Planned Features

* Income tracking
* Search expenses
* Filter by category
* Monthly and yearly reports
* Charts and analytics
* CSV export
* Offline support
* Dark mode

## 📸 Screenshots

Screenshots will be added after the UI is finalized.

## 📄 License

This project is open source and created for learning and portfolio purposes.
