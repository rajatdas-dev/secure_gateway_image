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

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('RD'), findsOneWidget);
  });

  testWidgets('network failure falls through to avatar', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SecureGatewayImage(
            networkUrl: 'https://invalid.example.invalid/avatar.png',
            initials: 'Rajat Das',
            size: 80,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('RD'), findsOneWidget);
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

    await tester.pump();

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
