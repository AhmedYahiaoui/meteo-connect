import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:meteo_connect/core/constants/assets.dart';
import 'package:meteo_connect/core/constants/colors.dart';
import 'package:meteo_connect/core/themes/app_theme.dart';
import 'package:meteo_connect/core/utils/tools.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/data/models/weather/weather_model.dart';
import 'package:meteo_connect/features/city_details/city_details_viewmodel.dart';
import 'package:meteo_connect/features/city_details/widgets/current_weather_widget.dart';
import 'package:meteo_connect/features/home/home_viewmodel.dart';
import 'package:meteo_connect/features/providers/theme_provider.dart';
import 'package:meteo_connect/services/connectivity_service.dart';
import 'package:meteo_connect/widgets/confirmation_bottom_sheet.dart';
import 'package:meteo_connect/widgets/loading_view.dart';
import 'package:timezone/timezone.dart' as tz;

class CityDetailsScreen extends ConsumerStatefulWidget {
  final CityModel city;

  const CityDetailsScreen({
    super.key,
    required this.city,
  });

  @override
  ConsumerState<CityDetailsScreen> createState() => _CityDetailsScreenState();
}

class _CityDetailsScreenState extends ConsumerState<CityDetailsScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  WeatherModel? _selectedWeather;

  // Store the selected hour index
  int selectedHourIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load the weather data after the widget is built
    _load();
  }

  void _load() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel =
          ref.read(cityDetailsViewModelProvider(widget.city).notifier);
      _selectedWeather = viewModel.currentWeather;

      // Get current hour in the city's timezone

      final location =
          tz.getLocation(_selectedWeather?.timezone ?? "Europe/Paris");
      final now = tz.TZDateTime.now(location).hour;

      // Update the selected hour
      setState(() {
        // Adjust the index to account for 1 AM start
        selectedHourIndex = now - 1;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final city = widget.city;
    final cityDetailsState = ref.watch(cityDetailsViewModelProvider(city));
    final viewModel =
        ref.read(cityDetailsViewModelProvider(widget.city).notifier);

    final isDarkMode = ref.watch(themeProvider);
    return Theme(
      data: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        body: SafeArea(
          child: CustomMaterialIndicator(
            onRefresh: () async {
              final isConnected = await _connectivityService.isConnected();
              if (isConnected) {
                viewModel.refreshWeather();
              }
            },
            indicatorBuilder: (context, controller) {
              return Lottie.asset(
                AppAssets.loader,
              );
            },
            child: cityDetailsState.when(
              data: (state) => _buildContent(context, ref),
              loading: () => const LoadingView(),
              error: (error, _) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    final viewModel =
        ref.read(cityDetailsViewModelProvider(widget.city).notifier);

    final selectedWeather = viewModel.selectedHourlyWeather;

    final currentWeather = viewModel.currentWeather;
    if (currentWeather == null) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _popArrowWidget(),
            if (viewModel.currentWeather != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 15,
                  right: 15,
                  bottom: 10,
                ),
                child: CurrentWeatherWidget(
                  city: widget.city,
                  weather: currentWeather,
                  selectedHourlyWeather:
                      selectedWeather ?? currentWeather.hourly.last,
                  useFahrenheit: viewModel.user?.useFahrenheit ?? false,
                  isDarkMode: viewModel.user?.useDarkMode ?? false,
                ),
              ),
            // Title for today's forecast
            _weatherTitlesHeaders('Today'),

            const SizedBox(height: 10),
            // Hourly Forecast
            _weatherHourWidget(ref),
            const SizedBox(height: 10),
            // Daily Forecast
            _weatherTitlesHeaders('Next 7 days'),
            _weatherDailyWidget(ref),
            const SizedBox(height: 10),
            _deleteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _popArrowWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: const RotatedBox(
          quarterTurns: 2,
          child: Icon(
            Icons.arrow_right_alt_rounded,
            size: 35,
          ),
        ),
      ),
    );
  }

  Widget _weatherTitlesHeaders(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _weatherHourWidget(WidgetRef ref) {
    final viewModel =
        ref.read(cityDetailsViewModelProvider(widget.city).notifier);

    final currentWeather = viewModel.currentWeather;
    final selectedWeather = viewModel.selectedHourlyWeather;
    final useFahrenheit = viewModel.user?.useFahrenheit ?? false;

    if (currentWeather == null || selectedWeather == null) {
      return const SizedBox.shrink();
    }

    final location = tz.getLocation(currentWeather.timezone);
    final now = tz.TZDateTime.now(location);

    // Get sunrise and sunset times
    final sunrise = tz.TZDateTime.fromMillisecondsSinceEpoch(
        location, currentWeather.current.sunrise * 1000);
    final sunset = tz.TZDateTime.fromMillisecondsSinceEpoch(
        location, currentWeather.current.sunset * 1000);

    // Create list of 24 hours starting from current hour
    final List<tz.TZDateTime> hours = [];

    for (int i = 0; i < 24; i++) {
      final hour = now.add(Duration(hours: i));
      hours.add(hour);
    }

    // Use a ListView to display all hours for the specific day
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        itemBuilder: (context, index) {
          final hour = hours[index];
          final hourlyWeather = currentWeather.hourly[index];
          final isSelected = hourlyWeather == viewModel.selectedHourlyWeather;

          // Special cases
          final isNow = index == 0;
          final isSunrise = hour.hour == sunrise.hour;
          final isSunset = hour.hour == sunset.hour;

          return GestureDetector(
            onTap: () {
              viewModel.selectHourlyWeather(hourlyWeather);
            },
            child: Container(
              margin: EdgeInsets.only(left: isSelected ? 12 : 8, right: 8),
              padding: const EdgeInsets.only(
                top: 10,
                bottom: 10,
                left: 18,
                right: 18,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.getBackgroundColor(
                        currentWeather.current.weather.main, context)
                    : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isNow ? 'Now' : formatHourString(hour.hour),
                    style: TextStyle(fontSize: isSelected ? 13 : 12),
                  ),
                  if (isSunrise || isSunset)
                    Icon(
                      Icons.wb_sunny,
                      size: isSelected ? 42 : 40,
                      color: isSunrise
                          ? AppColors.sunriseColor
                          : AppColors.sunsetColor,
                    )
                  else
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Lottie.asset(
                        AppAssets.getWeatherAnimation(
                          hourlyWeather.weather.first.main,
                          hour,
                          sunrise: sunrise,
                          sunset: sunset,
                        ),
                        fit: BoxFit.fill,
                      ),
                    ),
                  if (isSunrise)
                    const Text('Sunrise')
                  else if (isSunset)
                    const Text('Sunset')
                  else
                    Text(
                      '${formatTemperature(
                        hourlyWeather.temp,
                        useFahrenheit,
                        decimalPlaces: 0,
                      )}°',
                      style: TextStyle(
                        fontSize: isSelected ? 17 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _weatherDailyWidget(WidgetRef ref) {
    final viewModel =
        ref.read(cityDetailsViewModelProvider(widget.city).notifier);

    final currentWeather = viewModel.currentWeather;
    final useFahrenheit = viewModel.user?.useFahrenheit ?? false;
    if (currentWeather == null) return const SizedBox.shrink();

    final location = tz.getLocation(currentWeather.timezone);
    final tz.TZDateTime now = tz.TZDateTime.now(location);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: currentWeather.daily.length,
      itemBuilder: (context, index) {
        final dailyWeather = currentWeather.daily[index];

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(left: 10, right: 10),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getDayFromTimezone(
                        dailyWeather.dt.toString(),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      getFormattedDate(
                        dailyWeather.dt.toString(),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${formatTemperature(
                  dailyWeather.tempDay,
                  useFahrenheit,
                  decimalPlaces: 0,
                )}°',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                width: 50,
                height: 50,
                child: Lottie.asset(
                  AppAssets.getWeatherAnimation(
                    dailyWeather.weather.first.main,
                    now,
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _deleteButton(BuildContext context) {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    return GestureDetector(
      // onTap: () => homeViewModel.removeCity(widget.city.name),
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => ConfirmationBottomSheet(
            title: 'Remove City',
            message: 'Are you sure you want to remove ${widget.city.name}?',
            confirmLabel: 'Remove',
            onConfirm: () async {
              // Clear default city if it was the deleted one
              homeViewModel.removeCity(widget.city.name);
              if (!context.mounted) return;
              Navigator.pop(context); // Go back to home
            },
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(12),
          ),
          color: AppColors.error,
        ),
        child: const Text(
          'Delete this City',
          style: TextStyle(
            color: AppColors.background,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
