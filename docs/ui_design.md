# 🎨 Alumni Connect — Full UI Design Guide

## Design System (from Stitch)

| Property | Value |
|---|---|
| **Color Mode** | Dark |
| **Primary Color** | `#2463EB` (Blue) |
| **Font** | Inter |
| **Border Radius** | 12px (round-twelve) |
| **Device** | Mobile (390px wide) |
| **Saturation** | 2 |

---

## Color Palette

```
Background:     #0F172A  (Deep Navy)
Surface:        #1E293B  (Dark Slate)
Primary:        #2463EB  (Brand Blue)
Primary Light:  #3B82F6
Accent:         #60A5FA
Text Primary:   #F8FAFC
Text Secondary: #94A3B8
Divider:        #334155
Error:          #EF4444
Success:        #22C55E
Warning:        #F59E0B
```

---

## Typography (Inter Font)

| Style | Size | Weight |
|---|---|---|
| Heading 1 | 28px | Bold (700) |
| Heading 2 | 22px | SemiBold (600) |
| Heading 3 | 18px | SemiBold (600) |
| Body Large | 16px | Regular (400) |
| Body | 14px | Regular (400) |
| Caption | 12px | Regular (400) |
| Label | 12px | Medium (500) |

---

## Screens Overview

### Screen 1: Authentication Login Screen (3 Variants)
**Stitch Screen IDs:** `9b9351a3`, `704872db`, `351b87eb`, `3c894503`

**Purpose:** Entry point for all users

**UI Elements:**
- App logo + tagline at top
- Email & Password fields
- "Login" primary button (full width, blue)
- "Continue with Google" secondary button
- Forgot Password link
- "Don't have an account? Sign Up" link
- Role selector toggle (Student / Alumni)

**States:**
- Default
- Loading (button spinner)
- Error (red error text under field)
- Success → Navigate to Dashboard

**Navigation:**
- Success → Student Dashboard OR Admin Dashboard (based on role)
- Sign Up → Registration screen

---

### Screen 2: Student Dashboard Overview
**Stitch Screen ID:** `40dd654e`

**Purpose:** Home screen for logged-in students/alumni

**UI Sections:**
- Top bar: Welcome message + Avatar + Notification bell
- Stats row: Connections | Mentors | Jobs Applied
- "Explore Alumni" quick action card
- "Upcoming Events" horizontal scroll list
- "Recent Jobs Posted" card list
- "Active Mentorship" card
- Bottom Navigation Bar: Home | Directory | Jobs | Chat | Profile

**Data Sources:**
- Firestore: `users/{uid}`, `jobs/`, `mentorships/`, `events/`

---

### Screen 3: Alumni Directory List
**Stitch Screen ID:** `279076ca`

**Purpose:** Browse and search alumni by name, batch, company, field

**UI Elements:**
- Search bar with filter icon
- Filter chips: Batch Year | Company | Field | Location
- Alumni cards list:
  - Profile photo
  - Name + Batch
  - Current Role + Company
  - "Connect" / "Message" actions
- Pagination (load more on scroll)

**Data Sources:**
- Firestore: `users/` collection (role = alumni, filtered)

---

### Screen 4: Professional Alumni Profile
**Stitch Screen ID:** `ce48b600`

**Purpose:** Detailed view of an individual alumni profile

**UI Sections:**
- Cover photo + profile picture
- Name, Batch, Role, Company
- Bio / About section
- Contact buttons: Message | LinkedIn | Website
- Work Experience timeline
- Education section
- Skills chips
- "Open to Mentoring" badge (if applicable)
- Shared Posts/Jobs section

**Data Sources:**
- Firestore: `users/{uid}`, `posts/{uid}`

---

### Screen 5: Mentorship Program Hub
**Stitch Screen ID:** `2c78c676`

**Purpose:** Connect students with alumni mentors

