# meteo_connect

A new Flutter project.

### Key Architectural Components:

1. **Repository Pattern**

   - WeatherRepository acts as a single source of truth
   - Handles data operations between API and local cache
   - Implements error handling and data validation

2. **Service Layer**

   - ApiService: Handles all external API communications
   - CachingService: Manages local data persistence
   - Clear separation between data sources

3. **Provider Pattern**
   - Implements state management using Riverpod
   - Separates business logic from UI

## State Management

The application uses Riverpod for state management, offering several advantages:

1. **StateNotifier Providers**

   - `weatherProvider`: Manages weather data state
   - Handles loading, error, and success states
   - Provides reactive updates to UI

2. **AsyncValue Pattern**

   - Utilizes Flutter Riverpod's AsyncValue for better state handling
   - Properly manages loading and error states
   - Type-safe state management

3. **Repository Integration**
   - Providers communicate with repositories
   - Ensures single source of truth
   - Manages data caching and fetching logic

## Features

1. **Weather Information**

   - Real-time weather data fetching
   - Detailed weather information display
   - Support for multiple locations

2. **Caching System**

   - Offline data access
   - Efficient data storage
   - Automatic cache invalidation

3. **Error Handling**

   - Robust error management
   - User-friendly error messages
   - Graceful fallback mechanisms

4. **Location Management**
   - City-based weather lookup
   - Location coordinates support
   - Multiple location tracking

## Technical Implementation Details

1. **Testing**

   - Comprehensive unit tests
   - Mock-based testing using Mockito
   - Repository and Provider level testing

2. **State Management Techniques**

   - Reactive programming with Riverpod
   - AsyncValue for better state handling
   - Proper state immutability

3. **Caching Strategy**

   - Intelligent cache invalidation
   - Offline-first approach
   - Efficient data storage

4. **Code Organization**
   - Clean Architecture principles
   - Feature-based organization
   - Clear separation of concerns

## Theme Management

The application supports both light and dark themes through the `AppTheme` class, which defines the theme data. The `ThemeService` class manages the current theme state and allows users to toggle between light and dark modes.

## Constants

The application defines several constants used throughout the codebase, including:

- **API Constants**: Base URLs and API keys for accessing weather data.
- **Application Constants**: Strings for error messages, app name, and screen titles.
- **Weather Labels**: Labels for displaying weather-related information.# City Repository
  The `CityRepository` manages the storage and retrieval of city data using Hive. It provides methods to get, save, and update cities, as well as to clear all city data.

## Getting Started

1. Clone the repository

```bash
git clone https://github.com/yourusername/meteo_connect.git
```

1. Run the project
   I have already create a folder .vscode, contains a json file helps you launch the app directly or :

```bash
flutter devices
```

get the id of the device wanted

```bash
flutter run -d [the device id]
```
