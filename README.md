# 🎮 Game Nest - Multi-Game Flutter App

**Game Nest** is a Flutter-based mobile application that hosts multiple offline mini-games in one place. This app provides a fun and interactive platform to play classic games like Tic Tac Toe, Memory Match, Connect 4, Snake, and Hangman. Each game is fully functional, responsive, and designed with engaging UI elements.

---

## 📱 Features

* **Tic Tac Toe:** Classic 3x3 grid game with X and O players.
* **Memory Match:** Flip cards to find matching pairs, improves memory skills.
* **Connect 4:** Drop colored discs into a 7x6 grid to connect four in a row.
* **Snake:** Control the snake to collect food and grow longer without hitting walls.
* **Hangman:** Guess letters to discover the hidden word before reaching the maximum wrong attempts.
* **Responsive UI:** Works on different mobile screen sizes.
* **Offline Play:** No internet connection required.

---

## 🛠️ Getting Started

Follow these steps to run the app on your local machine:

### 1️⃣ Clone the repository

```bash
git clone <your-repo-link>
cd <repo-folder>
```

### 2️⃣ Install dependencies

```bash
flutter pub get
```

### 3️⃣ Set App Launcher Icon (Optional)

If you are using the `flutter_launcher_icons` package, run:

```bash
flutter pub run flutter_launcher_icons:main
```

Or (new recommended command):

```bash
dart run flutter_launcher_icons
```

Make sure you have configured `flutter_launcher_icons` inside your `pubspec.yaml` file before running this command.

### 4️⃣ Run the App

```bash
flutter run
```

---

## 🧩 App Structure

* `main.dart` – Entry point of the application, contains navigation to all games.
* `GameHubHome` – Main menu with all available games as cards.
* Individual game widgets:

    * `TicTacToeGame`
    * `MemoryMatchGame`
    * `ConnectFourGame`
    * `SnakeGame`
    * `HangmanGame`

Each game is implemented as a separate `StatefulWidget` with its own logic and UI.

---

## ⚡ Commands Summary

```bash
flutter pub get
dart run flutter_launcher_icons
flutter run
```

---

## 📌 Notes

* This project is developed as a Final Year Project (FYP).
* Works completely offline.
* No backend or API integration required.
* Compatible with Android and iOS.

---

## 👨‍💻 Author

**Abdul Hannan, Asad Mushtaq Saadi, and Anzar Ahmad**
Flutter Multi-Game Application – FYP Project

