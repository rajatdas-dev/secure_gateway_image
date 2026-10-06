# secure_gateway_image

> Error-resilient image fallback widget for Flutter.

**Created and maintained by [Rajat Das](https://github.com/rajatdas-dev).**

An error-resilient Flutter image widget with a deterministic fallback pipeline:

**Network → Local Cache → Asset → Animated Initials Avatar**

[![pub package](https://img.shields.io/pub/v/secure_gateway_image.svg)](https://pub.dev/packages/secure_gateway_image)
[![pub points](https://img.shields.io/pub/points/secure_gateway_image.svg)](https://pub.dev/packages/secure_gateway_image)
[![popularity](https://img.shields.io/pub/popularity/secure_gateway_image.svg)](https://pub.dev/packages/secure_gateway_image)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

An error-resilient Flutter image widget with a deterministic fallback pipeline:

**Network → Local Cache → Asset → Animated Initials Avatar**

`secure_gateway_image` is designed for profile pictures, chat avatars, feed images, business pages, product images, and other UI components where a failed image source should never result in a broken-image UI.

---

## ✨ Features

- 🌐 Network image as the primary source
- 🔁 Configurable network retry logic (max 3s default retry window)
- 💾 Local `ImageProvider` fallback
- 📦 Flutter asset fallback
- 👤 Animated initials avatar as the final fallback
- 🎨 Creative fallback avatar when user initials are not provided
- ⚠️ Comprehensive error messaging & typed error metadata
- 🎨 Deterministic avatar colors
- ✨ Animated avatar entrance
- 🧩 Custom avatar and creative fallback builders
- ⏳ Loading and retrying placeholder support
- 🔐 Network request headers
- 🖼️ Image decoding controls
- ♿ Accessibility support
- 📡 Fallback stage callbacks
- 🌍 Flutter Web compatible
- 🪶 Zero third-party runtime dependencies
- 🚫 No state-management dependency
- 🔒 Null-safe
- 🧪 Testable and deterministic

---

# 💡 Why secure_gateway_image?

In production applications (chat feeds, social apps, profile screens, product catalogs, and user directories), image loading fails frequently due to spotty mobile networks, expired S3/CDN URLs, deleted assets, or incomplete user data. 

Handling these edge cases manually across every widget requires dozens of lines of repetitive boilerplate. `secure_gateway_image` solves these real-world problems out of the box:

### 1. 📶 Resilient Against Transient Network Drops
- **The Problem**: Standard Flutter `Image.network` fails immediately on temporary connection drops, slow DNS, or cell tower handoffs.
- **The Solution**: Built-in **3-second retry logic** automatically attempts retries with backoff and image cache eviction before giving up.

### 2. 🛡️ Zero Broken-Image UI
- **The Problem**: Expired URLs or 404s result in ugly grey error boxes or empty whitespace.
- **The Solution**: Multi-tier deterministic fallback (`Network → Local Cache → Asset → Initials Avatar → Creative Fallback`) ensures your UI is always complete and polished.

### 3. 🎨 Deterministic Avatars Without Database Bloat
- **The Problem**: Storing custom avatar background colors for every user in your database creates unnecessary schema complexity.
- **The Solution**: Avatar colors are generated deterministically using a name/seed hash—so "Alex Johnson" consistently gets the same signature hue across the entire application without any backend storage.

### 4. ✨ Creative Fallbacks for Anonymous / Incomplete Profiles
- **The Problem**: Guest accounts, system bots, or incomplete user profiles often lack both a profile picture and a name/initials.
- **The Solution**: When initials are absent, the widget renders **creative fallback avatars** (gradient glow, abstract geometric patterns, glassmorphic cards, or mesh gradients) with an error badge and tooltip.

### 5. 🪶 Zero Bloat & Architectural Freedom
- **The Problem**: Heavy image packages bundle monolithic caching engines, SQLite/Hive databases, or opinionated HTTP clients that create dependency conflicts.
- **The Solution**: `secure_gateway_image` has **zero third-party runtime dependencies** and accepts any standard `ImageProvider`, leaving caching architecture decisions to your application layer.

---

# 📦 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  secure_gateway_image: ^1.0.0
```

Then run:

```bash
flutter pub get
```

Import it:

```dart
import 'package:secure_gateway_image/secure_gateway_image.dart';
```

---

# 🚀 Basic Usage

The simplest usage is:

```dart
SecureGatewayImage(
  networkUrl: user.profileImageUrl,
  initials: user.name,
  size: 56,
)
```

The widget will try:

```text
Network
   ↓ failure
Initials Avatar
```

---

# 🔥 Complete Fallback Pipeline

The complete fallback order is:

```text
┌─────────────────────┐
│    Network Image    │
└──────────┬──────────┘
           │
        failure
           ↓
┌─────────────────────┐
│    Local Cache      │
│   ImageProvider     │
└──────────┬──────────┘
           │
        failure
           ↓
┌─────────────────────┐
│    Asset Image      │
└──────────┬──────────┘
           │
        failure
           ↓
┌─────────────────────┐
│ Animated Initials   │
│      Avatar         │
└─────────────────────┘
```

For example:

```dart
SecureGatewayImage(
  networkUrl: user.profileImageUrl,
  cachedImage: FileImage(cachedFile),
  assetPath: 'assets/images/default_avatar.png',
  initials: user.name,
  size: 64,
)
```

The behavior is:

```text
networkUrl
    ↓
network succeeds
    → display network image

network fails
    ↓
cachedImage
    ↓
cache succeeds
    → display cached image

cache fails
    ↓
assetPath
    ↓
asset succeeds
    → display asset

asset fails
    ↓
initials
    ↓
display animated avatar
```

If a source isn't provided, it is automatically skipped.

---

# 💾 Local Cache

`secure_gateway_image` intentionally does **not** manage disk caching.

The host application owns:

- HTTP caching
- disk storage
- cache expiration
- cache eviction
- stale-while-revalidate
- database storage
- encrypted storage
- authentication
- retry policies

The widget only receives an `ImageProvider`.

For example, with a cached `File`:

```dart
import 'dart:io';

SecureGatewayImage(
  networkUrl: networkUrl,
  cachedImage: FileImage(cachedFile),
  assetPath: 'assets/images/default_avatar.png',
  initials: 'Rajat Das',
)
```

You can also use a `MemoryImage`:

```dart
SecureGatewayImage(
  networkUrl: networkUrl,
  cachedImage: MemoryImage(imageBytes),
  assetPath: 'assets/images/default_avatar.png',
  initials: 'Rajat Das',
)
```

This design keeps caching concerns outside the UI package.

---

# 📦 Asset Fallback

Provide an asset as the third fallback:

```dart
SecureGatewayImage(
  networkUrl: networkUrl,
  cachedImage: FileImage(cachedFile),
  assetPath: 'assets/images/default_avatar.png',
  initials: 'Rajat Das',
)
```

Make sure the asset is declared in your application's `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/default_avatar.png
```

---

# 👤 Initials Avatar

If every image source fails, the widget generates an avatar from the supplied initials/name.

```dart
SecureGatewayImage(
  initials: 'Rajat Das',
  size: 64,
)
```

Produces:

```text
┌──────────────┐
│              │
│      RD      │
│              │
└──────────────┘
```

For:

```dart
initials: 'Rajat Das'
```

the generated initials are:

```text
RD
```

For:

```dart
initials: 'Rajat'
```

the generated initials are:

```text
R
```

For:

```dart
initials: ''
```

the generated fallback is:

```text
?
```

---

# 🎨 Deterministic Avatar Colors

Avatar colors are generated deterministically from the supplied name.

For example:

```dart
SecureGatewayImage(
  initials: 'Rajat Das',
  size: 64,
)
```

will consistently generate the same base avatar color for `"Rajat Das"`.

This means the same user doesn't randomly change avatar colors every time the widget rebuilds.

---

# ✨ Avatar Animation

The default initials avatar is animated.

```dart
SecureGatewayImage(
  initials: 'Rajat Das',
  size: 64,
  animateAvatar: true,
)
```

Disable the animation if required:

```dart
SecureGatewayImage(
  initials: 'Rajat Das',
  size: 64,
  animateAvatar: false,
)
```

Customize the animation:

```dart
SecureGatewayImage(
  initials: 'Rajat Das',
  size: 64,
  animateAvatar: true,
  avatarAnimationDuration:
      const Duration(milliseconds: 700),
  avatarAnimationCurve:
      Curves.easeOutBack,
)
```

---

# 🧩 Custom Avatar

If you don't want the built-in initials avatar, provide your own:

```dart
SecureGatewayImage(
  initials: 'RD',
  size: 64,
  avatarBuilder: (
    context,
    initials,
  ) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  },
)
```

The custom builder is used only when all image sources fail.

---

# 🔁 Retry Logic (Max 3 Seconds)

`secure_gateway_image` includes built-in retry logic that automatically retries failed network image fetches for a configurable window (defaults to **3 seconds**).

```dart
SecureGatewayImage(
  networkUrl: 'https://example.com/photo.jpg',
  initials: 'Rajat Das',
  size: 64,
  // Retry options:
  enableRetry: true,
  retryDuration: const Duration(seconds: 3), // Max 3s retry window
  retryInterval: const Duration(milliseconds: 1000), // 1s between retries
  onRetry: (attempt, elapsed) {
    debugPrint('Retry attempt #$attempt ($elapsed elapsed)');
  },
  onError: (errorMessage, error, stackTrace) {
    debugPrint('Permanent failure: $errorMessage');
  },
)
```

If the image fails after retrying for 3 seconds, retries stop and the widget gracefully falls back to:
1. Local cache (if provided)
2. Asset (if provided)
3. User initials avatar (if `initials` was set)
4. Creative fallback avatar (if `initials` was not set)

---

# 🎨 Creative Fallback Avatar (When Initials Are Not Set)

If every image source fails and the user did **not** set initials (or left `initials` empty/null), `secure_gateway_image` renders a creative, aesthetically designed fallback avatar instead of a generic broken image.

```dart
SecureGatewayImage(
  networkUrl: 'https://invalid.example.com/avatar.png',
  // initials omitted or null
  size: 80,
  creativeFallbackStyle: CreativeFallbackStyle.gradientGlow,
  showErrorBadge: true, // Displays an error badge with tooltip
)
```

### Available Creative Styles

- `CreativeFallbackStyle.gradientGlow`: Dynamic multi-stop gradient with glowing accent, glassmorphic icon pill, and soft shadow.
- `CreativeFallbackStyle.abstractPattern`: Procedural geometric pattern and decorative accents.
- `CreativeFallbackStyle.glassmorphic`: Frosted dark glassmorphism card with glowing border and subtle sheen.
- `CreativeFallbackStyle.monogramMesh`: Smooth mesh gradient with modern glyph center.

### Custom Creative Fallback Builder

```dart
SecureGatewayImage(
  networkUrl: 'https://invalid.example.com/avatar.png',
  size: 80,
  creativeFallbackBuilder: (context, errorMessage) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text('Custom Error: $errorMessage'),
      ),
    );
  },
)
```

---

# ⚠️ Error Handling & Callbacks

Receive rich error information through `onError` and `onImageError`:

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  initials: 'RD',
  onError: (message, error, stackTrace) {
    debugPrint('Error message: $message');
  },
  onImageError: (GatewayImageError errorInfo) {
    debugPrint('Failed stage: ${errorInfo.stage}');
    debugPrint('Attempts: ${errorInfo.retryAttempts}');
    debugPrint('Duration: ${errorInfo.totalRetryDuration}');
  },
)
```

---

# ⏳ Loading Placeholder

You can provide a custom loading widget:

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  initials: 'RD',
  placeholder: (context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  },
)
```

For a skeleton:

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  initials: 'RD',
  placeholder: (context) {
    return Container(
      color: Colors.grey.shade300,
    );
  },
)
```

---

# 🔐 Network Headers

Authenticated image endpoints can use headers:

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  headers: {
    'Authorization': 'Bearer $token',
  },
  initials: 'RD',
)
```

This is useful for APIs where image URLs require authentication.

---

# 🖼️ Image Fit

All standard Flutter `BoxFit` values are supported.

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  initials: 'RD',
  size: 100,
  fit: BoxFit.cover,
)
```

Other options:

```dart
BoxFit.contain
BoxFit.cover
BoxFit.fill
BoxFit.fitWidth
BoxFit.fitHeight
BoxFit.none
BoxFit.scaleDown
```

---

# 📐 Width and Height

You can use `size`:

```dart
SecureGatewayImage(
  initials: 'RD',
  size: 56,
)
```

or specify width and height independently:

```dart
SecureGatewayImage(
  initials: 'RD',
  width: 100,
  height: 60,
)
```

If both `width`/`height` and `size` are supplied, explicit `width` and `height` take precedence.

---

# 🔲 Border Radius

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  initials: 'RD',
  size: 64,
  borderRadius:
      BorderRadius.circular(16),
)
```

Circular avatar:

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  initials: 'RD',
  size: 64,
  borderRadius:
      BorderRadius.circular(999),
)
```

