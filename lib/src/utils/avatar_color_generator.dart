import 'package:flutter/material.dart';

Color avatarColorFor(String value) {
  final hash = value.trim().codeUnits.fold<int>(
    17,
    (hash, unit) => 37 * hash + unit,
  );

  final hue = (hash.abs() % 360).toDouble();

  return HSVColor.fromAHSV(1, hue, 0.62, 0.82).toColor();
}
