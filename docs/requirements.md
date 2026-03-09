# 📋 Alumni Connect — Requirements Document

## 1. Project Overview

**App Name:** Alumni Connect  
**Type:** Mobile App (Flutter — iOS & Android)  
**Purpose:** A platform connecting students with alumni for networking, mentorship, job referrals, and career support.  
**Target Users:** Students, Alumni, Admin

---

## 2. User Roles

| Role | Description | Access |
|---|---|---|
| **Student** | Currently studying or recent graduate | Directory, Mentorship (request), Jobs (apply), Chat |
| **Alumni** | Graduated, working professional | Directory, Mentorship (offer), Jobs (post), Chat |
| **Admin** | Platform administrator | Full access + Analytics + User management |

---

## 3. Functional Requirements

### 3.1 Authentication
| ID | Requirement |
|---|---|
| FR-01 | Users can register with Email + Password |
| FR-02 | Users can login with Email + Password |
| FR-03 | Users can login with Google Sign-In |
| FR-04 | Users select their role during registration (Student / Alumni) |
| FR-05 | Admin accounts are created manually (not via self-registration) |
| FR-06 | Forgot password via email reset |
| FR-07 | Session persistence (auto-login on app restart) |
| FR-08 | Secure logout |

### 3.2 Alumni Directory
| ID | Requirement |
|---|---|
| FR-09 | View a searchable list of all alumni |
| FR-10 | Filter alumni by batch year, company, field, location |
| FR-11 | View full profile of any alumni |
| FR-12 | Send connection request / follow alumni |
| FR-13 | Pagination (20 per page, load more on scroll) |

### 3.3 Profile Management
| ID | Requirement |
|---|---|
| FR-14 | Users can view and edit their own profile |
| FR-15 | Profile includes: Name, Photo, Batch, Bio, Work Experience, Education, Skills |
| FR-16 | Alumni can toggle "Open to Mentoring" flag |
| FR-17 | Profile photo upload via camera or gallery |
| FR-18 | View other user profiles (read-only) |

### 3.4 Mentorship Program
| ID | Requirement |
|---|---|
| FR-19 | Students can browse available mentors |
| FR-20 | Students can send mentorship requests |
| FR-21 | Alumni can accept or decline mentorship requests |
| FR-22 | Active mentorships shown as ongoing relationships |
| FR-23 | Filter mentors by domain/field |

### 3.5 Jobs & Referrals
| ID | Requirement |
|---|---|
| FR-24 | Alumni can post job listings |
| FR-25 | Students can view all job listings |
| FR-26 | Students can apply to jobs |
| FR-27 | Students can request referral from a specific alumni |
| FR-28 | Filter jobs by type (Full-time, Internship, Remote) |
| FR-29 | Alumni can manage their posted jobs (edit/delete) |

### 3.6 Direct Messaging
| ID | Requirement |
|---|---|
| FR-30 | Any user can initiate a 1-on-1 chat with another user |
| FR-31 | Real-time message delivery (Firestore streams) |
| FR-32 | Inbox shows all conversations with last message preview |
| FR-33 | Unread message count badge |
| FR-34 | Messages display with timestamp |

### 3.7 Notifications
| ID | Requirement |
|---|---|
| FR-35 | In-app notifications for: new messages, job updates, mentorship requests |
| FR-36 | Push notifications via Firebase Cloud Messaging (FCM) |
| FR-37 | Mark notifications as read |
| FR-38 | Notification count badge on bell icon |

### 3.8 Admin Panel
| ID | Requirement |
|---|---|
| FR-39 | Admin can view platform analytics (users, jobs, activity) |
| FR-40 | Admin can approve/reject new user registrations (optional) |
| FR-41 | Admin can delete users or content |
| FR-42 | View charts for user growth and activity |

---

## 4. Non-Functional Requirements

