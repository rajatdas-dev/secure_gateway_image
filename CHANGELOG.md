# Changelog

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