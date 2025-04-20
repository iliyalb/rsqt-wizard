# Rust Qt Installer Wizard

![App window](Sample.png?raw=true)

## About

This application is a cross-platform installer wizard built using Rust and Qt6. It allows users to easily copy all files from a designated "data" directory (located within the application's project structure) to a user-specified destination directory.  If no destination directory is provided, it defaults to copying the files alongside the executable itself. The wizard provides a progress bar, file name display, and options for calculating required space and creating a desktop shortcut.

**Key Features:**

*   **Cross-Platform Compatibility:** Designed to work on Windows, macOS, and Linux (assuming Qt6 is properly configured).
*   **User-Friendly Interface:**  A QML-based graphical user interface provides an intuitive installation experience.
*   **Progress Tracking:** A real-time progress bar visually indicates the status of the file copying process.
*   **Customizable Destination:** Users can choose where to install the application data.
*   **Required Space Calculation:** Estimates the amount of disk space needed for the installation.
*   **Shortcut Creation (Optional):**  Allows users to create a desktop shortcut for easy access.

## Prerequisites

Before building and running this project, ensure you have the following installed:

1.  **Rust Toolchain:** Install Rust using `rustup`.  You can find instructions at [https://www.rust-lang.org/tools/install](https://www.rust-lang.org/tools/install).
2.  **Qt6 Development Environment:** You need the Qt6 development libraries and tools installed on your system. The installation process varies depending on your operating system:

    *   **Windows:** Install Qt using the online installer from [https://www.qt.io/download](https://www.qt.io/download).  Make sure to select the "Qt for Desktop" option and include the necessary components (e.g., MinGW or MSVC compiler).
    *   **macOS:** Install Qt using Homebrew: `brew install qt6`
    *   **Linux:** Use your distribution's package manager to install Qt6:
    
    Debian/Ubuntu:
    ```sh
    apt-get update && apt-get install qt6-base-dev qt6-default-development-tools
    ```
    Arch:
    ```sh
    pacman -S qt6-base qt6-declarative qt6-tools
    ```

3. **Verify Qt Installation:** After installation, verify that Qt is correctly installed by running `qmake6 --version` in your terminal.  This should output the Qt version number.

## Requirements

*   A "data" directory containing the files to be copied must exist at the root of the project (where the `main.rs` file resides).
*   Sufficient disk space on the destination drive for the installation.

## Build & Run

1.  **Navigate to Project Directory:** Open a terminal and navigate to the root directory of your Rust Qt6 project (the one containing the `Cargo.toml` file).

2.  **Build the Project:** Use Cargo to build the application:
    ```bash
    cargo build --release
    ```
    This will create an optimized release binary in the `target/release` directory.

3.  **Run the Application:** Execute the compiled binary:
    ```bash
    ./target/release/rsqt-wizard # Linux/macOS
    .\target\release\rsqt-wizard.exe # Windows
    ```

## Usage Instructions (Within the App)

1.  The application will open with a default install path (likely alongside the executable).
2.  **Browse for Destination:** Click the "Browse" button to select a different installation directory using a file dialog.
3.  **Calculate Required Space:** The "Required Space" field displays an estimate of the disk space needed based on the files in the `data` directory.
4.  **Create Shortcut (Optional):** Check the "Create Shortcut" box if you want to create a desktop shortcut for easy access after installation.
5.  **Start Installation:** Click the "Install" button to begin copying the files from the `data` directory to the selected destination. A progress bar will indicate the status of the operation.

## Contributing

Contributions are welcome! Feel free to submit issues and pull requests. Here's a brief guide:

1.  **Fork the Repository:** Create your own fork of this repository on GitHub.
2.  **Create a Branch:** Create a new branch for your feature or bug fix: `git checkout -b my-new-feature`
3.  **Make Changes:** Implement your changes, ensuring they adhere to Rust and Qt6 coding conventions.
4.  **Test Thoroughly:** Test your changes thoroughly to ensure they work as expected and don't introduce any regressions.
5.  **Commit Your Changes:** Commit your changes with a descriptive message: `git commit -m "Add feature X"`
6.  **Push to Your Fork:** Push your branch to your forked repository: `git push origin my-new-feature`
7.  **Create a Pull Request:** Create a pull request from your fork to the original repository.

## License

This is free and unencumbered software released into the public domain under The Unlicense.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

See [UNLICENSE](LICENSE) for full details.

## Troubleshooting

*   **Qt Not Found:** If you encounter errors related to Qt not being found, double-check that your environment variables are correctly configured to point to the Qt installation directory.  Specifically, ensure `QT_QMAKE_EXECUTABLE` and `PATH` include the path to `qmake6`.
*   **Permissions Issues:** Ensure you have write permissions to the destination directory.
*   **File Copy Errors:** If file copying fails, verify that the source files exist in the "data" directory and that there are no conflicting files with the same names in the destination directory.
*   **UI Freezing:** The application includes a small delay (`thread::sleep`) to prevent UI freezing during the copy process.  If you still experience freezing, consider increasing this delay or optimizing the file copying logic.

<!--
## Future Enhancements (Ideas)

*   Progress bar with estimated time remaining.
*   More robust error handling and reporting.
*   Support for different installation types (e.g., system-wide vs. user-specific).
*   Option to uninstall previous versions of the application.
*   GUI customization options.
-->
