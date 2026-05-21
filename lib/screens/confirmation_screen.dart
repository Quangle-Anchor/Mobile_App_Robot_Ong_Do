import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/calligraphy_provider.dart';
import '../providers/robot_stream_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/calligraphy_canvas.dart';

class ConfirmationScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const ConfirmationScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final calliProvider = Provider.of<CalligraphyProvider>(context);
    final robotProvider = Provider.of<RobotStreamProvider>(context);

    final selected = calliProvider.selectedCharacter;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    // Calligraphy Canvas preview panel
    final previewPanel = CustomCard(
      padding: const EdgeInsets.all(24.0),
      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.5),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CHỮ ĐÃ CHỌN",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0), // py → vertical
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: const Text(
                  "MỘT CHỮ DUY NHẤT",
                  style: TextStyle(
                    fontSize: 8.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8F6B1E),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16.0),
          CalligraphyCanvas(
            char: selected.char,
            fontSize: 160.0,
            height: 280.0,
            showDecorativeBorder: false,
          ),
          const SizedBox(height: 16.0),
          Text(
            selected.char,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          )
        ],
      ),
    );

    // Detail explanations panel
    final detailsPanel = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "BẠN ĐÃ CHỌN CHỮ",
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: AppColors.muted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          selected.char,
          style: const TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20.0),

        // Meaning panel
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.6),
            borderRadius: AppStyles.radiusMd,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Ý NGHĨA",
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryText,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                selected.meaning,
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppColors.ink,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        // Warning alert box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.08),
            borderRadius: AppStyles.radiusMd,
            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.0),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20.0),
              const SizedBox(width: 12.0),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 12.5, color: AppColors.ink, height: 1.3),
                    children: [
                      TextSpan(text: "Sau khi xác nhận, robot sẽ bắt đầu viết chữ này. "),
                      TextSpan(
                        text: "Mỗi lượt chỉ viết một chữ duy nhất.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        // Robot live connection status box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14.0),
          decoration: BoxDecoration(
            color: AppColors.tech.withValues(alpha: 0.08),
            borderRadius: AppStyles.radiusMd,
            border: Border.all(color: AppColors.tech.withValues(alpha: 0.3), width: 1.0),
          ),
          child: Row(
            children: [
              Container(
                height: 38.0,
                width: 38.0,
                decoration: BoxDecoration(
                  color: AppColors.tech,
                  borderRadius: AppStyles.radiusSm,
                ),
                child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 20.0),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ROBOT HIỆN ĐANG",
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Container(
                          height: 7.0,
                          width: 7.0,
                          decoration: BoxDecoration(
                            color: robotProvider.isConnected ? AppColors.success : AppColors.destructive,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          robotProvider.isConnected ? "Sẵn sàng" : "Chưa kết nối",
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            color: robotProvider.isConnected ? AppColors.success : AppColors.destructive,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24.0),

        // Navigation triggers
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => onNavigate(0),
              icon: const Icon(Icons.arrow_back, size: 16.0),
              label: const Text("Chọn lại", style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryText,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: robotProvider.isConnected
                    ? () {
                        onNavigate(2);
                      }
                    : null,
                icon: const Icon(Icons.check_circle_outline, size: 18.0),
                label: const Text(
                  "Xác nhận cho robot viết",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 1.0,
                ),
              ),
            ),
          ],
        )
      ],
    );

    return CustomCard(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "XÁC NHẬN CHỮ THƯ PHÁP",
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 4.0),
          Text(
            "Kiểm tra lại lựa chọn của bạn trước khi robot bắt đầu viết.",
            style: TextStyle(fontSize: 13.0, color: AppColors.muted),
          ),
          const SizedBox(height: 24.0),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: previewPanel),
                const SizedBox(width: 28.0),
                Expanded(flex: 5, child: detailsPanel),
              ],
            )
          else
            Column(
              children: [
                previewPanel,
                const SizedBox(height: 24.0),
                detailsPanel,
              ],
            ),
        ],
      ),
    );
  }
}
