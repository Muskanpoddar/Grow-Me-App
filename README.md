# 🌱 Grow Me – Habit & Goal Tracking App

**Grow Me** is a personal growth and habit-tracking mobile application built using **Flutter** and **Firebase**.  
It helps users set daily goals, track progress, stay consistent, and connect with others through a simple community system.


## 🚀 Features

### 🔐 Authentication
- Email & password login
- Google Sign-In
- Secure Firebase Authentication
- Auto session handling

### 🎯 Daily Goals
- Create **one active goal per day**
- Categorize goals (Fitness, Study, Mindfulness, etc.)
- Add description & optional image
- Automatic goal completion & streak tracking

### 📈 Progress Tracking
- Daily streak calculation
- Completed goals history
- Skill/category-based progress tracking
- Achievement unlocking logic

### 👥 Community
- Follow / Unfollow users
- Followers & Following lists
- View other users’ profiles
- View user posts & activity

### 📝 Posts
- Create posts with text & images
- Like posts
- View feed in real-time
- Posts linked to user profiles

### 🧑 Profile Management
- Edit profile (name, username, photo)
- Add bio
- Add interests
- Profile preview for other users

### ⚙️ Settings
- Notifications (UI-based)
- Security screen
- Privacy Policy
- About App
- Logout (secure session handling)



## 🛠 Tech Stack

### Frontend
- **Flutter (Dart)**
- Material UI
- Responsive layouts

### Backend & Services
- **Firebase Authentication**
- **Cloud Firestore**
- **Firebase Storage**
- **Cloudinary** (for image uploads)

### Architecture
- Repository pattern
- Clean separation of UI, data & logic
- Stream-based real-time updates



## 🔐 Firestore Rules (Highlights)

- Users can read/write only their own data
- Posts editable only by owner
- Followers/Following secured per user
- Notification settings protected by userId



## 📱 Installation (APK)

### Build APK
```bash
flutter build apk --release
```
### APK Path
```
build/app/outputs/flutter-apk/app-release.apk
