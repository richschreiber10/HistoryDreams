# HistoryDreams Architecture

## Directory Structure

```
HistoryDreams/
├── App/
│   └── HistoryDreamsApp.swift
├── Features/
│   ├── Home/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Library/
│   │   ├── Views/
│   │   └── ViewModels/
│   ├── Timer/
│   │   ├── Views/
│   │   └── ViewModels/
│   └── Settings/
│       ├── Views/
│       └── ViewModels/
├── Core/
│   ├── Audio/
│   │   ├── AudioManager.swift
│   │   ├── PlaybackController.swift
│   │   └── AudioSession.swift
│   └── Storage/
│       ├── StorageManager.swift
│       └── CacheManager.swift
├── Models/
│   ├── Story.swift
│   ├── PlaybackState.swift
│   └── UserPreferences.swift
├── Services/
│   ├── AudioService.swift
│   ├── StorageService.swift
│   └── AnalyticsService.swift
├── Components/
│   ├── PlayerControls/
│   ├── StoryList/
│   └── TimerControls/
└── Utils/
    ├── Extensions/
    └── Helpers/
```

## Architecture Overview

HistoryDreams follows the MVVM (Model-View-ViewModel) architecture pattern with SwiftUI, incorporating the following principles:

1. **Feature-First Organization**
   - Each major feature has its own directory
   - Features contain their own views and view models
   - Shared components are extracted to the Components directory

2. **Core Services**
   - Audio system is centralized in Core/Audio
   - Storage handling is managed in Core/Storage
   - Services are accessed through dependency injection

3. **State Management**
   - Using SwiftUI's @StateObject and @EnvironmentObject
   - Central state managers for audio and user preferences
   - Local view state handled by view models

4. **Data Flow**
   - Unidirectional data flow
   - State updates through publishers
   - Clear separation between UI and business logic

## Key Components

### Audio System
- AudioManager: Central audio playback controller
- PlaybackController: Handles playback state and controls
- AudioSession: Manages system audio session

### Storage System
- StorageManager: Handles persistent storage
- CacheManager: Manages temporary storage and caching

### UI Components
- PlayerControls: Reusable audio player interface
- StoryList: Standardized story listing component
- TimerControls: Sleep timer interface

## Dependencies

- SwiftUI for UI
- AVFoundation for audio playback
- UserDefaults for basic storage
- (Future) CoreData for complex data storage 