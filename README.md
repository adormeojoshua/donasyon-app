# DonasyON: Bayanihan in one tap!

A Philippine-based mobile donation app built with SwiftUI and Firebase. DonasyON connects donors with people and organizations who need financial help, and uses points, ranks, and rewards to encourage consistent giving. Built as a final project for CSSE105.

## Features

- **Authentication**: sign up and log in with Firebase Authentication, with real-time email and username validation to prevent duplicate accounts
- **Home feed**: fundraising campaigns stored in Cloud Firestore, with category filters (Health, Clothes, Study, Food) and live search
- **Donation flow**: preset or custom amounts, GCash or card selection, a confirmation prompt, validation that prevents over-donating past a campaign's goal, and a receipt with a transaction ID
- **Dual-point system**: Rank Points for donor status (Bronze to Platinum) and Spending Points for redeeming rewards
- **Leaderboard**: a podium for the top three donors, with weekly and all-time views
- **Rewards**: redeem points for items such as e-load and food vouchers, with a unique voucher code saved to the user's history
- **Digital wallet**: card-style balance view and a transaction history log
- **Campaign creation**: verified users can publish their own campaigns with a cover photo, category, and target amount, and can delete only their own campaigns
- **Identity verification flow**: ID upload and selfie steps with Unverified, Pending, and Verified statuses

## Tech stack

- **UI**: SwiftUI, with a custom bottom navigation bar and podium layout
- **Architecture**: MVVM (ViewModels for auth, charities, leaderboard, rewards, and user profile)
- **Backend**: Firebase Authentication and Cloud Firestore
- **Design**: Figma

## Project structure

| Folder | Contents |
|---|---|
| `DonasyONApp/App` | App entry point |
| `DonasyONApp/ViewModels` | Business logic and Firestore access |
| `DonasyONApp/DataModels` | Data models |
| `DonasyONApp/Views` | Screens: Onboarding and Auth, Main, Donation, Leaderboards, Rewards, Wallet, Profile |
| `DonasyONApp/Components` | Reusable UI components |

## Running the app

1. Open `DonasyONApp.xcodeproj` in Xcode (macOS required).
2. Create your own Firebase project with **Authentication** and **Cloud Firestore** enabled.
3. Add an iOS app to the project in the Firebase console, download its `GoogleService-Info.plist`, and place it in `DonasyONApp/App/`. The file is not included in this repository.
4. Build and run on a simulator or device.

## Known limitations

- Payments are **simulated**. The app is not connected to a live payment gateway, and no real money moves.
- Identity verification is simulated or manually toggled in the database. It does not use a third-party KYC provider.
- Images are stored as Base64 text in Firestore. A production version would move them to Firebase Storage.

## What I learned

Applying MVVM to keep logic out of the views, integrating Firebase for a backend-less architecture, building complex custom UIs in SwiftUI, and solving state and navigation issues such as stable item IDs and a shared tab bar manager.

## Author

Joshua Aeron J. Adormeo, Manuel S. Enverga University Foundation