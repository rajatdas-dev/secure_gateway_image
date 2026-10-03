/// Represents the currently active source in the fallback pipeline.
enum GatewayImageStage {
  /// The remote network image.
  network,

  /// The locally supplied cached image provider.
  cache,

  /// The Flutter asset image.
  asset,

  /// The generated initials avatar.
  avatar,
}
