import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

const _ink = _Rgb(0x2F, 0x29, 0x23);
const _paper = _Rgb(0xFF, 0xFC, 0xF5);
const _caramel = _Rgb(0xE0, 0x8A, 0x32);

void main() {
  final targets = <String, int>{
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@1x.png': 20,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@2x.png': 40,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-20x20@3x.png': 60,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@1x.png': 29,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@2x.png': 58,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-29x29@3x.png': 87,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@1x.png': 40,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@2x.png': 80,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-40x40@3x.png': 120,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@2x.png': 120,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-60x60@3x.png': 180,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@1x.png': 76,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-76x76@2x.png': 152,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-83.5x83.5@2x.png':
        167,
    'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png':
        1024,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_16.png': 16,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_32.png': 32,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_64.png': 64,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_128.png': 128,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_256.png': 256,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_512.png': 512,
    'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png': 1024,
  };

  for (final entry in targets.entries) {
    final icon = _createIcon(entry.value);
    File(entry.key)
      ..createSync(recursive: true)
      ..writeAsBytesSync(img.encodePng(icon));
  }
}

img.Image _createIcon(int size) {
  final image = img.Image(width: size, height: size);
  _fill(image, _ink);

  final safe = (size * 0.22).round();
  final gap = math.max(1, (size * 0.075).round());
  final dotSize = ((size - safe * 2 - gap * 2) / 3).floor();
  final gridSize = dotSize * 3 + gap * 2;
  final start = ((size - gridSize) / 2).round();
  final radius = math.max(1, (dotSize * 0.16).round());

  for (var row = 0; row < 3; row++) {
    for (var col = 0; col < 3; col++) {
      final index = row * 3 + col;
      final active =
          index == 0 || index == 2 || index == 4 || index == 6 || index == 8;
      final color = active ? _caramel : _paper;
      final x = start + col * (dotSize + gap);
      final y = start + row * (dotSize + gap);
      _roundedRect(image, x, y, dotSize, dotSize, radius, color);
    }
  }

  return image;
}

void _fill(img.Image image, _Rgb color) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgb(x, y, color.r, color.g, color.b);
    }
  }
}

void _roundedRect(
  img.Image image,
  int left,
  int top,
  int width,
  int height,
  int radius,
  _Rgb color,
) {
  final right = left + width - 1;
  final bottom = top + height - 1;
  for (var y = top; y <= bottom; y++) {
    for (var x = left; x <= right; x++) {
      final nearLeft = x < left + radius;
      final nearRight = x > right - radius;
      final nearTop = y < top + radius;
      final nearBottom = y > bottom - radius;

      if ((nearLeft || nearRight) && (nearTop || nearBottom)) {
        final cx = nearLeft ? left + radius : right - radius;
        final cy = nearTop ? top + radius : bottom - radius;
        final dx = x - cx;
        final dy = y - cy;
        if (dx * dx + dy * dy > radius * radius) {
          continue;
        }
      }

      image.setPixelRgb(x, y, color.r, color.g, color.b);
    }
  }
}

class _Rgb {
  const _Rgb(this.r, this.g, this.b);

  final int r;
  final int g;
  final int b;
}
