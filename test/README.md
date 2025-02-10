# Testing Structure

## Widget Tests (/test/widgets)
- Test widget rendering
- Test widget interactions
- Test widget state management
- Current widget tests:
	- CurrentWeatherWidget
	- CurvedLineChartWidget
	- WeatherCard
	- WeatherInfoRow

## Unit Tests
The unit tests are organized by layer:

### Services Tests (/test/services)
- Test API calls
- Test data transformation
- Test external service interactions

### Repository Tests (/test/repositories)
- Test data access logic
- Test caching mechanisms
- Test data persistence

### Provider Tests (/test/providers)
- Test state management
- Test data flow
- Test UI updates

## How to Run Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/path/to/test_file.dart
```

## Test Coverage
To generate test coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Best Practices
- Each test file should focus on a single component
- Use meaningful test descriptions
- Follow the Arrange-Act-Assert pattern
- Mock external dependencies
- Keep tests independent and isolated