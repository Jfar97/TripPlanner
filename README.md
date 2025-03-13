# Trip Planner 
Trip Planner is an IOS app designed to give users both comprehensive and easy-to-use planning capabilities for various trips they may take. It allows users to select dates and a main location for the trip, which is saved as one of many trips a user can have. Within a trip there are six subtypes of items that can be added: accommodations, activities, dining locations, events, points of interest, and transportation. Users can either add them to the subtype tab of the trip manually, or can use the search option to search around the location of the trip and add items found on the map as one of the subtypes. Any locations attached to the trip or a subitem of a trip can have the details of the location viewed as well as a street view, which can be clicked for a navigable street view functionality to look around the actual location.

[![Static Badge](https://img.shields.io/badge/SwiftUI-blue?style=flat&logo=Swift&logoColor=blue&logoSize=large&labelColor=black)](#) [![Static Badge](https://img.shields.io/badge/SwiftData-silver?style=flat&logo=Swift&logoColor=silver&logoSize=large&labelColor=black)](#) [![Static Badge](https://img.shields.io/badge/API%20Integration-%23ff3300?style=flat)](#)


File directories can be found inside of Trip_Planner\Trip_Planner_2.0\Trip_Planner_2.0


# Technical Skills Implemented:

## Core iOS Development

- **SwiftUI** - Built the entire UI with SwiftUI, including custom animations, transitions, and responsive layouts that adapt to different device sizes
- **SwiftData** - Implemented Apple's newest persistence framework with complex relationship models between Trip entities and six different sub-types
- **MVVM Architecture** - Structured the app with a clear separation between View, Model, and ViewModel layers, with the TripPlannerViewModel acting as the central coordinator

## API & Data Management

- **RESTful API Integration** - Connected to Google Maps & Street View APIs with proper error handling and response parsing
- **CRUD Operations** - Implemented complete Create, Read, Update, Delete functionality for all entity types with proper relationship management
- **JSON Parsing** - Used Swift's Codable protocol to efficiently parse API responses from Street View metadata services
- **Asynchronous Programming** - Leveraged modern async/await syntax for network calls and geocoding services to maintain UI responsiveness

## Location Services

- **MapKit Integration** - Built custom map interfaces with search functionality, annotations, and detailed location previews
- **Geocoding/Reverse Geocoding** - Converted between addresses and coordinates using CLGeocoder for both search and location display
- **Interactive Maps** - Created user-friendly map controls with custom zoom buttons and tap-to-select functionality

## Advanced Swift Features

- **Property Wrappers** - Extensively used @State, @Binding, @Environment, and @ObservedObject for state management across the app
- **Concurrency** - Implemented Task cancellation for search operations and MainActor for UI updates to prevent threading issues
- **Generic Programming** - Built type-safe views like the `listView(for:title:addAction:)` function that handles different entity types with a single implementation
- **Protocol-Oriented Design** - Used protocols like `Identifiable` and `Hashable` to enable consistent handling of different entity types

## UI/UX Implementation

- **Custom Component Design** - Created reusable components like CustomTabBar and TabBarButton with consistent styling across the app
- **Responsive Layouts** - Built adaptive UI elements using GeometryReader and relative sizing for compatibility across iPhone models
- **Navigation Patterns** - Implemented complex navigation flows with NavigationStack and custom back buttons for intuitive user journeys
- **Form Validation** - Built robust validation logic in all form views with the `isFormValid` computed property to prevent invalid data entry

## Software Engineering Practices

- **Modular & Reusable Code** - Created highly reusable UI patterns like the `detailView(for:)` function that dynamically returns the appropriate view for any entity type
- **Debugging & Logging** - Implemented strategic debug logs (e.g., "DEBUG: LocationDetailView appeared") throughout view lifecycle events to track navigation flow and data passing
- **Clean Code Organization** - Used consistent MARK comments to segment functionality in larger files and maintained naming conventions across the entire codebase

## Web Technologies

- **WebKit Integration** - Embedded WKWebView for interactive Street View panoramas with custom HTML content
- **HTML/JavaScript** - Generated dynamic HTML with embedded JavaScript to create custom Street View experiences
- **URL Components** - Built complex URL structures with query parameters for API requests with proper URL encoding



