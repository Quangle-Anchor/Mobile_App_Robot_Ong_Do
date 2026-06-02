import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../providers/calligraphy_provider.dart';
import '../../providers/robot_stream_provider.dart';
import 'widgets/hero_banner.dart';
import 'widgets/process_steps.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final calliProvider = Provider.of<CalligraphyProvider>(context);
    final robotProvider = Provider.of<RobotStreamProvider>(context);

    final activeChars = calliProvider.activeCharacters;
    final selected = calliProvider.selectedCharacter;

    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width >= 1024 ? 4 : (width >= 600 ? 3 : 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroBanner(eventName: robotProvider.eventName),
        const SizedBox(height: 32.0),

        // Character grid heading — fix Alignment.end → CrossAxisAlignment.end
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end, // was Alignment.end (wrong type)
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chọn một chữ thư pháp",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Nhấn vào một chữ bên dưới để chọn — chỉ một chữ duy nhất mỗi lượt.",
                  style: TextStyle(fontSize: 13.0, color: AppColors.muted),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: AppStyles.radiusSm,
                  ),
                  child: Text(
                    "Đã chọn: ${selected.char}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12.0),
                ElevatedButton(
                  onPressed: () => onNavigate(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
                    elevation: 2.0,
                  ),
                  child: const Row(
                    children: [
                      Text(
                        "Xác nhận",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.0),
                      ),
                      SizedBox(width: 6.0),
                      Icon(Icons.arrow_forward, size: 14.0),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20.0),

        // Grid View of Calligraphy Characters
        if (activeChars.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                "Không có chữ nào khả dụng. Hãy bật chữ trong Cài đặt.",
                style: TextStyle(color: AppColors.muted),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 18.0,
              mainAxisSpacing: 18.0,
              childAspectRatio: 0.72,
            ),
            itemCount: activeChars.length,
            itemBuilder: (context, index) {
              final item = activeChars[index];
              final isSelected = item.char == selected.char;

              return InkWell(
                onTap: () => calliProvider.selectCharacter(item),
                borderRadius: AppStyles.radiusXl,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppStyles.radiusXl,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.25),
                              offset: const Offset(0, 4),
                              blurRadius: 12.0,
                              spreadRadius: 2.0,
                            )
                          ]
                        : AppStyles.cardShadow,
                  ),
                  child: Stack(
                    children: [
                      if (isSelected)
                        const Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: Icon(Icons.check_circle, color: AppColors.primary, size: 24.0),
                        ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0), // py → vertical
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: const Text(
                              "MỘT CHỮ",
                              style: TextStyle(
                                fontSize: 8.0,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8F6B1E),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: AppStyles.radiusMd,
                                border: Border.all(color: AppColors.border, width: 1.0),
                              ),
                              alignment: Alignment.center,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item.char,
                                    textAlign: TextAlign.center,
                                    style: AppStyles.calligraphyStyle.copyWith(
                                      fontSize: 54.0,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12.0),

                          Text(
                            item.char,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            item.meaning,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11.0, color: AppColors.muted, height: 1.3),
                          ),
                          const SizedBox(height: 12.0),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.secondary,
                              borderRadius: AppStyles.radiusSm,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              isSelected ? "Đã chọn" : "Chọn chữ này",
                              style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        const SizedBox(height: 24.0),

      ],
    );
  }
}
