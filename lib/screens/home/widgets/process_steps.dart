import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';

class ProcessSteps extends StatelessWidget {
  const ProcessSteps({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final steps = [
      {"num": "1", "title": "Chọn một chữ", "desc": "Sinh viên chọn 1 chữ thư pháp."},
      {"num": "2", "title": "Xác nhận lựa chọn", "desc": "Kiểm tra và xác nhận."},
      {"num": "3", "title": "Robot viết thư pháp", "desc": "Robot thực hiện viết."},
      {"num": "4", "title": "Nhận thành phẩm", "desc": "Nhận tờ giấy thư pháp."},
    ];

    Widget buildStep(Map<String, String> step) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38.0,
            width: 38.0,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step["num"]!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                fontSize: 14.0,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step["title"]!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 3.0),
                Text(
                  step["desc"]!,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          )
        ],
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppStyles.radiusXl,
        border: Border.all(color: AppColors.border, width: 1.0),
        boxShadow: AppStyles.cardShadow,
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "QUY TRÌNH TRẢI NGHIỆM",
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16.0),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: steps.map((s) => Expanded(child: buildStep(s))).toList(),
            )
          else
            Column(
              children: steps
                  .map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: buildStep(s),
                      ))
                  .toList(),
            )
        ],
      ),
    );
  }
}
