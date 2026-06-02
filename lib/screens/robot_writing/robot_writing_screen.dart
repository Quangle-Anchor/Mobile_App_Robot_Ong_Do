import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_styles.dart';
import '../../providers/calligraphy_provider.dart';
import '../../providers/robot_stream_provider.dart';
import '../../providers/history_provider.dart';
import '../../widgets/custom_card.dart';
import 'widgets/process_timeline.dart';
import 'widgets/diagnostics_table.dart';

class RobotWritingScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const RobotWritingScreen({super.key, required this.onNavigate});

  @override
  State<RobotWritingScreen> createState() => _RobotWritingScreenState();
}

class _RobotWritingScreenState extends State<RobotWritingScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;

      final calliProvider = Provider.of<CalligraphyProvider>(context, listen: false);
      final robotProvider = Provider.of<RobotStreamProvider>(context, listen: false);
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        robotProvider.triggerWriteSequence(calliProvider.selectedCharacter, () {
          historyProvider.addLog(
            calliProvider.selectedCharacter.char,
            calliProvider.selectedCharacter.meaning,
            "Hoàn thành",
          );
          widget.onNavigate(3);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final calliProvider = Provider.of<CalligraphyProvider>(context);
    final robotProvider = Provider.of<RobotStreamProvider>(context);
    // Declare historyProvider here so it is in scope for all buttons below
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

    final selected = calliProvider.selectedCharacter;
    final isDesktop = MediaQuery.of(context).size.width >= 992;

    final progressPercent = (robotProvider.drawingProgress * 100).toInt();

    // Canvas Writing board
    final writingCard = CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Robot đang viết",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2.0),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13.0, color: AppColors.muted),
                      children: [
                        const TextSpan(text: "Robot đang viết chữ "),
                        TextSpan(
                          text: selected.char,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const TextSpan(text: " trên giấy thư pháp"),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0), // py → vertical
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100.0),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3), width: 1.0),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      height: 10.0,
                      width: 10.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      "Đang viết",
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.warning),
                    )
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20.0),

          // Writing simulation canvas
          Container(
            height: 240.0,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: AppStyles.radiusLg,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2.0),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 12.0,
                  left: 12.0,
                  child: Text(
                    "GIẤY THƯ PHÁP",
                    style: TextStyle(fontSize: 9.0, fontWeight: FontWeight.bold, color: AppColors.muted),
                  ),
                ),

                // Simulated brush contact coordinate tip pulser dot
                Positioned(
                  right: 40.0,
                  top: 50.0,
                  child: Container(
                    height: 12.0,
                    width: 12.0,
                    decoration: const BoxDecoration(
                      color: AppColors.tech,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),

                Center(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        selected.char,
                        textAlign: TextAlign.center,
                        style: AppStyles.calligraphyStyle.copyWith(
                          fontSize: 160.0,
                          height: 1.0,
                          // Darkens as progress increases — withValues replaces withOpacity
                          color: AppColors.ink.withValues(alpha: 0.1 + (robotProvider.drawingProgress * 0.9)),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12.0),

          // Linear progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tiến độ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text(
                "$progressPercent%",
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14.5),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: AppStyles.radiusSm,
            child: LinearProgressIndicator(
              value: robotProvider.drawingProgress,
              minHeight: 12.0,
              backgroundColor: AppColors.secondary,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 12.0),

          Row(
            children: [
              Icon(Icons.access_time, size: 16.0, color: AppColors.muted),
              const SizedBox(width: 6.0),
              Text(
                "Thời gian còn lại: ",
                style: TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
              Text(
                "${((1.0 - robotProvider.drawingProgress) * 45).toInt()} giây",
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Status message từ API
          if (robotProvider.statusMessage.isNotEmpty) ...[  
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.5),
                borderRadius: AppStyles.radiusSm,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 14.0, color: AppColors.muted),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      robotProvider.statusMessage,
                      style: TextStyle(fontSize: 12.0, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],

          // Writing controllers
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: robotProvider.activeStepIndex != -1
                    ? () => robotProvider.pauseWrite()
                    : null,
                icon: const Icon(Icons.pause, size: 16.0),
                label: const Text('Tạm dừng'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppStyles.radiusMd),
                ),
              ),
              const SizedBox(width: 12.0),
              OutlinedButton.icon(
                onPressed: () {
                  robotProvider.stopEmergency();
                  historyProvider.addLog(
                      selected.char, selected.meaning, 'Đã hủy');
                  widget.onNavigate(0);
                },
                icon: const Icon(Icons.stop_circle_outlined, size: 16.0),
                label: const Text('Dừng khẩn cấp'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.destructive,
                  side: const BorderSide(color: AppColors.destructive),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 14.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppStyles.radiusMd),
                ),
              ),
            ],
          )
        ],
      ),
    );

    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: writingCard),
              const SizedBox(width: 24.0),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    CustomCard(child: ProcessTimeline(provider: robotProvider)),
                    const SizedBox(height: 24.0),
                    CustomCard(child: DiagnosticsTable(provider: robotProvider)),
                  ],
                ),
              )
            ],
          )
        else
          Column(
            children: [
              writingCard,
              const SizedBox(height: 24.0),
              CustomCard(child: ProcessTimeline(provider: robotProvider)),
              const SizedBox(height: 24.0),
              CustomCard(child: DiagnosticsTable(provider: robotProvider)),
            ],
          ),
      ],
    );
  }
}
