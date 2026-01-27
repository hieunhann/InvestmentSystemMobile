import 'package:flutter/material.dart';

/// Class cấu hình kích thước responsive
/// Sử dụng design reference để tính toán tỷ lệ
class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;

  // Design reference (iPhone 11 Pro: 375 x 812)
  static const double designWidth = 375;
  static const double designHeight = 812;

  /// Khởi tạo SizeConfig
  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    // Tính toán block size (1% của màn hình)
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    // Tính toán safe area
    safeAreaHorizontal =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    // Tính toán safe block size
    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;
  }

  /// Tính toán chiều rộng responsive dựa trên design width
  static double getProportionateScreenWidth(double inputWidth) {
    return (inputWidth / designWidth) * screenWidth;
  }

  /// Tính toán chiều cao responsive dựa trên design height
  static double getProportionateScreenHeight(double inputHeight) {
    return (inputHeight / designHeight) * screenHeight;
  }

  /// Lấy text scale factor
  static double get textScaleFactor => _mediaQueryData.textScaleFactor;

  /// Lấy orientation
  static Orientation get orientation => _mediaQueryData.orientation;

  /// Kiểm tra landscape mode
  static bool get isLandscape => orientation == Orientation.landscape;

  /// Kiểm tra portrait mode
  static bool get isPortrait => orientation == Orientation.portrait;
}

/// Extension cho số để dễ dàng sử dụng responsive sizing
extension ResponsiveSize on num {
  /// Chiều rộng responsive
  double get w => SizeConfig.getProportionateScreenWidth(toDouble());

  /// Chiều cao responsive
  double get h => SizeConfig.getProportionateScreenHeight(toDouble());

  /// Font size responsive (dựa trên chiều rộng)
  double get sp => SizeConfig.getProportionateScreenWidth(toDouble());
}
