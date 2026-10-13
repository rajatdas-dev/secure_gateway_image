# Changelog

## 0.1.0

### Added
- **Caching System Integration**: Implemented a caching system based on `flutter_cache_manager` (matching the caching architecture of `cached_network_image`).
- **`SecureGatewayCachedImageProvider`**: Added a dedicated `ImageProvider` supporting memory and disk caching, custom cache managers, custom cache keys, and animated GIF/WebP streams via `MultiImageStreamCompleter`.
- **Cache Configuration Options in `SecureGatewayImage`**:
  - `enableCache`: Flag to enable or bypass caching (defaults to `true`).
  - `cacheKey`: Optional custom cache key to identify cached images.
  - `cacheManager`: Support for custom `BaseCacheManager` instances for customized cache retention policies and disk storage directories.
  - `maxWidthDiskCache` & `maxHeightDiskCache`: Resize and optimize images before writing to disk cache.
- **Cache Eviction Utilities**:
  - Added `SecureGatewayImage.evictFromCache(url, {cacheKey, cacheManager})` to evict images from both memory and disk cache.
  - Added `SecureGatewayCachedImageProvider.evictFromCache()` and `evictFromMemory()`.
  - Added automatic memory and disk cache eviction on retry cycles to prevent corrupted responses from sticking in cache.
- **Exported Cache Manager Symbols**: Exported `BaseCacheManager`, `DefaultCacheManager`, `CacheManager`, `ImageCacheManager`, `FileInfo`, and related classes directly from `package:secure_gateway_image/secure_gateway_image.dart`.
- **Tests & Documentation**: Added unit and widget tests covering cache hits, cache bypass (`enableCache: false`), custom cache managers, eviction, and disk cache dimension constraints. Updated `README.md` and `example/lib/main.dart` with caching documentation.

## 0.0.3

- Added automatic retry logic with configurable duration (defaults to max 3 seconds) and backoff.
- Added comprehensive error messaging via `onError` callback and typed `GatewayImageError` metadata via `onImageError`.
- Added creative fallback avatar (`CreativeFallbackAvatar`) with multiple visual styles (`gradientGlow`, `abstractPattern`, `glassmorphic`, `monogramMesh`) when user initials are not set.
- Added error badge and tooltip indicator on the creative avatar.
- Added support for custom `creativeFallbackBuilder`.
- Updated test suite with comprehensive tests for retry cycles, error handling, and creative avatars.

## 0.0.2

- Fixed package publishing configuration.
- Converted the example application to a regular package directory.
- Improved package metadata and publishing configuration.

## 0.0.1

Initial stable release.

### Added

- Network image support.
- Local ImageProvider fallback.
- Asset fallback.
- Animated initials avatar.
- Deterministic avatar colors.
- Custom avatar builder.
- Loading placeholder.
- Fallback stage callbacks.
- Accessibility support.
- Image decoding controls.
- Fade-in image animation.