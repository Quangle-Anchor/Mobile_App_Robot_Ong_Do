import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/robot_stream_provider.dart';
import '../../../widgets/status_badge.dart';

class DiagnosticsTable extends StatelessWidget {
  final RobotStreamProvider provider;

  const DiagnosticsTable({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final activeStep = provider.activeStepIndex;
    final isWriting = activeStep != -1;

    final diagnosticItems = [
      {
        "label": "Trạng thái robot",
        "value": isWriting ? "Đang viết" : "Chờ lệnh",
        "isBadge": true
      },
      {
        "label": "Kết nối",
        "value": provider.isConnected ? "Đã kết nối" : "Ngoại tuyến",
        "isBadge": true
      },
      {
        "label": "Bút thư pháp",
        "value": "Sẵn sàng",
        "isBadge": true
      },
      {
        "label": "Giấy",
        "value": provider.isPaperPresent ? "Đã đặt" : "Trống",
        "isBadge": true
      },
      {
        "label": "Mực",
        "value": provider.inkLevel > 0.15 ? "Đủ" : "Yêu cầu bơm mực",
        "isBadge": true
      },
    ];

    Widget buildRow(Map<String, dynamic> item) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item["label"] as String,
              style: TextStyle(
                fontSize: 13.0,
                color: AppColors.muted,
              ),
            ),
            StatusBadge(status: item["value"] as String),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "TRẠNG THÁI PHẦN CỨNG",
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: AppColors.muted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12.0),
        Column(
          children: diagnosticItems.map(buildRow).toList(),
        ),
      ],
    );
  }
}
