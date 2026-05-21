import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../providers/robot_stream_provider.dart';

class ProcessTimeline extends StatelessWidget {
  final RobotStreamProvider provider;

  const ProcessTimeline({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "QUY TRÌNH ROBOT",
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: AppColors.muted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 16.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.stepLabels.length,
          itemBuilder: (context, index) {
            final label = provider.stepLabels[index];
            final status = provider.getStepStatus(index);
            
            Color iconBg;
            Widget icon;
            String statusText;
            
            switch (status) {
              case WritingStepStatus.done:
                iconBg = AppColors.success;
                icon = const Icon(Icons.check, color: Colors.white, size: 14.0);
                statusText = "Hoàn thành";
                break;
              case WritingStepStatus.active:
                iconBg = AppColors.warning;
                icon = const _BlinkingDot();
                statusText = "Đang thực hiện";
                break;
              case WritingStepStatus.pending:
                iconBg = AppColors.secondary;
                icon = Text(
                  "${index + 1}",
                  style: const TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondaryText,
                  ),
                );
                statusText = "Chờ xử lý";
                break;
            }

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline Node circle & line
                  Column(
                    children: [
                      Container(
                        height: 26.0,
                        width: 26.0,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: icon,
                      ),
                      if (index != provider.stepLabels.length - 1)
                        Expanded(
                          child: Container(
                            width: 2.0,
                            color: AppColors.border,
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14.0),
                  
                  // Label details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontWeight: status == WritingStepStatus.active ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13.0,
                              color: status == WritingStepStatus.active ? AppColors.primary : AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 11.0,
                              color: status == WritingStepStatus.active ? AppColors.warning : AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
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
      opacity: _controller,
      child: Container(
        height: 6.0,
        width: 6.0,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
