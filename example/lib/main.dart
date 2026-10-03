import 'package:flutter/material.dart';

import 'package:secure_gateway_image/secure_gateway_image.dart';

void main() {
  runApp(const SecureGatewayExampleApp());
}

class SecureGatewayExampleApp extends StatelessWidget {
  const SecureGatewayExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Gateway Image',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secure Gateway Image')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Broken network → initials',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Center(
            child: SecureGatewayImage(
              networkUrl: 'https://invalid.example.invalid/avatar.png',
              initials: 'Rajat Das',
              size: 120,
              borderRadius: BorderRadius.circular(24),
              onStageChanged: (stage) {
                debugPrint('Current stage: $stage');
              },
            ),
          ),

          const SizedBox(height: 48),

          const Text(
            'Initials only',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          const Center(
            child: SecureGatewayImage(initials: 'Secure Gateway', size: 120),
          ),

          const SizedBox(height: 48),

          const Text(
            'Custom avatar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Center(
            child: SecureGatewayImage(
              initials: 'RD',
              size: 120,
              avatarBuilder: _customAvatarBuilder,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _customAvatarBuilder(BuildContext context, String initials) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
