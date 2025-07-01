# SpaceX iOS App

An iOS application built with clean architecture and modern SwiftUI, demonstrating advanced development patterns by consuming the SpaceX API to display SpaceX launches data (with pagination, caching, sorting and filtering), and company information.

## 🏛️ Architecture Overview

### Clean Architecture with Modular Design
- **7 distinct Swift packages** implementing separation of concerns
- **MVVM pattern** with SwiftUI and `@Observable` framework (iOS 17+)
- **Repository pattern** for data abstraction layer
- **Coordinator pattern** for navigation management
- **Dependency injection** Increasing modularity, flexibility and testability

### Package Structure
```
├── SpaceXDomain/          # Business logic and domain models
├── SpaceXData/            # Data layer with repositories and caching with Swift Data
├── SpaceXNetwork/         # Network layer with security features
├── SpaceXProtocols/       # Protocol definitions for loose coupling
├── SpaceXUtilities/       # Shared utilities and logging
├── SpaceXSharedUI/        # Reusable UI components
├── SpaceXMocks/           # Comprehensive mock data factory
└── SpaceX/                # Main iOS app target
```

## 🎯 Core Features & Technical Implementation

### Network Layer & Security
- **SSL Certificate Pinning**: Certificate validation with trust evaluation
- **Network Monitoring**: Real-time connectivity detection with NWPathMonitor
- **Retry Logic**: Automatic retry on failure with configurable intervals
- **Environment Configuration**: Development/Production security profiles
- **Custom URLSession**: Timeout configuration and security headers

### Data Management & Caching
- **Multi-layer Caching Strategy**:
- SwiftData for persistent storage
- UserDefaults for preferences and cache metadata
- Kingfisher for optimized image caching (50MB memory, 100MB disk)
- **Smart Cache Invalidation**: 5 minute expiration with sort-specific timestamps
- **Memory Management**: Automatic pagination trimming (500 item limit)
- **Offline-First Design**: Fallback to cached data when network is unavailable
  
### Advanced UI Patterns
- **SwiftUI + UIKit Integration**: WebView with navigation controls (back/forward)
- **@Observable Framework**: Modern state management with selective property observation
- **@ObservationIgnored**: Performance optimization for non-UI properties
- **Coordinator Pattern**: Centralized navigation with deep linking support
- **Dark Mode Support**: System-integrated appearance switching
- **Pull-to-Refresh**: Native iOS refresh patterns

### Pagination & Performance
- **Infinite Scrolling**: Load-more with visual indicators
- **Server-side Filtering**: Multiple filter combinations (year ranges, success status)
- **Server-side Sorting**: Multiple sort orders (A-Z, Z-A, newest first, oldest first)
- **Pagination State Management**: Current page, total pages, hasMore logic
- **Image Optimization**: Downsampling, retry logic, and error handling

## 🔧 Advanced Technical Features

### Filtering & Search
```swift
// Complex query building for server-side filtering
private func buildQuery(
    filter: LaunchFilter,
    sortOption: LaunchSortOption,
    page: Int,
    pageSize: Int
) -> LaunchQuery {
    // Supports combined filters: year + success status
    // Uses OR clauses for multiple years
    // Optimized for server-side processing
}
```

### Image Caching with Kingfisher
```swift
// Advanced image caching configuration
KFImage(url)
    .setProcessor(DownsamplingImageProcessor(size: size))
    .retry(maxCount: 2, interval: .seconds(1.0))
    .scaleFactor(UIScreen.main.scale)
    .onFailure { error in
        // Specific error handling for different failure types
    }
```

### Certificate Pinning Implementation
```swift
public final class CertificatePinner: Sendable {
    // Certificate validation
    // Chain validation support
    // Environment-specific configurations
}
```

### Network Monitoring
```swift
@Observable
public final class NetworkMonitor {
    // Real-time connectivity monitoring
    // Connection type detection (WiFi, Cellular, Ethernet)
    // Expensive connection awareness
}
```

## ✅ Testing Strategy

### Unit Testing
- **ViewModel Testing**: Comprehensive async/await testing patterns
- **Repository Testing**: Mock-based testing with error scenarios
- **State Management Testing**: Loading states, pagination, filtering
- **Error Handling Testing**: Network failures, cache misses, recovery

### UI Testing
- **Critical User Journeys**: Launch viewing, filtering, detail navigation
- **Functional Testing**: Navigation, scrolling, and interaction validation
- **Mock Data Integration**: UI tests with controlled data scenarios

### Mock Data Factory
```swift
public struct MockRepositoriesFactory {
    // Multiple configurations: default, withErrors, fast, instant
    // Realistic test data generation
    // Delay simulation for loading states
    // Error injection for failure testing
}
```

### Localization Implementation
- **Multi-language Support**: English and German translations
- **Native String Catalogs**: Uses `.xcstrings` format with extraction states
- **Dynamic Value Handling**: String interpolation for dates, counts, and IDs
- **Context-aware Translations**: Domain-specific terminology across modules

## 🛠️ Development Tools & Utilities

### Logging System
```swift
SpaceXLogger.network("🌐 API Request: \(endpoint)")
SpaceXLogger.cacheOperation("💾 Cache hit for \(key)")
SpaceXLogger.error("❌ Network error: \(error)")
```

### Error Handling
- **Typed Error System**: Domain-specific error types
- **Error Mapping**: Network to domain error translation
- **User-Friendly Messages**: Localized error descriptions
- **Recovery Mechanisms**: Automatic fallback to cached data

## 📱 UI Components & Patterns

### SwiftUI + UIKit Bridge
```swift
// WebView integration with SwiftUI
struct LaunchDetailWebViewRepresentable: UIViewControllerRepresentable {
    // Bidirectional communication
    // Navigation state management
    // Progress indication
}
```

## 🔧 Build Configuration

### Modern iOS Development
- **iOS 17.0+ Target**: Leveraging latest iOS capabilities
- **Swift 6.0**: Latest language features and concurrency model
- **SwiftData**: Modern Core Data replacement
- **Combine + async/await**: Hybrid reactive/async programming
