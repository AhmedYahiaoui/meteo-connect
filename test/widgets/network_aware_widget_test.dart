import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meteo_connect/services/connectivity_service.dart';
import 'package:meteo_connect/widgets/network_aware_widget.dart';

void main() {
  testWidgets('NetworkAwareWidget shows correct child based on connectivity',
      (tester) async {
    final onlineChild = Container(key: const Key('online'));
    final offlineChild = Container(key: const Key('offline'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: MaterialApp(
          home: NetworkAwareWidget(
            onlineChild: onlineChild,
            offlineChild: offlineChild,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('online')), findsOneWidget);
    expect(find.byKey(const Key('offline')), findsNothing);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: MaterialApp(
          home: NetworkAwareWidget(
            onlineChild: onlineChild,
            offlineChild: offlineChild,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('online')), findsNothing);
    expect(find.byKey(const Key('offline')), findsOneWidget);
  });
} 