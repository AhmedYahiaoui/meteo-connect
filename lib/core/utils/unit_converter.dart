class UnitConverter {
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  static String formatTemperature(double temperature, bool useFahrenheit,
      {bool showMetrics = true}) {
    final displayTemp =
        useFahrenheit ? celsiusToFahrenheit(temperature) : temperature;
    if (showMetrics) {
      return '${displayTemp.round()}°${useFahrenheit ? 'F' : 'C'}';
    } else {
      return '${displayTemp.round()}°';
    }
  }
}
