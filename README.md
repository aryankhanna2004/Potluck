# Potluck - Simplify Group Meal Planning with Dietary Preferences

Potluck is an iOS application that streamlines the organization of group meals by managing event details, tracking dietary preferences, and ensuring safe dining experiences for all participants. The app provides a user-friendly platform for creating and managing potluck events while anonymously handling dietary restrictions and allergies.

The application is built using SwiftUI and Firebase, featuring real-time updates, deep linking capabilities, and comprehensive event management. Key features include user authentication via Firebase and Google Sign-In, profile management for dietary preferences and allergies, event creation and editing, and seamless sharing of event details through deep links.

## Repository Structure
```
Potluck/                      # Root directory
├── Assets.xcassets/          # Asset catalog containing app icons and images
├── Models/                   # Data models
│   └── PotluckEvent.swift   # Core data models for events, dishes, and user profiles
├── ViewModels/              # MVVM architecture view models
│   ├── AuthViewModel.swift  # Authentication logic
│   ├── DeepLinkManager.swift # Deep linking functionality
│   └── EventViewModels.swift # Event management logic
├── Views/                   # SwiftUI views
│   ├── HomeView.swift      # Main event listing view
│   ├── LoginView.swift     # Authentication views
│   └── ProfileSetupView.swift # User profile setup
└── PotluckApp.swift        # Application entry point and configuration
```

## Usage Instructions
### Prerequisites
- Xcode 14.0 or later
- iOS 16.0 or later
- CocoaPods package manager
- Firebase account and configuration
- Google Sign-In configuration

### Installation
1. Clone the repository:
```bash
git clone <repository-url>
cd Potluck
```

2. Install dependencies using CocoaPods:
```bash
pod install
```

3. Open the workspace:
```bash
open Potluck.xcworkspace
```

4. Configure Firebase:
- Add your `GoogleService-Info.plist` to the project
- Update Firebase configuration in `AppDelegate`

### Quick Start
1. Launch the app and sign in using Google Sign-In or email/password
2. Complete the profile setup with dietary preferences and allergies
3. Create a new event:
```swift
// Navigate to New Event view
Button("Create Event") {
    // Fill in event details
    viewModel.name = "Summer BBQ"
    viewModel.theme = "Outdoor Grilling"
    viewModel.address = "123 Park Ave"
    viewModel.createEvent()
}
```

### More Detailed Examples
1. Creating and sharing an event:
```swift
// Create new event
let event = PotluckEvent(
    name: "Weekend Brunch",
    theme: "Breakfast Foods",
    location: "Community Center",
    dateTime: Date()
)

// Share event via deep link
let deepLink = "potluck://event/\(event.id)"
```

2. Updating profile preferences:
```swift
// Update dietary preferences
ProfileViewModel().updateProfile(
    firstName: "John",
    lastName: "Doe",
    dietaryPreference: "Vegetarian",
    allergies: ["Nuts", "Dairy"]
)
```

### Troubleshooting
1. Authentication Issues
- Error: "Sign in failed"
  - Verify Firebase configuration
  - Check internet connectivity
  - Ensure Google Sign-In is properly configured

2. Deep Link Handling
- Error: "Invalid deep link format"
  - Verify URL scheme is registered
  - Check deep link format matches: `potluck://event/<eventID>`

3. Profile Updates
- Error: "Failed to save profile"
  - Verify Firestore rules
  - Check user authentication status
  - Ensure required fields are not empty

## Data Flow
The application follows a unidirectional data flow pattern where user actions trigger view model updates, which then persist changes to Firebase and update the UI accordingly.

```ascii
User Action → ViewModel → Firebase/Firestore → ViewModel → View
     ↑                                                    |
     └────────────────── State Update ──────────────────-┘
```

Key component interactions:
1. Authentication flow handles user sign-in and profile creation
2. Events are created and stored in Firestore with real-time updates
3. Deep links enable sharing events with other users
4. Profile changes are immediately reflected across the application
5. Event updates trigger real-time notifications to attendees
6. Dietary preferences are anonymously shared with event hosts
7. User data is securely stored and managed through Firebase