import 'package:flutter/material.dart';

/// Utility class cho responsive design
/// Cung cấp các phương thức để xác định loại thiết bị và breakpoints
class ResponsiveUtils {
  // Breakpoints chuẩn
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Kiểm tra xem thiết bị có phải là mobile không
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  /// Kiểm tra xem thiết bị có phải là tablet không
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  /// Kiểm tra xem thiết bị có phải là desktop không
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  /// Lấy chiều rộng màn hình
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Lấy chiều cao màn hình
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Tính toán chiều rộng theo phần trăm
  static double widthPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * (percent / 100);
  }

  /// Tính toán chiều cao theo phần trăm
  static double heightPercent(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * (percent / 100);
  }

  /// Lấy orientation của màn hình
  static Orientation orientation(BuildContext context) {
    return MediaQuery.of(context).orientation;
  }

  /// Kiểm tra xem màn hình có đang ở chế độ landscape không
  static bool isLandscape(BuildContext context) {
    return orientation(context) == Orientation.landscape;
  }

  /// Kiểm tra xem màn hình có đang ở chế độ portrait không
  static bool isPortrait(BuildContext context) {
    return orientation(context) == Orientation.portrait;
  }

  /// Lấy padding an toàn (safe area) của màn hình
  static EdgeInsets safeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Lấy device pixel ratio
  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }
}

/// Widget responsive builder
/// Tự động chọn layout phù hợp dựa trên kích thước màn hình
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveUtils.desktopBreakpoint) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveUtils.mobileBreakpoint) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Widget để xây dựng UI responsive với constraints
class ResponsiveLayoutBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
  builder;

  const ResponsiveLayoutBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: builder);
  }
}
