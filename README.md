# GymWing

**(Under Development)**

GymWing is a mobile application that automatically tracks your weightlifting workouts. By simply placing your phone on a weight stack, the app counts your reps, providing real-time audio feedback and analysis of your exercise execution.

## 🚀 Project Overview

GymWing aims to make workout tracking seamless and intelligent. Forget manual rep counting and focus on your form. Our goal is to provide a smart, hands-free experience for gym enthusiasts to monitor their progress and improve their performance.

## ✨ Features

*   **Automatic Rep Counting:** Uses the phone's accelerometer to detect and count repetitions automatically.
*   **Real-time Audio Feedback:** Get instant audio cues for each rep, set completion, and other workout events.
*   **Exercise Analytics:** Provides real-time analysis of exercise execution (feature in development).
*   **Cross-Platform:** Built with Flutter for a consistent experience on both Android and iOS.

## 🏗️ Architecture

GymWing uses a modern, high-performance architecture to deliver real-time processing on mobile devices.

*   **Frontend:** The user interface is a cross-platform application built with **Flutter**.
*   **Backend/Core Logic:** The performance-critical rep counting and data analysis are handled by a **Rust** library (`zacc`).
*   **Integration:** The Flutter app communicates with the Rust backend via a Foreign Function Interface (FFI), ensuring high performance for the estimation algorithms.

## 🛠️ Installation and Setup

To get started with GymWing development, you'll need to set up both the Rust backend and the Flutter frontend.

### Prerequisites

*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   [Rust Toolchain](https://www.rust-lang.org/tools/install) (including `rustc` and `cargo`)
*   Build tools for cross-compiling the Rust library for Android/iOS.

### 1. Build the Rust Library (`zacc`)

The core logic is in the `zacc` directory. You will need to compile it for the target mobile platforms.

```bash
# Navigate to the Rust directory
cd zacc

# Example build command (you may need to adapt this for your specific target)
cargo build --release
```
*(Note: Specific cross-compilation setup for Android and iOS (e.g., via `cargo-lipo` or setting up NDK targets) is required. Refer to Rust and Flutter FFI documentation for details.)*

### 2. Run the Flutter App (`gymwingapp`)

Once the Rust library is built and correctly placed for FFI access, you can run the Flutter application.

```bash
# Navigate to the Flutter app directory
cd gymwingapp

# Install dependencies
flutter pub get

# Run the app on a connected device or simulator
flutter run
```

## 📖 Usage Guide

1.  Open the GymWing app.
2.  Select your workout type.
3.  Place your phone securely on top of the weight stack you are using.
4.  Begin your exercise set.
5.  The app will automatically detect movement, count your reps, and provide audio feedback.

## 📄 License
TODO