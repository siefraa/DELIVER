# 🚚 DeliverEasy - Delivery Service App

A full-featured Flutter delivery service app with **Client** and **Admin** portals, **Swahili/English** language support, and beautiful Material 3 theming.

---

## 📱 Screenshots Overview

| Role Selection | Client Home | Track Order | Admin Dashboard |
|---|---|---|---|
| Language Picker | Quick Actions + Orders | Live Tracking Progress | Stats + Charts |

---

## ✨ Features

### 🧑 Client Side
- **Role Selection** — Choose Client or Admin on launch
- **Home Dashboard** — Greeting, search, quick actions, promo banner, recent orders
- **Place Order (4-step wizard)**
  1. Pickup & delivery addresses
  2. Package details (weight, description, instructions)
  3. Delivery type (Standard / Express / Same Day)
  4. Payment method (Cash / Mobile Money / Credit Card)
- **Order Tracking** — Enter tracking number, live status progress steps
- **Order History** — Tabbed: All / Active / Completed / Cancelled
- **Order Detail** — Full timeline, addresses, driver info
- **Notifications** — Unread badge, notification list
- **Profile** — Edit profile, language picker, dark mode toggle, logout

### 🛠 Admin Side
- **Dashboard** — Welcome banner, stats grid (orders, deliveries, revenue, drivers)
- **Revenue Chart** — Line chart with fl_chart
- **Orders by Status** — Pie chart breakdown
- **Manage Orders** — Search, filter by status, update order status via bottom sheet
- **Manage Drivers** — Tabbed by availability, driver cards with stats, add driver form
- **Profile** — Admin settings

### 🌍 Language Support
- **English** (en)
- **Kiswahili** (sw) — Full translation of all UI strings
- Language switcher on role selection screen AND in profile settings

### 🎨 Theming
- Material 3 design system
- Custom color palette: Deep Navy + Vibrant Orange accent
- Light & Dark mode support
- Google Fonts (Poppins)
- Custom cards, badges, gradients, animated step indicators

---

## 🗂 Project Structure

```
lib/
├── main.dart                    # App entry point, router
├── theme/
│   └── app_theme.dart           # Full Material 3 theme + AppColors
├── models/
│   └── models.dart              # Order, Driver, User, Stats models + sample data
├── services/
│   └── app_state.dart           # ChangeNotifier state (theme, locale, auth, orders)
├── l10n/
│   ├── app_en.arb               # English strings
│   └── app_sw.arb               # Swahili strings
├── widgets/
│   └── shared_widgets.dart      # OrderCard, DriverCard, StatsCard, EmptyState, etc.
└── screens/
    ├── auth/
    │   └── role_selection_screen.dart
    ├── client/
    │   ├── client_home_screen.dart    # + OrderDetailScreen
    │   ├── client_orders_screen.dart  # + TrackOrderScreen
    │   └── place_order_screen.dart
    ├── admin/
    │   ├── admin_dashboard_screen.dart
    │   ├── admin_orders_screen.dart
    │   └── admin_drivers_screen.dart
    └── shared/
        └── profile_screen.dart        # + NotificationsScreen
```

---

## 🚀 Build Instructions

### Prerequisites
- Flutter SDK 3.13+ → https://docs.flutter.dev/get-started/install
- Android Studio or VS Code with Flutter plugin
- Android SDK (API 21+)
- Java 11+

### Steps

```bash
# 1. Clone / extract this project
cd deliveryapp

# 2. Get dependencies
flutter pub get

# 3. Generate localizations
flutter gen-l10n

# 4. Run on emulator or device
flutter run

# 5. Build release APK
flutter build apk --release

# 6. Build app bundle (for Play Store)
flutter build appbundle --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Debug APK (no signing required)
```bash
flutter build apk --debug
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `provider` | State management |
| `google_fonts` | Poppins font family |
| `fl_chart` | Revenue line chart + pie chart |
| `shared_preferences` | Persist theme/language settings |
| `go_router` | Navigation |
| `intl` | Localization |
| `geolocator` | GPS location access |
| `flutter_map` | Map views |
| `image_picker` | Profile photo upload |
| `http` / `dio` | API calls |
| `uuid` | Unique order ID generation |
| `timeline_tile` | Delivery timeline |
| `badges` | Notification count badge |
| `sqflite` | Local database |

---

## 🔌 Backend Integration

The app uses `SampleData` for demo purposes. To connect a real backend:

1. Replace `SampleData.orders` in `AppState` with API calls via `http`/`dio`
2. Implement real auth in `loginAsClient()` / `loginAsAdmin()`
3. Add JWT token management in `shared_preferences`
4. The API service layer is pre-wired — just implement the endpoints

Suggested REST endpoints:
```
POST /auth/login
GET  /orders
POST /orders
PUT  /orders/:id/status
GET  /drivers
POST /drivers
GET  /dashboard/stats
```

---

## 🌟 Customization

- **Colors** → Edit `AppColors` in `lib/theme/app_theme.dart`
- **Translations** → Edit `lib/l10n/app_en.arb` and `app_sw.arb`
- **App Name** → Update `appName` in both ARB files + `pubspec.yaml`
- **Package ID** → Update `applicationId` in `android/app/build.gradle`

---

## 📄 License

MIT License — Free to use for commercial and personal projects.

Built with ❤️ for the East African delivery market.
# DELIVER
