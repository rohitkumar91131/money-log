# MoneyLog

A simple and clean Flutter expense tracking app built for learning and portfolio purposes.

<p align="center">
  <img src="assets/images/logo.png" alt="MoneyLog Logo" width="140"/>
</p>

## Overview

MoneyLog is a lightweight money management application that helps users record their daily expenses with minimal effort.

The goal of this project is to demonstrate clean Flutter architecture, authentication, and basic CRUD functionality without unnecessary complexity.

## Features

* Google Sign-In using Supabase OAuth
* Secure user authentication
* Add expense records
* View expenses in a simple grid layout
* Clean and minimal UI
* Notes support (optional)

## Expense Form

Each expense contains:

* Name
* Expense Amount
* Expense Type
* Category
* Notes (Optional)

## Tech Stack

* Flutter
* Dart
* Supabase
* Google OAuth
* BLoC (State Management)

## Project Structure

```text
lib/
├── core/
├── features/
│   ├── auth/
│   └── expenses/
├── shared/
└── main.dart
```

## Screens

* Authentication
* Expense Form
* Expense Grid

## Getting Started

### Clone the repository

```bash
git clone https://github.com/your-username/moneylog.git
```

### Install dependencies

```bash
flutter pub get
```

### Configure environment variables

Create a `.env` file in the project root.

```env
SUPABASE_URL=YOUR_SUPABASE_URL
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

### Run the app

```bash
flutter run
```

## Dependencies

* supabase_flutter
* flutter_bloc
* flutter_dotenv

## Current Status

This is the initial version of the application.

Current functionality includes:

* User authentication
* Expense entry form
* Expense grid viewer

Future versions may include:

* Search and filtering
* Monthly reports
* Charts and analytics
* Export to CSV
* Offline support
* Dark mode

## Screenshots

Add screenshots here after the UI is complete.

## License

This project is open-source and intended for educational and portfolio use.
