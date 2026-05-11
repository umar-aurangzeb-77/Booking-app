# 🚀 Beginner's Guide: Setting Up Your Laptop to Run the Room Booking App

Welcome! This guide will help you set up everything you need to run this app on your computer, even if you've never coded before. Follow these steps one by one.

---

## 🛠 Step 1: Install the Tools

You need to download and install a few programs:

1. **Flutter SDK**: The engine that runs this app.
    * Go to [flutter.dev](https://docs.flutter.dev/get-started/install/windows) and follow the "Install" instructions for Windows.
2. **Visual Studio Code (VS Code)**: This is where you will see the code.
    * Download it from [code.visualstudio.com](https://code.visualstudio.com/).
    * Once installed, open VS Code, click the **Extensions** icon (looks like 4 squares) on the left, and search for/install the **"Flutter"** extension.
3. **Node.js**: Needed to talk to the database (Firebase).
    * Download the "LTS" version from [nodejs.org](https://nodejs.org/).
4. **Git**: Needed to manage the files.
    * Download from [git-scm.com](https://git-scm.com/).

---

## 🔑 Step 2: Setup the Database (Firebase)

Since we just moved to Firebase, you need the "Firebase CLI" installed.

1. Open your terminal (search for "Command Prompt" or "PowerShell" in your Start Menu).
2. Type this and hit Enter:

    ```bash
    npm install -g firebase-tools
    ```

3. Then log in:

    ```bash
    firebase login
    ```

    *A web browser will open. Log in with your Gmail account.*

---

## 📂 Step 3: Open the Project

1. Open **VS Code**.
2. Go to **File > Open Folder**.
3. Navigate to where you saved the project and select the **`frontend`** folder inside `Booking-app`.

---

## 🚀 Step 4: Run the App

1. In VS Code, go to the menu at the top and click **Terminal > New Terminal**.
2. In that terminal window at the bottom, type this to get all the pieces (dependencies) ready:

    ```bash
    flutter pub get
    ```

3. Connect to your Firebase project (if you haven't yet):

    ```bash
    flutterfire configure
    ```

    *Select your project name using the arrow keys and hit Enter.*
4. **Launch the app!** Type this to see it in your browser (Google Chrome):

    ```bash
    flutter run -d chrome
    ```

---

## 🌍 Step 5: Put it on the Internet (Google Firebase Hosting)

If you want others to visit your app through a link (like `myapp.web.app`), follow these steps:

1. **Build the website version**:
    ```bash
    flutter build web
    ```
2. **Initialize Hosting** (only the first time):
    ```bash
    firebase init hosting
    ```
    *   Choose "Use an existing project".
    *   Select your project.
    *   What do you want to use as your public directory? Type **`build/web`**.
    *   Configure as a single-page app? Type **`y`**.
    *   Set up automatic builds/deploys with GitHub? Type **`n`**.
3. **Deploy it!**:
    ```bash
    firebase deploy
    ```
    *Once finished, it will give you a "Hosting URL" where anyone can see your app!*

---

## 🤖 What is Antigravity?

**Antigravity** is your AI Coding Assistant (that's me!). 
*   You **don't need** to download or run me for the app to work.
*   The app is built using **Flutter**, which is independent.
*   If you share the code ZIP with a friend, they only need the **Step 1** tools (Flutter, VS Code) to run it. I am just here to help you build and fix things!

---

## 💡 Quick Tips for Beginners

* **Hot Reload**: If you change the code, just press `r` in the terminal to see changes instantly without restarting!
* **Errors?**: If you see red text, usually running `flutter pub get` again fixes it.
* **Login**: The Admin login we set up for you is:
  * **Email**: `admin@gmail.com`
  * **Password**: `admin123`

Congratulations! You are now running a professional-grade Flutter application! 🎉
