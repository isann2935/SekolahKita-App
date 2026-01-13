# 📚 SekolahKita App

Aplikasi edukasi interaktif yang dirancang untuk membantu siswa belajar dengan cara yang menyenangkan dan engaging melalui berbagai fitur seperti latihan soal, achievement system, dan gamifikasi pembelajaran.

---

## 📖 Deskripsi Aplikasi

**SekolahKita** adalah aplikasi mobile yang dikembangkan dengan Flutter untuk mendukung pembelajaran siswa. Aplikasi ini menyediakan:

- 📝 **Latihan Soal** - Soal-soal matematika, membaca, dan menulis
- 🎮 **Gamifikasi** - Battle mode dan achievement system untuk motivasi belajar
- 🗺️ **Map Learning** - Navigasi pembelajaran yang interaktif
- 👨‍👩‍👧‍👦 **Parent Feature** - Fitur untuk orang tua memantau progress anak
- 🎯 **Custom Questions** - Kemampuan membuat soal kustom
- 📱 **Notifikasi** - Push notification untuk reminder pembelajaran
- ⚙️ **Profile Management** - Kelola profil pengguna dan preferensi

---

## 🛠️ Tech Stack yang Digunakan

### Core Framework

- **Flutter** - Framework UI cross-platform (iOS, Android, Web)
- **Dart** - Bahasa pemrograman

### Dependencies Utama

| Paket                         | Versi   | Fungsi                                |
| ----------------------------- | ------- | ------------------------------------- |
| `google_fonts`                | ^6.1.0  | Typography dengan Google Fonts        |
| `flutter_animate`             | ^4.5.0  | Animasi UI yang smooth                |
| `shared_preferences`          | ^2.2.2  | Local storage & preference management |
| `flutter_local_notifications` | ^18.0.1 | Push notification lokal               |
| `timezone`                    | ^0.10.0 | Timezone handling untuk notifikasi    |
| `cupertino_icons`             | ^1.0.8  | iOS-style icons                       |

### Development Tools

- `flutter_lints` - Code quality & linting
- `flutter_launcher_icons` - Icon management untuk app launcher

### Environment

- **Dart SDK**: ^3.10.0
- **Minimum Android**: API 21 (Android 5.0)

---

## 🚀 Cara Instalasi dan Setup

### Prasyarat

Pastikan Anda telah menginstal:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (versi terbaru)
- [Dart SDK](https://dart.dev/get-dart) (sudah termasuk dalam Flutter)
- Git
- Android Studio / Xcode (untuk development emulator)
- IDE pilihan (VS Code, Android Studio, IntelliJ IDEA)

### Langkah-Langkah Setup

#### 1. Clone Repository

```bash
git clone https://github.com/isann2935/SekolahKita-App.git
cd SekolahKita-App
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Generate Launcher Icons (Opsional)

Jika Anda ingin menggunakan custom launcher icon:

```bash
flutter pub run flutter_launcher_icons
```

#### 4. Setup Environment

Pastikan Flutter sudah terakonfigurasi dengan benar:

```bash
flutter doctor
```

Perintah ini akan menampilkan status semua dependencies yang diperlukan. Pastikan semuanya memiliki centang (✓).

---

## ▶️ Cara Menjalankan Aplikasi

### Menjalankan di Emulator/Device

#### 1. List Available Devices

```bash
flutter devices
```

#### 2. Run di Device Tertentu

```bash
flutter run -d <device-id>
```

#### 3. Run dengan Mode Debug (Default)

```bash
flutter run
```

#### 4. Run dengan Mode Release (Performance Optimal)

```bash
flutter run --release
```

#### 5. Run di Web Browser

```bash
flutter run -d web
```

### Build APK (Android)

```bash
flutter build apk --release
```

APK akan tersimpan di: `build/app/outputs/flutter-apk/app-release.apk`

### Build untuk iOS

```bash
flutter build ios
```

---

## 🔌 Dokumentasi API

### Local Storage API (SharedPreferences)

Aplikasi menggunakan `shared_preferences` untuk menyimpan data lokal.

#### Service Classes

**NotificationService**

```dart
NotificationService().initialize()  // Inisialisasi notification
// Lokasi: lib/services/notification_service.dart
```

**CustomQuestionService**

```dart
// Manage custom questions
// Lokasi: lib/services/custom_question_service.dart
```

### Data Models

#### Data Structure

- **Math Questions** - `lib/data/math_questions.dart`
- **Reading Questions** - `lib/data/reading_questions.dart`
- **Writing Data** - `lib/data/writing_data.dart`

### Screen Architecture

| Screen       | Path                                 | Fungsi                     |
| ------------ | ------------------------------------ | -------------------------- |
| MainWrapper  | `lib/screens/main_wrapper.dart`      | Root navigation            |
| Onboarding   | `lib/screens/onboarding_screen.dart` | First-time user experience |
| Home         | `lib/screens/home/`                  | Dashboard utama            |
| Practice     | `lib/screens/practice/`              | Latihan soal               |
| Battle       | `lib/screens/battle/`                | Mode battle interaktif     |
| Question     | `lib/screens/question/`              | Detail soal dan jawaban    |
| Profile      | `lib/screens/profile/`               | Manajemen profil           |
| Parent       | `lib/screens/parent/`                | Monitoring orang tua       |
| Map          | `lib/screens/map/`                   | Navigasi pembelajaran      |
| Achievements | `lib/screens/achievements/`          | Sistem achievement         |
| Writing      | `lib/screens/writing/`               | Praktik menulis            |

### Theme & Styling

Aplikasi menggunakan Material Design 3 dengan tema custom:

```dart
// Color Theme
// Lokasi: lib/theme/colors.dart
AppColors.softTeal    // Background utama
AppColors.blue        // Primary color
AppColors.textDark    // Text color
```

---

## 📂 Struktur Folder

```
SekolahKita-App/
├── lib/
│   ├── main.dart
│   ├── constants/        # Konstanta aplikasi
│   ├── data/            # Data & models
│   ├── screens/         # UI screens
│   ├── services/        # Business logic & services
│   ├── theme/           # Theme & styling
│   └── widgets/         # Reusable widgets
├── assets/              # Images, fonts, etc
├── android/             # Native Android code
├── ios/                 # Native iOS code
├── web/                 # Web platform
├── test/                # Unit tests
└── pubspec.yaml         # Dependency manager
```

---

## 🔧 Troubleshooting

### Error: "Flutter Command Not Found"

```bash
export PATH="$PATH:`flutter config --android-sdk`"
```

### Error: "Java/Gradle Issues" (Android)

```bash
flutter clean
rm -rf android/.gradle
flutter pub get
flutter run
```

### Error: "Pod Issues" (iOS)

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter pub get
```

### Build Cache Issues

```bash
flutter clean
flutter pub get
flutter run --verbose
```

---

## 📖 Resources & Dokumentasi

- [Flutter Official Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Material Design 3](https://m3.material.io/)
- [Google Fonts Package](https://pub.dev/packages/google_fonts)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## 📝 License

Project ini merupakan bagian dari mata kuliah Rekaya Perangkat Lunak (Software Engineering).

---

## 👥 Tim Pengembang

Dikembangkan sebagai bagian dari tugas Rekaya Perangkat Lunak (Software Engineering).

---

**Happy Learning! 🎉**
