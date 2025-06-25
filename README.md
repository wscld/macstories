# MacStories Video Recorder

A Swift learning project that demonstrates building a modern macOS video recording application using SwiftUI and AVFoundation.

## 📋 Project Overview

This project is designed as a hands-on learning experience for Swift development on macOS. It implements a sleek, translucent video recording app that captures video and audio from connected devices.

### 🎯 Learning Objectives

This project covers essential Swift and macOS development concepts:

- **SwiftUI Framework**: Modern declarative UI development
- **AVFoundation**: Media capture and processing
- **macOS App Development**: Native macOS application structure
- **State Management**: Using `@StateObject`, `@Published`, and `@ObservableObject`
- **Permissions Handling**: Camera and microphone access requests
- **Custom UI Components**: Translucent backgrounds and custom views
- **Window Management**: Custom window styling and behavior
- **Audio Visualization**: Real-time audio level monitoring

## 🏗️ Architecture

### Core Components

#### **MacStoriesApp.swift**
- Main app entry point using `@main` attribute
- Custom `AppDelegate` for window management
- Shared app state using `ObservableObject`
- Translucent background implementation with `NSVisualEffectView`

#### **VideoRecorder.swift** 
- Core recording functionality using `AVCaptureSession`
- Device discovery and management (cameras/microphones)
- Permission handling for camera and microphone access
- Real-time audio level monitoring
- Recording state management

#### **Views/**
- **ContentView.swift**: Main interface with video preview
- **PermissionsView.swift**: Elegant permission request flow
- **AudioWaveView.swift**: Visual audio level representation
- **AboutView.swift**: Application information
- **IntroView.swift**: App introduction flow

#### **Controllers/**
- Window controllers for modular UI management
- Separation of concerns for different app windows

## 🚀 Features Implemented

### ✅ Core Functionality
- [x] Video recording with selectable cameras
- [x] Audio recording with device selection
- [x] Real-time preview with mirroring
- [x] Permission request workflow
- [x] Device discovery and switching
- [x] Recording duration controls
- [x] Audio level visualization

### ✅ UI/UX Features
- [x] Translucent, modern interface
- [x] Fixed window size (340x730)
- [x] Custom title bar styling
- [x] Smooth animations and transitions
- [x] Device picker interface
- [x] Recording controls

### ✅ macOS Integration
- [x] Native permission dialogs
- [x] System menu integration
- [x] Keyboard shortcuts
- [x] Window management

## 🛠️ Technical Concepts Demonstrated

### 1. **SwiftUI State Management**
```swift
@StateObject private var recorder = VideoRecorder()
@Published var isRecording = false
@EnvironmentObject private var appState: AppState
```

### 2. **AVFoundation Integration**
```swift
private var captureSession: AVCaptureSession?
private var movieOutput: AVCaptureMovieFileOutput?
let preview = AVCaptureVideoPreviewLayer(session: session)
```

### 3. **Permission Handling**
```swift
switch AVCaptureDevice.authorizationStatus(for: .video) {
case .authorized: // Handle authorized state
case .notDetermined: // Request permission
case .denied, .restricted: // Handle denied state
}
```

### 4. **Custom NSViewRepresentable**
```swift
struct TranslucentBackgroundView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .dark
        view.blendingMode = .behindWindow
        return view
    }
}
```

## 📚 Swift Concepts Covered

### **Language Features**
- Classes and Structs
- Protocols and Extensions
- Optionals and Error Handling
- Closures and Completion Handlers
- Property Wrappers (`@Published`, `@StateObject`, etc.)

### **Frameworks & APIs**
- **SwiftUI**: Views, Modifiers, State Management
- **AVFoundation**: Capture Sessions, Device Management
- **Foundation**: Timers, Notifications, Data Types
- **AppKit**: Window Management, Visual Effects

### **Design Patterns**
- MVVM (Model-View-ViewModel)
- Observer Pattern with Combine
- Delegation Pattern
- Singleton Pattern (for window controllers)

## 🔧 Development Environment

- **Language**: Swift 5.x
- **Framework**: SwiftUI
- **Platform**: macOS 11.0+
- **IDE**: Xcode 12.0+

## 📖 Learning Path Suggestions

### **Beginner Focus Areas**
1. Study `ContentView.swift` for SwiftUI basics
2. Examine state management in `VideoRecorder.swift`
3. Understand permission flow in `PermissionsView.swift`

### **Intermediate Topics**
1. Custom UI components and animations
2. AVFoundation session management
3. Window styling and AppDelegate integration

### **Advanced Concepts**
1. Performance optimization for video capture
2. Custom visual effects and graphics
3. Audio processing and visualization

## 🎨 UI Design Elements

- **Translucent Design**: Modern glass-morphism effect
- **Fixed Dimensions**: iPhone-like aspect ratio (340x730)
- **Dark Theme**: Optimized for video content
- **Smooth Animations**: Bouncy transitions and scaling effects
- **Native Controls**: macOS-style buttons and interfaces

## 🔒 Privacy & Permissions

The app demonstrates proper handling of sensitive permissions:
- Camera access for video recording
- Microphone access for audio capture
- Graceful error handling for denied permissions
- User-friendly permission request flow

## 🚧 Potential Enhancements for Further Learning

- [ ] Add video filters and effects
- [ ] Implement video editing capabilities
- [ ] Add export format options
- [ ] Create settings persistence
- [ ] Add recording quality selection
- [ ] Implement batch recording features
- [ ] Add cloud storage integration

## 📝 Notes for Learners

This project serves as an excellent foundation for understanding:
- How modern macOS apps are structured
- Integration between Swift UI and system frameworks
- Real-world permission and device handling
- Professional UI/UX design patterns in Swift

The codebase is well-organized and includes proper separation of concerns, making it easy to understand and extend as you continue your Swift learning journey.

---

**Created**: March 25, 2025  
**Purpose**: Swift Learning Project  
**Platform**: macOS  
**Framework**: SwiftUI + AVFoundation
