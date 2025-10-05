# Photo GPS Editor (English)

## 📖 Project Overview

**App Name:** Photo GPS Editor
**Goal:** Help users easily search, filter, and edit GPS information in their saved photos
**Target Users:** General users and photographers who want to manage photo location data

## 🛠️ Tech Stack & Tools

- **Language:** Dart (Flutter framework)
- **Recommended IDE:** Visual Studio Code, Android Studio
- **Image Processing:** flutter_exif_plugin, image
- **Map API:** google_maps_flutter (Android/iOS), Apple Maps
- **File Access:** file_picker, image_picker
- **Permissions:** Android/iOS file and location permissions

## 🚀 Main Features

- **Image File Scan & Collection:**
  - Automatically scan device/gallery for photos
  - Filter by directory or date
  - Extract Exif metadata (including GPS)
- **GPS Edit & Save:**
  - Edit location using map view
  - Save new coordinates to Exif
  - Show photo thumbnail with GPS info
- **Batch GPS Edit**
- **Data Backup & Restore**
- **User Customization:** Favorites, history, etc.
- **UI/UX:**
  - Home: scan/filter/recent edit buttons
  - Gallery-style photo list with GPS info
  - Detail/edit screen: preview, Exif, GPS edit
  - Map screen: marker, select/save new location, zoom, map type
- **Security:**
  - Exif backup before edit
  - User consent for GPS/photo access
  - Optional data encryption/cloud sync

## 🌐 Language Selection

- [View in Korean](README.ko.md)
- [View in English](README.en.md)
