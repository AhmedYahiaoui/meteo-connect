import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meteo_connect/services/connectivity_service.dart';

class NetworkAwareWidget extends ConsumerWidget {
  final Widget onlineChild;
  final Widget offlineChild;

  const NetworkAwareWidget({
    super.key,
    required this.onlineChild,
    required this.offlineChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);

    return isOnline.when(
      data: (online) => online ? onlineChild : offlineChild,
      loading: () => onlineChild,
      error: (_, __) => offlineChild,
    );
  }
} 