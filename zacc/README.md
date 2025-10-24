# Installtion of NDK:
Install NDK though the Android Studio

rustup target add aarch64-linux-android armv7-linux-androideabi

Deaktivate Anti-Virus and do:
cargo install cargo-ndk


# How to compile:
cargo ndk -t armeabi-v7a -t arm64-v8a build --release

 cargo build --target i686-linux-android
 cargo build --target aarch64-linux-android
 cargo build --target armv7-linux-androideabi

 For Emulator:
 cargo build --target x86_64-linux-android 