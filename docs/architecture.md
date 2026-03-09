# 🏗️ Alumni Connect — Architecture Design

## Recommended Architecture: **Clean Architecture + BLoC Pattern**

After evaluating multiple Flutter architectures (MVC, MVVM, Provider, GetX, BLoC, Clean Architecture), the best fit for the **alumni_connect** app is:

> **Clean Architecture with BLoC (Business Logic Component) + Repository Pattern**

---

## Why Clean Architecture + BLoC?

| Factor | Reason |
|---|---|
| **Scalability** | App has 9+ screens and will grow — Clean Arch handles this well |
| **Testability** | BLoC separates UI from logic, making unit testing easy |
| **Firebase Integration** | Repository pattern abstracts Firebase neatly |
| **Team Collaboration** | Clear separation of concerns makes it easy to work in teams |
| **Real-time Features** | BLoC handles streams (Firestore, chat) natively |
| **Admin Panel** | Clean separation allows admin vs user logic cleanly |

---

## Architecture Layers

```
┌─────────────────────────────────────────────────┐
│                 PRESENTATION LAYER               │
│        (Screens / Widgets / BLoC / Cubit)        │
├─────────────────────────────────────────────────┤
│                  DOMAIN LAYER                    │
│        (Use Cases / Entities / Interfaces)       │
├─────────────────────────────────────────────────┤
│                   DATA LAYER                     │
│   (Repositories / Firebase / Remote Data Sources)│
└─────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### 1. Presentation Layer
- **Screens** — UI widgets mapped to Stitch designs
- **BLoC/Cubit** — Manages state, listens to events
- **Widgets** — Reusable UI components

#### 2. Domain Layer
- **Entities** — Pure Dart classes (User, Alumni, Job, Message, Mentorship)
- **Use Cases** — Business rules (LoginUser, FetchAlumniList, SendMessage)
- **Repository Interfaces** — Abstractions that data layer implements

#### 3. Data Layer
- **Firebase Firestore** — Remote data source
- **Firebase Auth** — Auth data source
- **Firebase Storage** — File uploads
- **Repository Implementations** — Connect domain interfaces to Firebase

---

## Conceptual Design

```
alumni_connect/
│
├── 📱 AUTH FLOW
│   ├── Splash → Check auth state
│   ├── Login (Email/Password + Google Sign-In)
│   ├── Signup (Student / Alumni / Admin role)
│   └── Role-based routing after login
│
├── 🎓 STUDENT / ALUMNI HOME
│   ├── Dashboard (stats, recent activity)
│   ├── Alumni Directory (search, filter)
│   ├── Individual Profile View
│   └── My Profile (edit)
│
├── 👨‍🏫 MENTORSHIP
│   ├── Browse mentors
│   ├── Request mentorship
│   └── Active mentorships
│
├── 💼 JOBS & REFERRALS
│   ├── Job listings board
│   ├── Post a job (alumni only)
│   ├── Apply / Refer
│   └── My applications
│
├── 💬 MESSAGING
│   ├── Inbox (all conversations)
│   └── Chat screen (realtime)
│
├── 🔔 NOTIFICATIONS
│   └── Activity feed + FCM push
│
└── 🔧 ADMIN PANEL
    ├── Analytics dashboard
    ├── User management
    └── Content moderation
```

---

## State Management Strategy

| Feature | State Tool | Why |
|---|---|---|
| Auth state | BLoC (AuthBloc) | Complex states (loading, error, success) |
| Alumni list | Cubit | Simpler list state |
| Chat messages | BLoC + Firestore Stream | Real-time stream handling |
| Notifications | BLoC | FCM + Firestore events |
| Profile data | Cubit | CRUD operations |
| Admin analytics | Cubit | Data fetching |

---

## Navigation Strategy

Using **GoRouter** (best for Flutter):
- Route-based navigation
- Supports deep linking
- Role-based guards (Admin vs Student vs Alumni)

---

## Tech Stack Summary

| Category | Technology |
|---|---|
| **Framework** | Flutter (Dart) |
| **Architecture** | Clean Architecture + BLoC |
| **State Management** | flutter_bloc |
| **Navigation** | go_router |
| **Backend** | Firebase (Auth, Firestore, Storage, FCM) |
| **Database** | Firestore (NoSQL) |
| **Real-time Chat** | Firestore Streams |
| **Auth** | Firebase Auth + Google Sign-In |
| **Notifications** | Firebase Cloud Messaging (FCM) |
| **Image Picker** | image_picker + Firebase Storage |
| **DI** | get_it + injectable |
| **Network** | Dio (for any REST APIs) |
| **Local Storage** | shared_preferences |

---

## Data Flow Diagram

```
User Action (UI)
      ↓
   BLoC Event
      ↓
   Use Case (Domain)
      ↓
   Repository Interface
      ↓
   Firebase (Data Source)
      ↓
   Repository returns Entity
      ↓
   BLoC emits State
      ↓
   UI rebuilds via BlocBuilder
```

---

## Key Design Decisions

1. **Role-based access** — 3 roles: `student`, `alumni`, `admin`
2. **Dark theme only** — matches Stitch design (dark mode, Inter font, #2463eb blue)
3. **Offline support** — Firestore offline caching enabled
4. **Pagination** — Alumni directory and job board use cursor-based pagination
5. **Security** — Firestore rules enforce role-based read/write access
