# 🖼️ Curator — The Art of Digital Memories

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white) 
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

**Curator** is a state-of-the-art Flutter gallery application designed with a focus on high-end aesthetics, liquid-smooth animations, and robust functionality. It blends the nostalgia of Polaroid-style cards with a modern, glossy 2024 "Glassmorphism" design system.

---

## ✨ Key Features

- **💎 Premium Glossy UI**: Experience a "frosted glass" interface with intense blurs, inner shadows, and high-gloss navigation bars.
- **📸 Polaroid Masonry Gallery**: A beautifully staggered grid layout that emphasizes visual hierarchy and artistic display.
- **🎨 Dynamic Design System**: Customize your experience with multiple accent colors (Steel Blue, Amber, Emerald, Rose, Lavender) and premium typography (Inter, Roboto, Outfit).
- **🧠 Intelligent Persistence**: Theme settings, font choices, and curated collections are saved locally and persist automatically across app sessions.
- **❤️ Interactive Micro-animations**:
  - Double-tap to like with heart pop animations.
  - Smooth card-slide effects in the bottom navigation.
  - Native gesture-based navigation (swipe between Gallery, Favorites, and Albums).
- **📁 Real-World Curation**: Select actual images from your device's camera roll to build and organize custom digital albums.

---

## 🛠️ Tech Stack

- **Core**: [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Data Persistence**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Backend**: [Firebase Core](https://pub.dev/packages/firebase_core) (AOT-Ready)
- **Styling**: [Google Fonts](https://pub.dev/packages/google_fonts), Custom Material 3 Design System
- **Layout**: [Staggered Grid View](https://pub.dev/packages/flutter_staggered_grid_view)
- **Native Bridges**: Image Picker, Permission Handler

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Channel Stable)
- Android Studio / VS Code with Flutter Extension
- A valid Firebase project

### Installation & Setup

1.  **Clone the project:**
    ```bash
    git clone https://github.com/your-username/polaroid_gallery_app.git
    cd polaroid_gallery_app
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Firebase Configuration**:
    - Download your `google-services.json` from the Firebase Console and place it in `android/app/`.
    - Download your `GoogleService-Info.plist` and place it in `ios/Runner/`.

4.  **Run the app:**
    ```bash
    flutter run
    ```

### Android APK Build
For a performance-optimized release build:
```bash
flutter build apk --release
```

---

## 📱 Screenshots & UI

| Gallery (Masonry) | Navigation | Custom Themes |
| :--- | :--- | :--- |
| ![Gallery View](https://via.placeholder.com/200x400) | ![Nav Bar](https://via.placeholder.com/200x400) | ![Theme Picker](https://via.placeholder.com/200x400) |

---

## 📄 License
Distributed under the MIT License. See `LICENSE` for more information.

---
*Built with ❤️ by Antigravity AI*
