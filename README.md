# NS Electrical - Electrical Distribution Management System

A comprehensive Flutter application for managing electrical distribution systems, designed to work seamlessly on both mobile and web platforms.

## Features

- DTR (Distribution Transformer) management
- Pole scheduling and tracking
- Reporting and analytics
- Voice search capabilities
- Data export functionality
- Responsive design for all device sizes

## Getting Started

### Prerequisites

- Flutter SDK 3.19.0 or higher
- Dart SDK 3.9.0 or higher
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```

2. Navigate to the project directory:
   ```bash
   cd nselectrical
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

## Running the Application

### Mobile (Android/iOS)

To run on a connected device or emulator:
```bash
flutter run
```

To run on a specific platform:
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios
```

### Web

To run on the web:
```bash
flutter run -d chrome
```

Or to run on a specific browser:
```bash
# Firefox
flutter run -d firefox

# Edge
flutter run -d edge
```

### Desktop (Windows/macOS/Linux)

To run on desktop:
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Building for Production

### Mobile

```bash
# Android
flutter build apk

# iOS
flutter build ios
```

### Web

```bash
flutter build web
```

The web build will be available in the `build/web` directory.

### Desktop

```bash
# Windows
flutter build windows

# macOS
flutter build macos

# Linux
flutter build linux
```

## Responsive Design

This application is designed with responsive principles to work well on:
- Mobile phones (portrait and landscape)
- Tablets
- Desktop browsers

The UI automatically adapts to different screen sizes using custom responsive widgets.

## Project Structure

```
lib/
├── main.dart                 # Entry point
├── src/
│   ├── app.dart              # Main app configuration
│   ├── core/                 # Core business logic
│   │   ├── models/           # Data models
│   │   └── services/         # Business services
│   ├── features/             # Feature modules
│   │   ├── auth/             # Authentication
│   │   ├── dtr/              # DTR management
│   │   ├── home/             # Home/dashboard
│   │   ├── pole/             # Pole management
│   │   ├── reports/          # Reporting
│   │   └── splash/           # Splash screen
│   └── shared/               # Shared utilities
│       ├── constants/        # App constants
│       └── widgets/          # Reusable widgets
```

## Dependencies

Key dependencies include:
- `provider` for state management
- `google_fonts` for typography
- `floor` for local database
- `fl_chart` for data visualization
- `speech_to_text` for voice search
- `share_plus` for sharing functionality

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue on the GitHub repository.