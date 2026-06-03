import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/calligraphy_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/calligraphy_canvas.dart';

class CompletionScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const CompletionScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final calliProvider = Provider.of<CalligraphyProvider>(context);
    final selected = calliProvider.selectedCharacter;

    final metadataItems = [
      {"label": "Mã lượt", "value": "CB-001"},
      {"label": "Chữ đã viết", "value": selected.char},
      {"label": "Trạng thái", "value": "Hoàn thành"},
      {"label": "Thời gian", "value": "09:30"},
    ];

    Widget buildMetaColumn(Map<String, String> item) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item["label"]!.toUpperCase(),
            style: const TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.bold,
              color: AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            item["value"]!,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
        ],
      );
    }

    return CustomCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Main layout content
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 36.0,
            ),
            child: Column(
              children: [
                // Huge Checked Success Circle Badge
                Container(
                  height: 72.0,
                  width: 72.0,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 38.0,
                  ),
                ),
                const SizedBox(height: 20.0),
                const Text(
                  "Robot đã hoàn thành",
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Chữ thư pháp của bạn đã được viết xong",
                  style: TextStyle(fontSize: 14.0, color: AppColors.muted),
                ),
                const SizedBox(height: 28.0),

                // Display calligraphy scroll result card
                SizedBox(
                  width: 320.0,
                  child: CustomCard(
                    padding: const EdgeInsets.all(20.0),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    child: Column(
                      children: [
                        CalligraphyCanvas(
                          char: selected.char,
                          fontSize: 160.0,
                          height: 260.0,
                          showDecorativeBorder: false,
                        ),
                        const SizedBox(height: 12.0),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.muted,
                            ),
                            children: [
                              TextSpan(
                                text: selected.char,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const TextSpan(text: " — "),
                              TextSpan(text: selected.meaning),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Greeting bottom note
                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 13.0,
                      color: AppColors.secondaryText,
                      height: 1.3,
                    ),
                    children: [
                      TextSpan(text: "Cảm ơn bạn đã tham gia trải nghiệm "),
                      TextSpan(
                        text: "Robot Ông Đồ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(text: " tại ngày hội tuyển sinh."),
                    ],
                  ),
                ),
                const SizedBox(height: 28.0),

                // CTA Action Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => onNavigate(0),
                      icon: const Icon(Icons.refresh_rounded, size: 16.0),
                      label: const Text(
                        "Chọn chữ khác",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppStyles.radiusMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14.0),
                    OutlinedButton.icon(
                      onPressed: () => onNavigate(0),
                      icon: const Icon(Icons.home_outlined, size: 16.0),
                      label: const Text(
                        "Về trang chủ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppStyles.radiusMd,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Metadata bottom grid — use non-const BoxDecoration (radiusValue is not const)
          Container(
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(14.0),
                bottomRight: Radius.circular(14.0),
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: metadataItems.map(buildMetaColumn).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
