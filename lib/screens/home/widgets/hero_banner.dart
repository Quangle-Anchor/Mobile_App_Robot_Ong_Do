import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';

class HeroBanner extends StatelessWidget {
  final String eventName;

  const HeroBanner({super.key, required this.eventName});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: AppStyles.radius2xl,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Color(0xFF3B0B14)],
        ),
        boxShadow: AppStyles.cardShadow,
      ),
      padding: const EdgeInsets.all(28.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sparkles / Event announcement badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 6.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: AppColors.gold, size: 14.0),
                    const SizedBox(width: 6.0),
                    Text(
                      "$eventName · Khu trải nghiệm Robot Ông Đồ",
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              const Text(
                "Trải nghiệm Robot Viết Thư Pháp",
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8.0),

              // Fix: Colors.white84 not valid — use Color with opacity
              Text(
                "Chọn một chữ ý nghĩa, robot sẽ viết thư pháp dành tặng bạn.",
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white.withValues(alpha: 0.84),
                ),
              ),
              const SizedBox(height: 20.0),

              // Helpful tip box
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.95),
                  borderRadius: AppStyles.radiusSm,
                ),
                child: Row(
                  // removed unnecessary const
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.info, color: AppColors.ink, size: 16.0),
                    SizedBox(width: 8.0),
                    Text(
                      "Mỗi lượt chỉ chọn 1 chữ. Robot sẽ viết đúng chữ bạn đã chọn.",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          // Decorative Calligraphy Scroll Mockup
          final scrollMock = Container(
            height: 180.0,
            width: 240.0,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: AppStyles.radiusLg,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppStyles.radiusMd,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    "書",
                    style: TextStyle(
                      fontFamily: 'Georgia',
                      fontSize: 90.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Positioned(
                  top: 18.0,
                  right: 18.0,
                  child: Container(
                    height: 38.0,
                    width: 38.0,
                    decoration: BoxDecoration(
                      color: AppColors.sidebar.withValues(alpha: 0.9),
                      borderRadius: AppStyles.radiusSm,
                      boxShadow: AppStyles.cardShadow,
                    ),
                    child: const Icon(
                      Icons.brush,
                      color: Colors.white,
                      size: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          );

          if (isDesktop && constraints.maxWidth > 700) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: content),
                const SizedBox(width: 24.0),
                scrollMock,
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [content, const SizedBox(height: 20.0), scrollMock],
          );
        },
      ),
    );
  }
}
