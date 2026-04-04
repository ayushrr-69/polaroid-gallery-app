# Curator Gallery

A premium, high-fidelity photo curation and management experience for mobile, featuring a bespoke "Curated." sharing engine and an advanced Glassmorphic design system.

---

## 📸 Overview

Curator is more than just a gallery—it’s an editorial platform for your memories. It follows a strict minimalist aesthetic, utilizing Material 3 principles and deep Glassmorphic layers to create a professional-grade viewing environment.

### Key Visuals
*(Add your high-resolution screenshots in the `metadata/screenshots/` folder and link them below)*

| **Main Gallery** | **Editorial View** | **Custom Share** |
| :---: | :---: | :---: |
| ![Gallery](metadata/screenshots/gallery.png) | ![Preview](metadata/screenshots/preview.png) | ![Share](metadata/screenshots/share.png) |

---

## ✨ Core Features

### 1. "Curated." Sharing Engine (V4.4)
Transform any photo into a professional social media asset.
- **Ultra-HD Rendering**: Generates story-ready assets (1080x1920) with high-fidelity detail.
- **Watermark Branding**: Distinct "Curated." watermark positioned for maximum aesthetic impact.
- **The "Thin Chin" Polaroid**: A modern take on the classic Polaroid layout with sharp edges and a minimalist white border.
- **Dynamic Centering**: Intelligently positions your memories just above the frame's center for optimal viewing on mobile devices.

### 2. RGB Photo-Match Technology
Perfectly coordinate your sharing backgrounds.
- **Palette Extraction**: Automatically identifies the top 3 dominant colors from your photo.
- **Custom RGB Wheel**: Granular control via a precise color wheel, allowing for any custom background hue.
- **Multi-Style Support**: Choose between immersive Blurs, clean Gradients, or Solid color backgrounds.

### 3. Professional UI Architecture
- **Glassmorphism**: High-sigma blurring and inner-glow shadow layers for a truly premium feel.
- **Masonry Layout**: Staggered grid rendering for a dynamic, non-repetitive gallery flow.
- **Persistence**: Your preferences for accent colors and theme modes are saved locally.

---

## 🛠️ Technical Implementation

### Architecture
Ordered for clarity and scale:
- `lib/models/`: Robust data structures.
- `lib/screens/`: Feature-rich, modular view layers.
- `lib/services/`: Core logic for Firebase, image processing, and generation.
- `lib/widgets/`: Reusable, atomic UI components.

### Tech Stack
- **Framework**: Flutter (Mobile-Focused)
- **Backend**: Firebase (Core, Auth, Firestore)
- **Styling**: Google Fonts (Playfair Display, Inter, Outfit)
- **Plugins**: Staggered Grid, Palette Generator, Color Picker, Screenshot.

---

## 🚀 Getting Started

### Installation
1. **Clone & Install**:
   ```bash
   git clone https://github.com/your-username/curator_gallery.git
   cd curator_gallery
   flutter pub get
   ```
2. **Firebase Setup**:
   Place your `google-services.json` in `android/app/` and `GoogleService-Info.plist` in `ios/Runner/`.

3. **Build APK**:
   ```bash
   flutter build apk --release
   ```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

Developed with ❤️ by **Ayush Rajput**
