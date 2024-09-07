import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class DithererUtil {
  static img.Image dither(img.Image imgData, List<Color> colors) {
    ColorPalette palette = ColorPalette(colors);
    Ditherer ditherer = Ditherer(palette);
    ditherer.dither(imgData);
    return imgData;
  }
}

class ColorPalette {
  List<VectorRGB> colors;

  ColorPalette(List<Color> colors)
      : colors = colors.map((color) => VectorRGB.fromColor(color)).toList();

  VectorRGB getClosestMatch(VectorRGB color) {
    return colors.reduce((a, b) =>
    a.fastDifferenceTo(color) < b.fastDifferenceTo(color) ? a : b);
  }
}

class VectorRGB {
  int r, g, b;

  VectorRGB(this.r, this.g, this.b);

  @override
  String toString() => 'r: $r, g: $g, b: $b';

  factory VectorRGB.fromColor(Color color) =>
      VectorRGB(color.red, color.green, color.blue);

  factory VectorRGB.fromImgColor(img.Color color) =>
      VectorRGB(color.r.toInt(), color.g.toInt(), color.b.toInt());

  img.Color toImgColor() => img.ColorRgb8(r, g, b);

  VectorRGB subtract(VectorRGB other) =>
      VectorRGB(r - other.r, g - other.g, b - other.b);

  VectorRGB add(VectorRGB other) =>
      VectorRGB(r + other.r, g + other.g, b + other.b);

  int fastDifferenceTo(VectorRGB other) {
    VectorRGB diff = subtract(other);
    return diff.r.abs() + diff.g.abs() + diff.b.abs();
  }

  VectorRGB scalarMultiply(double scalar) => VectorRGB(
    (r * scalar).toInt(),
    (g * scalar).toInt(),
    (b * scalar).toInt(),
  );

  VectorRGB clip(int min, int max) => VectorRGB(
    r.clamp(min, max),
    g.clamp(min, max),
    b.clamp(min, max),
  );
}

class Ditherer {
  final ColorPalette palette;

  Ditherer(this.palette);

  void dither(img.Image imgData) {
    for (int y = 0; y < imgData.height; y++) {
      for (int x = 0; x < imgData.width; x++) {
        VectorRGB currentColor = VectorRGB.fromImgColor(imgData.getPixel(x, y));
        VectorRGB closestMatch = palette.getClosestMatch(currentColor);
        VectorRGB error = currentColor.subtract(closestMatch);
        imgData.setPixel(x, y, closestMatch.toImgColor());

        _applyError(imgData, x + 1, y, error, 7 / 16);
        _applyError(imgData, x + 1, y + 1, error, 1 / 16);
        _applyError(imgData, x, y + 1, error, 3 / 16);
        _applyError(imgData, x - 1, y + 1, error, 5 / 16);
      }
    }
  }

  void _applyError(img.Image imgData, int x, int y, VectorRGB error, double factor) {
    if (x >= 0 && x < imgData.width && y >= 0 && y < imgData.height) {
      VectorRGB newColor = VectorRGB.fromImgColor(imgData.getPixel(x, y))
          .add(error.scalarMultiply(factor))
          .clip(0, 255);
      imgData.setPixel(x, y, newColor.toImgColor());
    }
  }
}



