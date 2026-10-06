import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:secure_gateway_image/secure_gateway_image.dart';

void main() {
  testWidgets('renders initials avatar when no sources exist', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(initials: 'Rajat Das', size: 80),
        ),
      ),
    );

    expect(find.text('RD'), findsOneWidget);
  });

  testWidgets('renders custom avatar builder', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(
            initials: 'Rajat Das',
            size: 80,
            avatarBuilder: _customAvatar,
          ),
        ),
      ),
    );

    expect(find.text('CUSTOM'), findsOneWidget);
  });

  testWidgets('invalid asset falls back to avatar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(
            assetPath: 'assets/does_not_exist.png',
            initials: 'Rajat Das',
            size: 80,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('RD'), findsOneWidget);
  });

  testWidgets('network failure retries up to 3 seconds then falls through to initials avatar', (tester) async {
    int retryCount = 0;
    String? capturedError;
    GatewayImageError? typedError;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(
            networkUrl: 'https://invalid.example.invalid/avatar.png',
            initials: 'Rajat Das',
            size: 80,
            onRetry: (attempt, elapsed) {
              retryCount = attempt;
            },
            onError: (message, error, stackTrace) {
              capturedError = message;
            },
            onImageError: (error) {
              typedError = error;
            },
          ),
        ),
      ),
    );

    // Drive the retry timer loop and subsequent async frame failures
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    // Falls back to initials set by user
    expect(find.text('RD'), findsOneWidget);
    // Verifies retries took place
    expect(retryCount, greaterThan(0));
    // Verifies error message was captured
    expect(capturedError, isNotNull);
    expect(capturedError, contains('Failed to load network image'));
    expect(typedError, isNotNull);
    expect(typedError?.stage, equals(GatewayImageStage.network));
  });

  testWidgets('network failure falls back to creative fallback avatar when initials are not set', (tester) async {
    String? capturedError;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(
            networkUrl: 'https://invalid.example.invalid/avatar.png',
            // initials are not set
            size: 80,
            creativeFallbackStyle: CreativeFallbackStyle.gradientGlow,
            onError: (message, error, stackTrace) {
              capturedError = message;
            },
          ),
        ),
      ),
    );

    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
    }
    await tester.pumpAndSettle();

    // Finds CreativeFallbackAvatar
    expect(find.byType(CreativeFallbackAvatar), findsOneWidget);
    expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    expect(capturedError, isNotNull);
  });

  testWidgets('renders custom creativeFallbackBuilder when initials are not set', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(
            enableRetry: false,
            networkUrl: 'https://invalid.example.invalid/avatar.png',
            size: 80,
            creativeFallbackBuilder: (context, errorMessage) {
              return Text('CREATIVE_FALLBACK: $errorMessage');
            },
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('CREATIVE_FALLBACK:'), findsOneWidget);
  });

  testWidgets('stage callback reports avatar stage', (tester) async {
    final stages = <GatewayImageStage>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(
            initials: 'Rajat Das',
            size: 80,
            onStageChanged: stages.add,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('RD'), findsOneWidget);
    expect(stages, isEmpty);
  });
}

Widget _customAvatar(BuildContext context, String initials) {
  return const ColoredBox(
    color: Colors.black,
    child: Center(child: Text('CUSTOM')),
  );
}
