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

## ✅ Prerequisites

Before running or building this project, make sure the following are installed on your system:

1. **Flutter SDK** – [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Dart SDK** – comes bundled with Flutter, no separate installation needed.
3. **Android Studio** – [Download Android Studio](https://developer.android.com/studio)
4. **Android SDK** – install via Android Studio → More Actions → SDK Manager → install the latest Android SDK, SDK Platform-Tools, and SDK Build-Tools.

After installing everything, verify your setup by running:

```bash
flutter doctor
```

Fix any issues it reports (missing licenses, missing SDKs, etc.). If it complains about Android licenses, run:

```bash
flutter doctor --android-licenses
```

---

## 🛠️ Getting Started

Follow these steps to run the app on your local machine:

### 1️⃣ Clone the repository

```bash
git clone <your-repo-link>
cd <repo-folder>
```

### 2️⃣ Clean the project

```bash
flutter clean
```

This removes old build files and cached data so you start with a fresh build.

### 3️⃣ Install dependencies

```bash
flutter pub get
```

### 4️⃣ Set App Launcher Icon (Optional)

If you are using the `flutter_launcher_icons` package, run:

```bash
flutter pub run flutter_launcher_icons:main
```

Or (new recommended command):

```bash
dart run flutter_launcher_icons
```

Make sure you have configured `flutter_launcher_icons` inside your `pubspec.yaml` file before running this command.

### 5️⃣ Run the App (Debug mode, on a connected device/emulator)

```bash
flutter run
```

### 6️⃣ Build the APK (Release build)

```bash
flutter build apk
```

Once the build finishes successfully, the APK file will be located at:

```
build/app/outputs/flutter-apk/app-release.apk
```

You can copy this `app-release.apk` file to an Android device and install it directly, or share it as needed.

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
flutter clean
flutter pub get
dart run flutter_launcher_icons
flutter run
flutter build apk
```

---

## 📌 Notes

* This project is developed as a Final Year Project (FYP).
* Works completely offline.
* No backend or API integration required.
* Compatible with Android and iOS.
* Make sure you have a stable internet connection during `flutter pub get`, since it downloads packages from the internet.
* The `flutter build apk` command may take a few minutes depending on your system.
* If the build fails, run `flutter doctor` again to check for any missing setup steps.

---

## 👨‍💻 Author

**Abdul Hannan, Asad Mushtaq Saadi, and Anzar Ahmad**
Flutter Multi-Game Application – FYP Project