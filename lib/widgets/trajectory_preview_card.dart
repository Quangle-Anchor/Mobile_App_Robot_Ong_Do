import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'custom_card.dart';

class TrajectoryPreviewCard extends StatelessWidget {
  final Map<String, dynamic> result;
  static const double _fallbackPaperWidthMm = 199.053;
  static const double _fallbackPaperHeightMm = 263.069;

  const TrajectoryPreviewCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final strokeCount = result['stroke_count'];
    final poses = result['poses'];
    final poseCount =
        result['pose_count'] ?? (poses is List ? poses.length : null);
    final plannedPoseCount = result['planned_pose_count'];
    final motionMode = result['motion_mode'];
    final fontFamily = result['font_family'];
    final textMode = result['text_mode'];
    final hasPoses = poses is List && poses.isNotEmpty;
    final paperWidth =
        _readDouble(result, ['paper_width', 'paper_width_mm', 'width_mm']) ??
        _fallbackPaperWidthMm;
    final paperHeight =
        _readDouble(result, ['paper_height', 'paper_height_mm', 'height_mm']) ??
        _fallbackPaperHeightMm;

    return CustomCard(
      backgroundColor: AppColors.secondary.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Preview đường chạy',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12.0),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520.0),
              child: AspectRatio(
                aspectRatio: paperWidth / paperHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: AppStyles.radiusSm,
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppStyles.cardShadow,
                  ),
                  child: CustomPaint(
                    painter: _PosePreviewPainter(
                      poses,
                      paperWidthMm: paperWidth,
                      paperHeightMm: paperHeight,
                    ),
                    child: hasPoses
                        ? const SizedBox.expand()
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(
                                'Không có dữ liệu pose để vẽ preview',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14.0),
          Wrap(
            spacing: 24.0,
            runSpacing: 10.0,
            children: [
              _ResultMetric('Số nét', strokeCount),
              _ResultMetric('Số pose', poseCount),
              _ResultMetric('Pose dự kiến', plannedPoseCount),
              _ResultMetric('Motion mode', motionMode),
              _ResultMetric('Font', fontFamily),
              _ResultMetric('Kiểu chữ', textMode),
              _ResultMetric(
                'Khổ giấy',
                '${paperWidth.toStringAsFixed(1)} x ${paperHeight.toStringAsFixed(1)} mm',
              ),
            ],
          ),
        ],
      ),
    );
  }

  double? _readDouble(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }
}

class _ResultMetric extends StatelessWidget {
  final String label;
  final Object? value;

  const _ResultMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(fontSize: 11.0, color: AppColors.muted)),
        const SizedBox(height: 3.0),
        Text(
          value?.toString() ?? '-',
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }
}

class _PosePreviewPainter extends CustomPainter {
  final Object? poses;
  final double paperWidthMm;
  final double paperHeightMm;

  const _PosePreviewPainter(
    this.poses, {
    required this.paperWidthMm,
    required this.paperHeightMm,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawPaperGuides(canvas, size);

    final points = _parsePoints();
    if (points.length < 2) return;

    final minX = points.map((point) => point.dx).reduce(math.min);
    final maxX = points.map((point) => point.dx).reduce(math.max);
    final minY = points.map((point) => point.dy).reduce(math.min);
    final maxY = points.map((point) => point.dy).reduce(math.max);

    const padding = 18.0;
    final drawableWidth = math.max(size.width - padding * 2, 1.0);
    final drawableHeight = math.max(size.height - padding * 2, 1.0);
    final usesPaperCoordinates =
        minX >= 0 && minY >= 0 && maxX <= paperWidthMm && maxY <= paperHeightMm;
    final originX = usesPaperCoordinates ? 0.0 : minX;
    final originY = usesPaperCoordinates ? 0.0 : minY;
    final spanX = usesPaperCoordinates
        ? math.max(paperWidthMm, 1.0)
        : math.max(maxX - minX, 1.0);
    final spanY = usesPaperCoordinates
        ? math.max(paperHeightMm, 1.0)
        : math.max(maxY - minY, 1.0);
    final scale = math.min(drawableWidth / spanX, drawableHeight / spanY);
    final offsetX = (drawableWidth - spanX * scale) / 2;
    final offsetY = (drawableHeight - spanY * scale) / 2;

    Offset project(Offset point) {
      return Offset(
        padding + offsetX + (point.dx - originX) * scale,
        size.height - padding - offsetY - (point.dy - originY) * scale,
      );
    }

    final firstPoint = project(points.first);
    final path = Path()..moveTo(firstPoint.dx, firstPoint.dy);
    for (final point in points.skip(1)) {
      final projected = project(point);
      path.lineTo(projected.dx, projected.dy);
    }

    final shadowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final pathPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, pathPaint);
    canvas.drawCircle(firstPoint, 4.5, Paint()..color = AppColors.success);
    canvas.drawCircle(
      project(points.last),
      4.5,
      Paint()..color = AppColors.destructive,
    );
  }

  void _drawPaperGuides(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.55)
      ..strokeWidth = 1.0;
    final centerPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.18)
      ..strokeWidth = 1.0;

    for (var i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      final y = size.height * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  List<Offset> _parsePoints() {
    final rawPoses = poses;
    if (rawPoses is! List) return const [];

    final points = <Offset>[];
    for (final pose in rawPoses) {
      if (pose is! List || pose.length < 2) continue;
      final x = _toDouble(pose[0]);
      final y = _toDouble(pose[1]);
      if (x == null || y == null) continue;
      points.add(Offset(x, y));
    }
    return points;
  }

  double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  bool shouldRepaint(covariant _PosePreviewPainter oldDelegate) {
    return oldDelegate.poses != poses ||
        oldDelegate.paperWidthMm != paperWidthMm ||
        oldDelegate.paperHeightMm != paperHeightMm;
  }
}
