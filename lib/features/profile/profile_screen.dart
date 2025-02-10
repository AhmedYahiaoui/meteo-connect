import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/features/profile/profile_viewmodel.dart';
import 'package:meteo_connect/widgets/city_search_dropdown.dart';
import 'package:meteo_connect/widgets/confirmation_bottom_sheet.dart';
import 'package:meteo_connect/widgets/loading_view.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: profileState.when(
        data: (state) => _buildContent(context, ref),
        loading: () => const LoadingView(),
        error: (error, _) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserSection(context, ref),
          const SizedBox(height: 24),
          _buildLocationSection(context, ref),
          const SizedBox(height: 24),
          _buildNotificationSection(context, ref),
          const SizedBox(height: 24),
          _buildSettingsSection(context, ref),
          const SizedBox(height: 24),
          _buildResetSection(context, ref),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUserSection(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final user = viewModel.user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(user?.name ?? 'Set your name'),
              trailing: const Icon(Icons.edit),
              onTap: () => _showNameEditDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final user = viewModel.user;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on_outlined),
              title: Text(
                user?.city != null && user!.city!.isNotEmpty
                    ? '${user.city}, ${user.country}'
                    : 'Set your location',
              ),
              trailing: const Icon(Icons.refresh),
              onTap: () => _updateLocation(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final cities = viewModel.cities.map((city) => city.name).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CitySearchDropdown(
              currentValue: viewModel.user?.defaultCity ?? '',
              onChanged: (newCity) {
                if (newCity != null) {
                  viewModel.updateDefaultCity(newCity);
                }
              },
              cities: cities,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              secondary: const Icon(Icons.notifications_active_rounded),
              value: viewModel.user?.weatherNotificationsEnabled ?? false,
              onChanged: (bool value) =>
                  viewModel.updateWeatherNotifications(value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Dark Mode'),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: viewModel.isDarkMode,
              onChanged: (_) => viewModel.toggleTheme(),
            ),
            SwitchListTile(
              title: const Text('Use Fahrenheit'),
              secondary: const Icon(Icons.thermostat_outlined),
              value: viewModel.useFahrenheit,
              onChanged: (_) => viewModel.toggleTemperatureUnit(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetSection(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Clear Cities'),
              subtitle: const Text('Remove all saved cities'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => ConfirmationBottomSheet(
                    title: 'Clear Cities',
                    message:
                        'Are you sure you want to remove all saved cities?',
                    confirmLabel: 'Clear',
                    onConfirm: () async {
                      try {
                        // Clear cities first
                        viewModel.resetCities();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              showCloseIcon: true,
                              behavior: SnackBarBehavior.floating,
                              content: Text('Cities cleared successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              showCloseIcon: true,
                              behavior: SnackBarBehavior.floating,
                              content: Text(
                                  'Error clearing cities: ${e.toString()}'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Reset App'),
              subtitle:
                  const Text('Clear all data and reset to default settings'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => ConfirmationBottomSheet(
                    title: 'Reset App',
                    message: 'Are you sure you want to reset all app data?',
                    confirmLabel: 'Reset',
                    onConfirm: () async {
                      try {
                        // Clear and reset the app
                        viewModel.resetApp();

                        // Refresh the current screen
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              showCloseIcon: true,
                              behavior: SnackBarBehavior.floating,
                              content: Text('App reset successfully'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Error resetting app: ${e.toString()}'),
                              backgroundColor: Colors.red,
                              showCloseIcon: true,
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNameEditDialog(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(profileViewModelProvider.notifier);
    final controller = TextEditingController(text: viewModel.user?.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: Container(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'Enter your name',
            ),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                viewModel.updateUserName(name);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLocation(BuildContext context, WidgetRef ref) async {
    final viewModel = ref.read(profileViewModelProvider.notifier);

    try {
      await viewModel.updateLocation();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully'),
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating location: $e'),
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
