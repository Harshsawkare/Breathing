import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';

/// Full-screen gradient background with theme-specific overlay images placed
/// by name (topLarge, topSmall, midLeft, midRight, bottomLeft, bottomRight;
/// dark theme also has Stars). Overlays sit above the background but behind
/// [child]. Positions and sizes scale with screen size for mobile and web.
class BackgroundWithOverlays extends StatelessWidget {
  const BackgroundWithOverlays({
    super.key,
    required this.isDark,
    required this.child,
  });

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base background (gradient on all platforms)
        Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppColors.webBackgroundGradientDark
                : AppColors.webBackgroundGradientLight,
          ),
        ),
        // Overlay images (positioned by name, responsive)
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            return _OverlayLayer(
              isDark: isDark,
              width: w,
              height: h,
            );
          },
        ),
        child,
      ],
    );
  }
}

class _OverlayLayer extends StatelessWidget {
  const _OverlayLayer({
    required this.isDark,
    required this.width,
    required this.height,
  });

  final bool isDark;
  final double width;
  final double height;

  /// Scale overlay size with screen; use a fraction of the shorter dimension.
  double get _sizeBase => width < height ? width : height;

  /// Top overlays sit slightly below the top edge.
  double get _topOffset => 0.045 * _sizeBase;
  /// Bottom overlays sit slightly above the bottom edge.
  double get _bottomOffset => 0.06 * _sizeBase;

  @override
  Widget build(BuildContext context) {
    if (isDark) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _stars(),
          _positioned(AppAssets.darkTopLarge, 0.65 * _sizeBase, 0.22 * _sizeBase, Alignment.topCenter),
          _positioned(AppAssets.darkTopSmall, 0.28 * _sizeBase, 0.12 * _sizeBase, Alignment.topRight),
          _positioned(AppAssets.darkMidLeft, 0.35 * _sizeBase, 0.2 * _sizeBase, Alignment.centerLeft),
          _positioned(AppAssets.darkMidRight, 0.32 * _sizeBase, 0.18 * _sizeBase, Alignment.centerRight),
          _positioned(AppAssets.darkBottomLeft, 0.4 * _sizeBase, 0.2 * _sizeBase, Alignment.bottomLeft),
          _positioned(AppAssets.darkBottomRight, 0.38 * _sizeBase, 0.19 * _sizeBase, Alignment.bottomRight),
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        _positioned(AppAssets.lightTopLarge, 0.65 * _sizeBase, 0.22 * _sizeBase, Alignment.topCenter),
        _positioned(AppAssets.lightTopLeft, 0.32 * _sizeBase, 0.14 * _sizeBase, Alignment.topLeft, topOffsetAdd: 0.05 * _sizeBase),
        _positioned(AppAssets.lightTopSmall, 0.28 * _sizeBase, 0.12 * _sizeBase, Alignment.topRight),
        _positioned(AppAssets.lightMidLeft, 0.35 * _sizeBase, 0.2 * _sizeBase, Alignment.centerLeft),
        _positioned(AppAssets.lightMidRight, 0.32 * _sizeBase, 0.18 * _sizeBase, Alignment.centerRight),
        _positioned(AppAssets.lightBottomLeft, 0.4 * _sizeBase, 0.2 * _sizeBase, Alignment.bottomLeft),
        _positioned(AppAssets.lightBottomRight, 0.38 * _sizeBase, 0.19 * _sizeBase, Alignment.bottomRight),
      ],
    );
  }

  Widget _stars() {
    return Positioned.fill(
      child: Image.asset(
        AppAssets.darkStars,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _positioned(
    String asset,
    double w,
    double h,
    Alignment alignment, {
    double topOffsetAdd = 0,
  }) {
    double left;
    double top;
    final topY = _topOffset + topOffsetAdd;
    if (alignment == Alignment.topCenter) {
      left = (width - w) / 2;
      top = topY;
    } else if (alignment == Alignment.topLeft) {
      left = 0;
      top = topY;
    } else if (alignment == Alignment.topRight) {
      left = width - w;
      top = topY;
    } else if (alignment == Alignment.centerLeft) {
      left = 0;
      top = (height - h) / 2;
    } else if (alignment == Alignment.centerRight) {
      left = width - w;
      top = (height - h) / 2;
    } else if (alignment == Alignment.bottomLeft) {
      left = 0;
      top = height - h - _bottomOffset;
    } else if (alignment == Alignment.bottomRight) {
      left = width - w;
      top = height - h - _bottomOffset;
    } else {
      left = (width - w) / 2;
      top = (height - h) / 2;
    }
    return Positioned(
      left: left,
      top: top,
      width: w,
      height: h,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
      ),
    );
  }
}
