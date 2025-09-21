# 🔥 Firebase Setup Guide for Kanso

## Quick Setup Steps

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Project name: `kanso-app`
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Add iOS App
1. Click "Add app" → iOS
2. **Bundle ID**: `com.example.kanso`
3. **App nickname**: `Kanso iOS`
4. Click "Register app"
5. **Download** `GoogleService-Info.plist`
6. **Replace** the placeholder file at: `ios/Runner/GoogleService-Info.plist`

### 3. Add Android App
1. Click "Add app" → Android
2. **Package name**: `com.example.kanso`
3. **App nickname**: `Kanso Android`
4. Click "Register app"
5. **Download** `google-services.json`
6. **Replace** the placeholder file at: `android/app/google-services.json`

### 4. Enable Services
1. **Authentication** → Sign-in method → Enable "Email/Password"
2. **Firestore Database** → Create database → Start in test mode

### 5. Test Your Setup
```bash
flutter clean
flutter pub get
flutter run
```

## What You Get
- ✅ User authentication (sign up/sign in)
- ✅ Real-time database (Firestore)
- ✅ Data persistence across devices
- ✅ Offline support
- ✅ Scalable cloud storage

## Current Status
- 🔧 Firebase dependencies added
- 🔧 Configuration files created (placeholders)
- 🔧 Firebase service implemented
- ⏳ **You need to**: Replace placeholder config files with real ones from Firebase Console

## Troubleshooting
- If build fails: `flutter clean && flutter pub get`
- If Firebase errors: Check your config files are properly placed
- If auth fails: Verify Email/Password is enabled in Firebase Console

## Next Steps
1. Follow steps 1-4 above
2. Replace the placeholder config files
3. Run `flutter run`
4. Test sign up/sign in functionality
