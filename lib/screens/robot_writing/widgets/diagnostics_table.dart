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
        "label": "Robot IP",
        "value": provider.robotIp,
        "isBadge": false
      },
      {
        "label": "TCP X/Y/Z",
        "value": provider.tcpPose.length >= 3
            ? "${(provider.tcpPose[0] as num).toStringAsFixed(0)}/"
              "${(provider.tcpPose[1] as num).toStringAsFixed(0)}/"
              "${(provider.tcpPose[2] as num).toStringAsFixed(0)} mm"
            : "—",
        "isBadge": false
      },
      {
        "label": "Bước hiện tại",
        "value": provider.activeStepIndex >= 0 &&
                provider.activeStepIndex < provider.stepLabels.length
            ? provider.stepLabels[provider.activeStepIndex]
            : "Chờ lệnh",
        "isBadge": true
      },
    ];

    Widget buildRow(Map<String, dynamic> item) {
      final isBadge = item["isBadge"] as bool;
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
            isBadge
                ? StatusBadge(status: item["value"] as String)
                : Text(
                    item["value"] as String,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
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
