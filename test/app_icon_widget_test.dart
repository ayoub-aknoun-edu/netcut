import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:netcut/app_providers.dart';
import 'package:netcut/features/apps/widgets/app_icon.dart';

final Uint8List k1x1TransparentPng = Uint8List.fromList(<int>[
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  10,
  73,
  68,
  65,
  84,
  120,
  156,
  99,
  0,
  1,
  0,
  0,
  5,
  0,
  1,
  13,
  10,
  42,
  181,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130,
]);

void main() {
  testWidgets('shows fallback icon when provider returns null', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Prevent calling the Android platform channel in tests.
          appIconPngProvider.overrideWith((ref, pkg) async => null),
        ],
        child: const MaterialApp(
          home: Scaffold(body: AppIcon(packageName: 'x', iconPng: null)),
        ),
      ),
    );

    expect(find.byIcon(Icons.apps_rounded), findsOneWidget);
  });

  testWidgets('shows an Image when iconPng is provided', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: AppIcon(packageName: 'x', iconPng: null)),
        ),
      ),
    );
    // Re-pump with icon bytes (keeps test simple & deterministic).
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AppIcon(packageName: 'x', iconPng: k1x1TransparentPng),
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.apps_rounded), findsNothing);
  });
}
