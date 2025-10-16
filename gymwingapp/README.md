# GymWing

## Build the apk File:
'flutter clean; if (Test-Path .\build\sensors_plus) { Remove-Item -Recurse -Force .\build\sensors_plus }; flutter pub get; flutter build apk -v'

## Run the App:
Copy the latest Android library .so file to
(android/app/src/main/jniLibs/<abi>/libzacc.so for each ABI you support, e.g., armeabi-v7a, arm64-v8a, x86_64).

In Android Studio, start the emulator (Pixel 9 SDK 34) and open the Logcat view.

then run:
'flutter run'

or 
'flutter clean; flutter pub get; flutter build apk'

then select the Android target

## Show Logs:
'flutter log'

## Show Available Devices:
'flutter devices'

