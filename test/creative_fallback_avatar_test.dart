import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:secure_gateway_image/secure_gateway_image.dart';

void main() {
  group('CreativeFallbackAvatar', () {
    testWidgets('renders gradientGlow style with center icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreativeFallbackAvatar(
              size: 80,
              style: CreativeFallbackStyle.gradientGlow,
              errorMessage: 'Network timeout after 3s',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CreativeFallbackAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byType(Tooltip), findsOneWidget);
    });

    testWidgets('renders abstractPattern style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreativeFallbackAvatar(
              size: 80,
              style: CreativeFallbackStyle.abstractPattern,
              errorMessage: 'Failed to load',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
    });

    testWidgets('renders glassmorphic style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreativeFallbackAvatar(
              size: 80,
              style: CreativeFallbackStyle.glassmorphic,
              errorMessage: 'Failed to load',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.broken_image_rounded), findsOneWidget);
    });

    testWidgets('renders monogramMesh style', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CreativeFallbackAvatar(
              size: 80,
              style: CreativeFallbackStyle.monogramMesh,
              errorMessage: 'Failed to load',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.account_circle_rounded), findsOneWidget);
    });

    testWidgets('supports custom icon and custom builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CreativeFallbackAvatar(
              size: 80,
              customBuilder: (context, errorMessage) {
                return Text('CUSTOM_CREATIVE: $errorMessage');
              },
              errorMessage: 'Custom error occurred',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('CUSTOM_CREATIVE: Custom error occurred'), findsOneWidget);
    });
  });
}
