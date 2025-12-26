# BadApple-With-Dart

A command-line interface implementation of the famous "Bad Apple!!" animation, written in Dart.

## Features

- **Cross-Platform:** Works on Linux, macOS, and Windows.
- **Responsive:** Automatically adapts to terminal window resizing during playback.

## Prerequisites

- **Dart SDK:** Required to run or compile the source code.
- **Audio Player:**
    - **Linux:** `paplay` (PulseAudio) or `aplay` (ALSA).
    - **macOS:** `afplay`.
    - **Windows:** PowerShell (built-in).

## Installation & Usage

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Eatgrapes/BadApple-With-Dart.git
    cd BadApple-With-Dart
    ```

2.  **Run directly with Dart:**
    ```bash
    dart BadApple.dart
    ```

3.  **Compile to native executable (optional):**
    ```bash
    dart compile exe BadApple.dart -o bad_apple
    ./bad_apple
    ```

## Controls

- **Ctrl+C:** Stop playback and exit

## Credits

- **Original Data & Inspiration:** Portions of the data parsing logic and the data files themselves are adapted from [kzaemrio/BadApple](https://github.com/kzaemrio/BadApple).
