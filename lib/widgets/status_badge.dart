import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool showPulse;

  const StatusBadge({
    super.key,
    required this.status,
    this.showPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color border;

    switch (status) {
      case "Hoàn thành":
      case "Đã kết nối":
      case "Sẵn sàng":
      case "Đủ":
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        border = AppColors.success.withValues(alpha: 0.3);
        break;
      case "Đang viết":
      case "Đang thực hiện":
      case "Chờ xử lý":
      case "Tự động":
        bg = AppColors.warning.withValues(alpha: 0.12);
        fg = AppColors.warning;
        border = AppColors.warning.withValues(alpha: 0.3);
        break;
      case "Lỗi":
      case "Đã hủy":
        bg = AppColors.destructive.withValues(alpha: 0.12);
        fg = AppColors.destructive;
        border = AppColors.destructive.withValues(alpha: 0.3);
        break;
      default:
        bg = AppColors.secondary;
        fg = AppColors.secondaryText;
        border = AppColors.border;
    }

    final isPulse = showPulse || status == "Đang viết" || status == "Đang thực hiện";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppStyles.radiusSm,
        border: Border.all(color: border, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPulse) ...[
            _PulseDot(color: fg),
            const SizedBox(width: 6.0),
          ],
          Text(
            status,
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  final Color color;

  const _PulseDot({required this.color});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_controller),
      child: Container(
        height: 7.0,
        width: 7.0,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