---

# 📡 Monitoring Fallback Stages

You can monitor which source is currently active:

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  cachedImage: FileImage(cachedFile),
  assetPath: 'assets/default.png',
  initials: 'Rajat Das',

  onStageChanged: (stage) {
    debugPrint(
      'Image stage: $stage',
    );
  },
)
```

Available stages:

```dart
GatewayImageStage.network
GatewayImageStage.cache
GatewayImageStage.asset
GatewayImageStage.avatar
```

For example, if the network fails and cache succeeds:

```text
network
   ↓
cache
```

If everything fails:

```text
network
   ↓
cache
   ↓
asset
   ↓
avatar
```

---

# ♿ Accessibility

For meaningful images, provide a semantic label:

```dart
SecureGatewayImage(
  networkUrl: profileImage,
  initials: 'Rajat Das',
  semanticLabel:
      'Profile photo of Rajat Das',
)
```

For purely decorative images:

```dart
SecureGatewayImage(
  networkUrl: backgroundImage,
  initials: '',
  excludeFromSemantics: true,
)
```

---

# ⚡ Performance

For large source images displayed at small dimensions, use `cacheWidth` and `cacheHeight`.

Example:

```dart
SecureGatewayImage(
  networkUrl: imageUrl,
  initials: 'RD',
  size: 48,
  cacheWidth: 144,
  cacheHeight: 144,
)
```

This can prevent unnecessarily decoding a huge original image when the UI only needs a small avatar.

Do not blindly use the original image resolution for tiny UI elements.

---

# 🌐 Flutter Web

The package itself does not import `dart:io`.

The cache source is an `ImageProvider`, which means the widget can be used across Flutter platforms.

For mobile/desktop file caching:

```dart
SecureGatewayImage(
  networkUrl: url,
  cachedImage: FileImage(file),
  initials: 'RD',
)
```

For web-compatible cached bytes:

```dart
SecureGatewayImage(
  networkUrl: url,
  cachedImage: MemoryImage(bytes),
  initials: 'RD',
)
```

---

# 🏗️ Architecture

The package intentionally follows a simple responsibility boundary.

```text
┌─────────────────────────────────────┐
│          Application Layer          │
│                                     │
│  API / Dio / Repository / Database │
│             │                       │
│             │ cached image          │
│             ▼                       │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│      SecureGatewayImage             │
│                                     │
│  Network                            │
│     ↓                               │
│  Cached ImageProvider               │
│     ↓                               │
│  Asset                              │
│     ↓                               │
│  Initials Avatar                    │
└─────────────────────────────────────┘
```

The package does **not** own the application's data layer.

---

# 🚫 What This Package Does NOT Do

`secure_gateway_image` does not provide:

- HTTP client
- Disk cache
- Database
- Authentication
- Token refresh
- Retry policy
- Cache eviction
- Background downloads
- State management
- Bloc
- Riverpod
- Provider
- GetX
- Service locator

These responsibilities should remain in the application layer.

---

# 🧠 Why No Built-in Cache?

A common mistake would be to make this widget responsible for downloading and caching images.

That creates unnecessary coupling:

```text
Widget
 ├── HTTP
 ├── Cache
 ├── Database
 ├── File system
 ├── Retry
 └── Rendering
