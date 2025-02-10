# meteo_connect

A new Flutter project.

# Architecture
This application follows a modular architecture, separating concerns into different directories such as `lib`, `data`, `services`, and `features`. The use of Riverpod for state management allows for efficient and reactive UI updates.

# Theme Management
The application supports both light and dark themes through the `AppTheme` class, which defines the theme data. The `ThemeService` class manages the current theme state and allows users to toggle between light and dark modes.

# Constants
The application defines several constants used throughout the codebase, including:

- **API Constants**: Base URLs and API keys for accessing weather data.
- **Application Constants**: Strings for error messages, app name, and screen titles.
- **Weather Labels**: Labels for displaying weather-related information.# City Repository
The `CityRepository` manages the storage and retrieval of city data using Hive. It provides methods to get, save, and update cities, as well as to clear all city data.

# Weather Repository
The [WeatherRepository] handles the storage and retrieval of weather data. It utilizes the `ApiService` to fetch weather information and the `CachingService` to manage cached data. The repository provides methods to get weather data for a city, update weather data, and clear all weather data.