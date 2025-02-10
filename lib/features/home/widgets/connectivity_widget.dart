import 'package:flutter/material.dart';
import 'package:meteo_connect/services/connectivity_service.dart';

class ConnectivityWidget extends StatelessWidget {
  const ConnectivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();
    return StreamBuilder<bool>(
      stream: connectivityService.onConnectivityChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasData && !snapshot.data!) {
          return IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            onPressed: () => _showConnectivityDialog(context),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showConnectivityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text(
          'Currently, there is no internet connection. Data is being fetched from local storage.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
