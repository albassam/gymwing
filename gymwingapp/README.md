# GymWing

GymWing is a mobile application that likely uses the device's accelerometer for tracking gym exercises.

## Getting Started

### Prerequisites

*   Flutter SDK
*   Android Studio with the Android SDK and emulator
*   Rust and the Android NDK for building the native `zacc` library.

### Build and Run

1.  **Build the native `zacc` library** located in the `zacc` directory of the project.
2.  **Copy the compiled `.so` file** to `android/app/src/main/jniLibs/<abi>/libzacc.so` for each ABI you are targeting (e.g., `armeabi-v7a`, `arm64-v8a`, `x86_64`).
3.  **Run the following command to build the APK:**
    ```powershell
    flutter clean; if (Test-Path .\build\sensors_plus) { Remove-Item -Recurse -Force .\build\sensors_plus }; flutter pub get; flutter build apk -v
    ```
4.  **Run the app on an emulator or connected device:**
    ```bash
    flutter run
    ```

## Developer Commands

*   **Show connected devices:**
    ```bash
    flutter devices
    ```
*   **Show logs:**
    ```bash
    flutter log
    ```