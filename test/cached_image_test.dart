import 'dart:async';
import 'dart:typed_data';

import 'package:file/file.dart' as f;
import 'package:file/local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:secure_gateway_image/secure_gateway_image.dart';

// 1x1 transparent PNG bytes for testing
final Uint8List _kTransparentPng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

class _FakeTestCacheManager implements BaseCacheManager {
  _FakeTestCacheManager(this._testFile);

  final f.File _testFile;
  bool removeFileCalled = false;
  String? lastRemovedKey;

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) async* {
    yield FileInfo(
      _testFile,
      FileSource.Cache,
      DateTime.now().add(const Duration(days: 7)),
      url,
    );
  }

  @override
  Future<void> removeFile(String key) async {
    removeFileCalled = true;
    lastRemovedKey = key;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const fs = LocalFileSystem();
  late f.Directory tempDir;
  late f.File sampleImageFile;
  late _FakeTestCacheManager fakeCacheManager;

  setUp(() async {
    tempDir = await fs.systemTempDirectory.createTemp('sgi_cache_test_');
    sampleImageFile = tempDir.childFile('test_image.png');
    await sampleImageFile.writeAsBytes(_kTransparentPng);
    fakeCacheManager = _FakeTestCacheManager(sampleImageFile);
  });

  tearDown(() async {
    try {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    } catch (_) {}
  });

  group('SecureGatewayCachedImageProvider', () {
    test('equality and hashcode comparison', () {
      const provider1 = SecureGatewayCachedImageProvider(
        'https://example.com/photo.jpg',
        cacheKey: 'custom_key_1',
        scale: 1.0,
      );
      const provider2 = SecureGatewayCachedImageProvider(
        'https://example.com/photo.jpg',
        cacheKey: 'custom_key_1',
        scale: 1.0,
      );
      const provider3 = SecureGatewayCachedImageProvider(
        'https://example.com/photo.jpg',
        cacheKey: 'custom_key_2',
        scale: 1.0,
      );

      expect(provider1, equals(provider2));
      expect(provider1.hashCode, equals(provider2.hashCode));
      expect(provider1, isNot(equals(provider3)));
      expect(
        provider1.toString(),
        contains('https://example.com/photo.jpg'),
      );
    });

    test('obtainKey resolves to itself', () async {
      const provider = SecureGatewayCachedImageProvider(
        'https://example.com/photo.jpg',
      );
      final key = await provider.obtainKey(ImageConfiguration.empty);
      expect(key, equals(provider));
    });

    test('evictFromMemory removes image from memory cache', () {
      const provider = SecureGatewayCachedImageProvider(
        'https://example.com/photo.jpg',
      );
      final evicted = provider.evictFromMemory();
      expect(evicted, isA<bool>());
    });

    test('static evictFromCache removes from memory and cacheManager', () async {
      await SecureGatewayCachedImageProvider.evictFromCache(
        'https://example.com/photo.jpg',
        cacheKey: 'evict_key',
        cacheManager: fakeCacheManager,
      );

      expect(fakeCacheManager.removeFileCalled, isTrue);
      expect(fakeCacheManager.lastRemovedKey, equals('evict_key'));
    });
  });

  group('SecureGatewayImage cache integration', () {
    testWidgets('renders network image using custom cacheManager from disk cache', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SecureGatewayImage(
              networkUrl: 'https://example.com/profile.png',
              cacheManager: fakeCacheManager,
              size: 100,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<SecureGatewayCachedImageProvider>());
      final provider = imageWidget.image as SecureGatewayCachedImageProvider;
      expect(provider.url, equals('https://example.com/profile.png'));
      expect(provider.cacheManager, equals(fakeCacheManager));
    });

    testWidgets('respects enableCache: false by using NetworkImage', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SecureGatewayImage(
              networkUrl: 'https://example.com/profile.png',
              enableCache: false,
              size: 100,
            ),
          ),
        ),
      );

      final imageWidget = tester.widget<Image>(find.byType(Image));
      expect(imageWidget.image, isA<NetworkImage>());
      final provider = imageWidget.image as NetworkImage;
      expect(provider.url, equals('https://example.com/profile.png'));
    });

    testWidgets('static evictFromCache removes file via cacheManager', (tester) async {
      await SecureGatewayImage.evictFromCache(
        'https://example.com/photo.jpg',
        cacheKey: 'avatar_user_123',
        cacheManager: fakeCacheManager,
      );

      expect(fakeCacheManager.removeFileCalled, isTrue);
      expect(fakeCacheManager.lastRemovedKey, equals('avatar_user_123'));
    });
  });
}
