# 📁 Alumni Connect — Project Structure

## Complete Folder Structure (Clean Architecture + BLoC)

```
alumni_connect/
├── docs/                          ← 📚 Design & Documentation
│   ├── architecture.md
│   ├── ui_design.md
│   ├── project_structure.md
│   └── requirements.md
│
├── lib/
│   ├── main.dart                  ← App entry point
│   ├── app.dart                   ← MaterialApp + GoRouter setup
│   │
│   ├── core/                      ← 🔧 Shared utilities
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_strings.dart
│   │   │   └── app_sizes.dart
│   │   ├── errors/
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── utils/
│   │   │   ├── validators.dart
│   │   │   ├── date_utils.dart
│   │   │   └── image_utils.dart
│   │   ├── widgets/               ← Reusable UI components
│   │   │   ├── app_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_overlay.dart
│   │   │   ├── empty_state.dart
│   │   │   ├── profile_avatar.dart
│   │   │   └── bottom_nav_bar.dart
│   │   └── theme/
│   │       ├── app_theme.dart
│   │       └── app_decorations.dart
│   │
│   ├── features/                  ← 🧩 Feature modules
│   │
│   │   ├── auth/                  ← 🔐 Authentication
│   │   │   ├── data/
│   │   │   │   ├── datasources/
│   │   │   │   │   └── auth_remote_datasource.dart
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository_impl.dart
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user_entity.dart
│   │   │   │   ├── repositories/
│   │   │   │   │   └── auth_repository.dart
│   │   │   │   └── usecases/
│   │   │   │       ├── login_usecase.dart
│   │   │   │       ├── signup_usecase.dart
│   │   │   │       ├── google_signin_usecase.dart
│   │   │   │       └── logout_usecase.dart
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── auth_bloc.dart
│   │   │       │   ├── auth_event.dart
│   │   │       │   └── auth_state.dart
│   │   │       └── screens/
│   │   │           ├── login_screen.dart
│   │   │           └── signup_screen.dart
│   │   │
│   │   ├── dashboard/             ← 🏠 Student Dashboard
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── dashboard_cubit.dart
│   │   │       │   └── dashboard_state.dart
│   │   │       ├── screens/
│   │   │       │   └── dashboard_screen.dart
│   │   │       └── widgets/
│   │   │           ├── stats_row.dart
│   │   │           └── activity_feed.dart
│   │   │
│   │   ├── alumni_directory/      ← 👥 Alumni Directory
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       │   ├── alumni_cubit.dart
│   │   │       │   └── alumni_state.dart
│   │   │       ├── screens/
│   │   │       │   └── alumni_directory_screen.dart
│   │   │       └── widgets/
│   │   │           └── alumni_card.dart
│   │   │
│   │   ├── profile/               ← 👤 User Profile
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       ├── screens/
│   │   │       │   ├── profile_screen.dart
│   │   │       │   └── edit_profile_screen.dart
│   │   │       └── widgets/
│   │   │
│   │   ├── mentorship/            ← 🎓 Mentorship Hub
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       ├── screens/
│   │   │       │   └── mentorship_screen.dart
│   │   │       └── widgets/
│   │   │           └── mentor_card.dart
│   │   │
│   │   ├── jobs/                  ← 💼 Jobs & Referrals
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       ├── screens/
│   │   │       │   ├── jobs_screen.dart
│   │   │       │   └── post_job_screen.dart
│   │   │       └── widgets/
│   │   │           └── job_card.dart
│   │   │
│   │   ├── messaging/             ← 💬 Direct Messages
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── bloc/
│   │   │       │   ├── chat_bloc.dart
│   │   │       │   ├── chat_event.dart
│   │   │       │   └── chat_state.dart
│   │   │       ├── screens/
│   │   │       │   ├── inbox_screen.dart
│   │   │       │   └── chat_screen.dart
│   │   │       └── widgets/
│   │   │           ├── chat_bubble.dart
│   │   │           └── message_input.dart
│   │   │
│   │   ├── notifications/         ← 🔔 Notifications
│   │   │   ├── data/
│   │   │   ├── domain/
│   │   │   └── presentation/
│   │   │       ├── cubit/
│   │   │       └── screens/
│   │   │           └── notifications_screen.dart
│   │   │
│   │   └── admin/                 ← 🔧 Admin Panel
│   │       ├── data/
│   │       ├── domain/
│   │       └── presentation/
│   │           ├── cubit/
│   │           └── screens/
│   │               └── admin_dashboard_screen.dart
│   │
│   ├── navigation/                ← 🧭 Routing
│   │   ├── app_router.dart        ← GoRouter setup
│   │   └── route_names.dart       ← Named route constants
│   │
│   └── injection/                 ← 💉 Dependency Injection
│       ├── injection.dart         ← get_it setup
│       └── injection.config.dart  ← generated by injectable
│
├── assets/
│   ├── images/
│   │   └── app_logo.png
│   ├── icons/
│   └── fonts/
│       └── Inter/
│
├── test/
│   ├── features/
│   │   ├── auth/
│   │   └── alumni_directory/
│   └── core/
│
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## Feature Module Pattern

Each feature follows this exact structure:

```
feature_name/
├── data/
│   ├── datasources/        ← Firebase calls
│   ├── models/             ← JSON serializable classes
│   └── repositories/       ← Repository implementations
├── domain/
│   ├── entities/           ← Pure Dart classes
│   ├── repositories/       ← Abstract interfaces
│   └── usecases/           ← Single-purpose business logic
└── presentation/
    ├── bloc/ OR cubit/     ← State management
    ├── screens/            ← Full page widgets
    └── widgets/            ← Screen-specific widgets
```

---

## Naming Conventions

| Type | Convention | Example |
|---|---|---|
| Files | snake_case | `alumni_card.dart` |
| Classes | PascalCase | `AlumniCard` |
| Variables | camelCase | `alumniList` |
| Constants | SCREAMING_SNAKE | `APP_NAME` |
| BLoC events | PascalCase + `Event` | `FetchAlumniEvent` |
| BLoC states | PascalCase + `State` | `AlumniLoadedState` |
| Cubits | PascalCase + `Cubit` | `DashboardCubit` |
| Use cases | Verb + PascalCase | `FetchAlumniUseCase` |
| Screens | PascalCase + `Screen` | `AlumniDirectoryScreen` |
| Widgets | PascalCase | `AlumniCard` |

---

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Navigation
  go_router: ^13.0.0

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.10
  google_sign_in: ^6.2.1

  # Dependency Injection
  get_it: ^7.6.7
  injectable: ^2.3.2

  # Networking
  dio: ^5.4.0

  # Local Storage
  shared_preferences: ^2.2.2

  # UI / Utils
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  intl: ^0.19.0
  timeago: ^3.6.1
  fl_chart: ^0.66.2   # For admin charts
  shimmer: ^3.0.0      # Loading skeleton

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  injectable_generator: ^2.4.1
  bloc_test: ^9.1.5
  mockito: ^5.4.4
  flutter_lints: ^3.0.1
```
