# MediaShelf 📀

A mobile app to catalogue your physical media collections — CDs, DVDs, books, cassettes, and any custom collection types you create. Built with Flutter & Dart for Android.

Available on Google Play (internal testing).

---

## Features

**Collection**
- Browse your collection in a filterable grid
- Add items manually: title, creator, year, genre, and cover art
- Add cover art from your camera or photo gallery
- Filter by collection type using chips
- Edit and delete items
- Create custom collection types with custom emoji icons

**Stats**
- Item counts by collection type
- Top genres and decades
- Recently added items
- Filter stats by one or more collection types

**Account & Sync**
- Sign up and log in with email and password
- Collection syncs to the cloud via Firestore
- Data persists locally via SQLite for fast offline access
- Sign out and switch accounts

**Customization**
- Light and dark mode
- Manage and edit custom collection types

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Local Database | SQLite (sqflite) |
| Cloud Database | Firebase Firestore |
| Authentication | Firebase Auth |
| Image Picking | image_picker |

---
## Publishing

- Submitted to Google Play internal testing
- 13 installed testers
- Production access pending
