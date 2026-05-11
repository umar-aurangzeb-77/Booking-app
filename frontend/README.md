# Room Booking Application

A premium, role-based room booking application built with Flutter and Firebase. This app features distinct themes for Students (Green) and Admins (Red/Cream).

## 🚀 Getting Started

If you are a beginner, please read our [BEGINNER_GUIDE.md](../BEGINNER_GUIDE.md) in the root directory for a step-by-step setup on your machine.

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel)
*   [Firebase CLI](https://firebase.google.com/docs/cli)
*   Dart 3.0+

### Installation

1.  **Clone the repository/Unzip the code**.
2.  **Navigate to the frontend directory**:
    ```bash
    cd frontend
    ```
3.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Configure Firebase**:
    If you are running this for the first time, ensure you have a `firebase_options.dart` in `lib/`. If not, run:
    ```bash
    flutterfire configure
    ```
5.  **Run the application**:
    ```bash
    flutter run -d chrome
    ```

## 🏗 Project Structure

*   `lib/models`: Data structures for Rooms, Students, and Bookings.
*   `lib/providers`: State management (Auth, Room, Booking).
*   `lib/services`: Firebase Firestore integration logic.
*   `lib/theme`: Role-based dynamic theme system.
*   `lib/pages`: UI screens for Student and Admin flows.

## 🌐 Deployment (Google Firebase)

To host this application on the web using Google Firebase:

1.  Build the web production bundle:
    ```bash
    flutter build web
    ```
2.  Deploy to Firebase Hosting:
    ```bash
    firebase deploy
    ```

## 🤖 Note on Antigravity

**Antigravity** is the AI Coding Assistant used to develop this project. You do not need any special software or the "Antigravity tool" to run this app. It is a standard Flutter project that runs on any machine with the Flutter SDK installed.