```

Instead, this package follows:

```text
Repository
    │
    ├── HTTP
    ├── Cache
    └── Persistence
          │
          ▼
SecureGatewayImage
    │
    ├── Render network
    ├── Render cache
    ├── Render asset
    └── Render avatar
```

This keeps the package small and reusable.

---

# 📄 License

This project is licensed under the MIT License.

See:

```text
LICENSE
```

---

# ⭐ Example

A typical production usage might look like:

```dart
SecureGatewayImage(
  networkUrl: user.profileImageUrl,

  cachedImage: cachedFile == null
      ? null
      : FileImage(cachedFile),

  assetPath:
      'assets/images/default_avatar.png',

  initials: user.name,

  size: 48,

  borderRadius:
      BorderRadius.circular(12),

  fit: BoxFit.cover,

  cacheWidth: 144,
  cacheHeight: 144,

  onStageChanged: (stage) {
    debugPrint(
      'Image source: $stage',
    );
  },
)
```

The resulting behavior is:

```text
                 Network
                    │
             ┌──────┴──────┐
             │             │
          Success        Failure
             │             │
             ▼             ▼
           Image          Cache
                            │
                     ┌──────┴──────┐
                     │             │
                  Success        Failure
                     │             │
                     ▼             ▼
                   Image          Asset
                                   │
                            ┌──────┴──────┐
                            │             │
                         Success        Failure
                            │             │
                            ▼             ▼
                          Image      Initials Avatar
```

The widget therefore provides a predictable rendering contract:


---

# 👨‍💻 Author

**Rajat Das**

Flutter Developer | Mobile Application Developer

Created and maintained by Rajat Das.

GitHub: https://github.com/rajatdas-dev

---

# 📄 License

Copyright © 2026 Rajat Das.

This project is licensed under the MIT License.

See [LICENSE](LICENSE) for details.

> **There should always be a valid visual representation, even when every external image source fails.**