| ID | Category | Requirement |
|---|---|---|
| NFR-01 | Performance | App should load dashboard in < 2 seconds |
| NFR-02 | Scalability | Firestore structure supports 10,000+ users |
| NFR-03 | Security | Firestore security rules enforce role-based access |
| NFR-04 | Offline | Firestore offline caching for read operations |
| NFR-05 | UI/UX | Dark theme, Inter font, consistent with Stitch design |
| NFR-06 | Testing | Unit tests for all BLoC/Cubit and Use Cases |
| NFR-07 | Compatibility | Android API 21+ and iOS 12+ |
| NFR-08 | Accessibility | Font scaling support, sufficient color contrast |

---

## 5. Firestore Data Schema

### Collection: `users`
```json
{
  "uid": "string",
  "email": "string",
  "name": "string",
  "photoUrl": "string",
  "role": "student | alumni | admin",
  "batch": "number",
  "bio": "string",
  "company": "string",
  "position": "string",
  "skills": ["string"],
  "isAvailableForMentoring": "boolean",
  "createdAt": "timestamp",
  "lastSeen": "timestamp"
}
```

### Collection: `jobs`
```json
{
  "id": "string",
  "title": "string",
  "company": "string",
  "type": "full-time | internship | remote",
  "location": "string",
  "description": "string",
  "postedBy": "uid",
  "postedByName": "string",
  "createdAt": "timestamp",
  "isActive": "boolean"
}
```

### Collection: `mentorships`
```json
{
  "id": "string",
  "mentorId": "uid",
  "menteeId": "uid",
  "status": "pending | active | completed | rejected",
  "domain": "string",
  "createdAt": "timestamp"
}
```

### Collection: `chats`
```json
{
  "id": "string",
  "participants": ["uid1", "uid2"],
  "lastMessage": "string",
  "lastMessageTime": "timestamp",
  "unreadCount": { "uid1": 0, "uid2": 2 }
}
```

### SubCollection: `chats/{chatId}/messages`
```json
{
  "id": "string",
  "senderId": "uid",
  "text": "string",
  "sentAt": "timestamp",
  "isRead": "boolean"
}
```

### Collection: `notifications`
```json
{
  "id": "string",
  "userId": "uid",
  "type": "message | job | mentorship | system",
  "title": "string",
  "body": "string",
  "isRead": "boolean",
  "createdAt": "timestamp"
}
```

---

## 6. Firebase Services Required

| Service | Purpose | Setup Priority |
|---|---|---|
| **Firebase Auth** | Login, Signup, Google Sign-In | 🔴 Priority 1 |
| **Cloud Firestore** | All app data | 🔴 Priority 1 |
| **Firebase Storage** | Profile photos, media | 🟡 Priority 2 |
| **Firebase Messaging** | Push notifications | 🟡 Priority 2 |
| **Cloud Functions** | Admin analytics, complex logic | 🟢 Priority 3 |

---

## 7. Development Phases

### Phase 1 — Foundation (Week 1-2)
- [ ] Project setup + folder structure
- [ ] Firebase initialization
- [ ] Theme setup (dark mode, colors, fonts)
- [ ] Navigation setup (GoRouter)
- [ ] DI setup (get_it + injectable)

### Phase 2 — Auth (Week 2-3)
- [ ] Login screen
- [ ] Signup screen (with role selection)
- [ ] Google Sign-In
- [ ] Auth BLoC
- [ ] Firestore user creation on signup

### Phase 3 — Core Features (Week 3-6)
- [ ] Student Dashboard
- [ ] Alumni Directory
- [ ] Profile screens
- [ ] Mentorship Hub
- [ ] Jobs Board

### Phase 4 — Social Features (Week 6-8)
- [ ] Direct Messaging
- [ ] Notifications (in-app + FCM)

### Phase 5 — Admin & Polish (Week 8-10)
- [ ] Admin Dashboard
- [ ] Analytics charts
- [ ] Testing & bug fixing
- [ ] Performance optimizations

---

## 8. Environment Setup Checklist

- [ ] Flutter SDK installed (3.x+)
- [ ] Firebase project created
- [ ] `google-services.json` added (Android)
- [ ] `GoogleService-Info.plist` added (iOS)
- [ ] Firebase CLI installed
- [ ] FlutterFire CLI installed (`flutterfire configure`)
- [ ] Firestore database created
- [ ] Firebase Auth enabled (Email + Google)
- [ ] Firebase Storage bucket created
- [ ] FCM configured
