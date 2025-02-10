import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:meteo_connect/app.dart';
import 'package:meteo_connect/core/constants/assets.dart';
import 'package:meteo_connect/core/themes/app_theme.dart';
import 'package:meteo_connect/features/home/home_viewmodel.dart';
import 'package:meteo_connect/features/providers/theme_provider.dart';
import 'package:meteo_connect/services/connectivity_service.dart';

class BoardingScreen extends ConsumerStatefulWidget {
  const BoardingScreen({super.key});

  @override
  BoardingScreenState createState() => BoardingScreenState();
}

class BoardingScreenState extends ConsumerState<BoardingScreen> {
  @override
  void initState() {
    super.initState();
    _refreshWeather();
  }

  Future<void> _refreshWeather() async {
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.isConnected();

    Stopwatch stopwatch = Stopwatch()..start();
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    if (isConnected) {
      await homeViewModel.refreshWeather();
    }
    stopwatch.stop();
    int executionTime = stopwatch.elapsed.inSeconds;

    // After refreshing, navigate to the main app
    // if the executionTime is too small and less the 1 sec
    // then, a delay for 1 sec at least to see the full animation
    Future.delayed(Duration(seconds: executionTime >= 1 ? 0 : 1)).then((val) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const WeatherApp()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);

    return Theme(
      data: isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Center(
        child: Lottie.asset(
          AppAssets.loader,
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}
