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
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
      ),
      home: const ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  String _retryStatus = 'Waiting for failure...';
  String _lastErrorMessage = 'None';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Gateway Image Showcase'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildCard(
            title: '1. Network Retry (Max 3s) → Initials Fallback',
            subtitle:
                'Attempts retries for up to 3s with backoff, captures the error message, then falls back to user initials.',
            child: Column(
              children: [
                Center(
                  child: SecureGatewayImage(
                    networkUrl: 'https://invalid.example.invalid/avatar.png',
                    initials: 'Rajat Das',
                    size: 110,
                    borderRadius: BorderRadius.circular(24),
                    retryDuration: const Duration(seconds: 3),
                    retryInterval: const Duration(seconds: 1),
                    onRetry: (attempt, elapsed) {
                      setState(() {
                        _retryStatus = 'Retrying attempt #$attempt (${elapsed.inMilliseconds}ms elapsed)';
                      });
                    },
                    onError: (message, error, stackTrace) {
                      setState(() {
                        _retryStatus = 'Retry timed out (3s max). Switched to fallback.';
                        _lastErrorMessage = message;
                      });
                    },
                    onStageChanged: (stage) {
                      debugPrint('Current stage: $stage');
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $_retryStatus',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Error message: $_lastErrorMessage',
                        style: const TextStyle(fontSize: 12, color: Color(0xFFF87171)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildCard(
            title: '2. Creative Fallback (Initials NOT set)',
            subtitle:
                'When the user does not set initials, the widget renders an aesthetically styled creative fallback with an error badge and tooltip.',
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildStyleItem(
                  label: 'Gradient Glow',
                  child: const SecureGatewayImage(
                    networkUrl: 'https://invalid.example.invalid/avatar.png',
                    enableRetry: false,
                    size: 90,
                    creativeFallbackStyle: CreativeFallbackStyle.gradientGlow,
                    showErrorBadge: true,
                  ),
                ),
                _buildStyleItem(
                  label: 'Abstract Pattern',
                  child: const SecureGatewayImage(
                    networkUrl: 'https://invalid.example.invalid/avatar.png',
                    enableRetry: false,
                    size: 90,
                    creativeFallbackStyle: CreativeFallbackStyle.abstractPattern,
                    showErrorBadge: true,
                  ),
                ),
                _buildStyleItem(
                  label: 'Glassmorphic',
                  child: const SecureGatewayImage(
                    networkUrl: 'https://invalid.example.invalid/avatar.png',
                    enableRetry: false,
                    size: 90,
                    creativeFallbackStyle: CreativeFallbackStyle.glassmorphic,
                    showErrorBadge: true,
                  ),
                ),
                _buildStyleItem(
                  label: 'Monogram Mesh',
                  child: const SecureGatewayImage(
                    networkUrl: 'https://invalid.example.invalid/avatar.png',
                    enableRetry: false,
                    size: 90,
                    creativeFallbackStyle: CreativeFallbackStyle.monogramMesh,
                    showErrorBadge: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildCard(
            title: '3. Initials Avatar Only',
            subtitle: 'Directly generated initials avatar with deterministic colors.',
            child: const Center(
              child: SecureGatewayImage(
                initials: 'Secure Gateway',
                size: 100,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildCard(
            title: '4. Custom Avatar Builder',
            subtitle: 'Full customization through custom builders when needed.',
            child: Center(
              child: SecureGatewayImage(
                initials: 'RD',
                size: 100,
                avatarBuilder: _customAvatarBuilder,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF334155), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStyleItem({required String label, required Widget child}) {
    return Column(
      children: [
        child,
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
        ),
      ],
    );
  }
}

Widget _customAvatarBuilder(BuildContext context, String initials) {
  return DecoratedBox(
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Center(
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    ),
  );
}