**UI Sections:**
- "Find a Mentor" search
- Featured Mentors carousel
- Browse by domain (Tech, Finance, Design, etc.)
- My Active Mentorships section
- Pending Requests section
- Mentor cards: Photo | Name | Domain | Availability

**Data Sources:**
- Firestore: `mentorships/`, `users/` (role=alumni, mentor=true)

---

### Screen 6: Jobs and Referrals Board
**Stitch Screen ID:** `e851b420`

**Purpose:** Alumni can post jobs; students can apply or request referrals

**UI Sections:**
- Post a Job button (alumni only)
- Filter bar: Full-time | Internship | Remote | Location
- Job cards:
  - Company Logo + Name
  - Job Title + Type
  - Location + Salary (optional)
  - Posted by (alumni name)
  - Apply | Request Referral buttons
- "My Posted Jobs" tab (alumni view)

**Data Sources:**
- Firestore: `jobs/` collection

---

### Screen 7: Direct Messages Chat
**Stitch Screen ID:** `3c369d5`

**Purpose:** 1-on-1 real-time messaging between users

**UI Elements:**
- Chat list (inbox): User avatar | Name | Last message | Time
- Individual chat screen:
  - Messages bubbles (sent/received)
  - Timestamp
  - Text input + Send button
  - Attachment support (optional)

**Data Sources:**
- Firestore: `chats/{chatId}/messages/` (real-time stream)
- Firestore: `chats/` collection

---

### Screen 8: Activity Notifications Center
**Stitch Screen ID:** `8a65bcbf`

**Purpose:** Show all activity notifications in-app

**UI Elements:**
- Notification items with icon, title, time
- Categories: Mentions | Job Updates | Mentorship | System
- Mark all as read
- Swipe to dismiss

**Data Sources:**
- Firestore: `notifications/{uid}/`
- Firebase Cloud Messaging (FCM) for push

---

### Screen 9: Admin Analytics Dashboard
**Stitch Screen ID:** `d513e4f9`

**Purpose:** Admin-only panel to monitor platform activity

**UI Sections:**
- Total Users | Active This Month | New Signups (stat cards)
- User growth chart (line chart)
- Jobs Posted count
- Top Alumni (most active)
- Pending approvals (new registrations)
- Reported content

**Data Sources:**
- Firestore: Aggregated queries on `users/`, `jobs/`, `reports/`
- Cloud Functions for complex analytics

---

## Screen Navigation Flow

```
App Launch
    ↓
Splash Screen (auto-navigate)
    ↓
[Auth Check]
    ├── Not Logged In → Login Screen → Signup (if new)
    └── Logged In ──────────────────────┐
                                        ↓
                              Role Check
                     ┌─────────┬────────┴──────────┐
                  Student   Alumni               Admin
                     │         │                   │
                     ▼         ▼                   ▼
                Dashboard  Dashboard         Admin Analytics
                     │
              Bottom Nav Bar
         ┌────┬────┬────┬──────┐
         │    │    │    │      │
       Home Dir Jobs Chat Profile
```

---

## Component Library

### Reusable Widgets
| Widget | Description |
|---|---|
| `AppButton` | Primary/secondary/ghost button variants |
| `AlumniCard` | Card for alumni in directory |
| `JobCard` | Card for job listings |
| `NotificationTile` | Single notification row |
| `ChatBubble` | Message bubble (sent/received) |
| `CustomTextField` | Input field with validation |
| `LoadingOverlay` | Full screen loading indicator |
| `EmptyState` | Empty data placeholder |
| `ErrorWidget` | Error with retry button |
| `BottomNavBar` | Main bottom navigation |
| `ProfileAvatar` | Avatar with fallback initials |

---

## Stitch Project Reference

- **Project ID:** `6756343870718518859`
- **Stitch Link:** `https://stitch.withgoogle.com`
- **Theme:** Dark, Inter, #2463EB
- **Screenshots:** Available via Stitch MCP API
