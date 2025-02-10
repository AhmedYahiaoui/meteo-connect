// ignore_for_file: use_build_context_synchronously

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:meteo_connect/core/constants/assets.dart';
import 'package:meteo_connect/data/models/city/city_model.dart';
import 'package:meteo_connect/features/city_details/city_details_screen.dart';
import 'package:meteo_connect/features/home/home_viewmodel.dart';
import 'package:meteo_connect/features/home/widgets/add_city_bottom_sheet.dart';
import 'package:meteo_connect/features/home/widgets/connectivity_widget.dart';
import 'package:meteo_connect/features/home/widgets/weather_card.dart';
import 'package:meteo_connect/services/connectivity_service.dart';
import 'package:meteo_connect/widgets/loading_view.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  final connectivityService = ConnectivityService();
  final FocusNode _searchFocusNode = FocusNode();
  String searchQuery = '';

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);

    return Scaffold(
        resizeToAvoidBottomInset:
            true, // Allow the body to resize when the keyboard appears

        body: SafeArea(
          child: CustomMaterialIndicator(
            onRefresh: () async {
              final isConnected = await connectivityService.isConnected();
              if (isConnected) {
                await ref.read(homeViewModelProvider.notifier).refreshWeather();
              }
            },
            indicatorBuilder: (context, controller) {
              return Lottie.asset(
                AppAssets.loader,
              );
            },
            child: homeState.when(
              data: (data) {
                return _buildHomeContent(context, data);
              },
              loading: () => const LoadingView(),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: homeState.whenOrNull(
          data: (data) => data.cityState.cities.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () => _showAddCityBottomSheet(context),
                  child: const Icon(Icons.add),
                )
              : null,
        ));
  }

  Widget _buildHomeContent(BuildContext context, HomeState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, state),
          const SizedBox(height: 16),
          _buildSearchBar(context),
          const SizedBox(height: 16),
          _buildCitiesList(context, state),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeState state) {
    final user = state.userState;
    if (user == null || user.user == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'Bonjour',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Text(
                  user.user!.name.isNotEmpty ? ' ${user.user!.name},' : ',',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const ConnectivityWidget(),
          ],
        ),
        if (user.user!.city != null && user.user!.city!.isNotEmpty)
          Row(
            children: [
              const Icon(Icons.gps_fixed_rounded, size: 12),
              Text(' ${user.user!.city}, ${user.user!.country}'),
            ],
          ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      focusNode: _searchFocusNode,
      decoration: InputDecoration(
        hintText: 'Search cities...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onChanged: (query) {
        ref.read(homeViewModelProvider.notifier).searchCities(query);
      },
    );
  }

  Widget _buildCitiesList(BuildContext context, HomeState state) {
    final cities = state.cityState.filteredCities;

    if (cities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No cities added yet'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showAddCityBottomSheet(context),
              child: const Text('Add your first city'),
            ),
          ],
        ),
      );
    }

    return Expanded(
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          Future.microtask(() {
            final List<CityModel> newOrder = List.from(cities);
            final item = newOrder.removeAt(oldIndex);
            newOrder.insert(newIndex, item);

            ref.read(homeViewModelProvider.notifier).reorderCities(newOrder);
          });
        },
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          return Padding(
            key: ValueKey('city_${city.name}_$index'),
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: _buildCityCard(context, city, index,
                key: ValueKey('city_${cities[index].name}_$index')),
          );
        },
      ),
    );
  }

  Widget _buildCityCard(
    BuildContext context,
    CityModel city,
    int index, {
    required Key key,
  }) {
    final homeViewModel = ref.read(homeViewModelProvider.notifier);
    final weather = homeViewModel.getWeatherForCity(city);
    final user = homeViewModel.user;

    if (weather == null) {
      return SizedBox(
        key: key,
        child: const LoadingView(),
      );
    }

    return Dismissible(
      key: ValueKey('dismissible_${city.name}_$index'),
      direction: DismissDirection.endToStart,
      resizeDuration: null,
      onDismissed: (_) => homeViewModel.removeCity(city.name),
      background: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          return Stack(
            children: [
              Positioned(
                right: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: screenWidth,
                    height: constraints.maxHeight,
                    alignment: Alignment.center,
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      confirmDismiss: (direction) async {
        await Future.delayed(const Duration(milliseconds: 300));
        return await _showDeleteConfirmation(context, city);
      },
      child: Hero(
        tag: 'city_${city.name}',
        child: WeatherCard(
          weather: weather,
          city: city,
          user: user!,
          index: index,
          showDragHandle: true,
          onTap: () => _navigateToCityDetails(context, city),
        ),
      ),
    );
  }

  void _showAddCityBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).bottomSheetTheme.backgroundColor,
      builder: (context) => const AddCityBottomSheet(),
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    CityModel city,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove City'),
        content: Text('Are you sure you want to remove ${city.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _navigateToCityDetails(BuildContext context, CityModel city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailsScreen(city: city),
      ),
    );
  }
}
