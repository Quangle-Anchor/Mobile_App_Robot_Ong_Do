import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/calligraphy_provider.dart';
import '../providers/robot_stream_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _eventNameController;
  late TextEditingController _locationController;
  late TextEditingController _boothController;
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      final robotProvider = Provider.of<RobotStreamProvider>(context, listen: false);
      _eventNameController = TextEditingController(text: robotProvider.eventName);
      _locationController = TextEditingController(text: robotProvider.eventLocation);
      _boothController = TextEditingController(text: robotProvider.eventBooth);
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _boothController.dispose();
    super.dispose();
  }

  Widget buildFieldRow(String key, Widget value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontSize: 13.0, color: AppColors.muted)),
          value,
        ],
      ),
    );
  }

  Widget buildTextInput(String label, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: AppColors.ink),
          ),
          const SizedBox(height: 6.0),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
              filled: true,
              fillColor: AppColors.secondary.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: AppStyles.radiusSm,
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppStyles.radiusSm,
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calliProvider = Provider.of<CalligraphyProvider>(context);
    final robotProvider = Provider.of<RobotStreamProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    final inkPercent = (robotProvider.inkLevel * 100).toInt();

    // Event Info Card Panel
    final eventCard = CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "THÔNG TIN SỰ KIỆN",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 0.8),
          ),
          const SizedBox(height: 16.0),
          buildTextInput("Tên sự kiện", _eventNameController),
          buildTextInput("Địa điểm", _locationController),
          buildTextInput("Tên booth", _boothController),
        ],
      ),
    );

    // Robot config diagnostics card
    final robotCard = CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CẤU HÌNH ROBOT",
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 0.8),
          ),
          const SizedBox(height: 16.0),
          buildFieldRow("Robot ID", Text(robotProvider.robotId, style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold))),
          buildFieldRow(
            "Trạng thái kết nối",
            StatusBadge(status: robotProvider.isConnected ? "Đã kết nối" : "Ngoại tuyến"),
          ),
          buildFieldRow("Chế độ", const StatusBadge(status: "Tự động")),
          buildFieldRow("Trạng thái bút", const StatusBadge(status: "Sẵn sàng")),
          const SizedBox(height: 12.0),
          
          // Ink levels slider diagnostics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Mức mực", style: TextStyle(fontSize: 13.0, color: AppColors.muted)),
              Text("$inkPercent%", style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: AppColors.ink)),
            ],
          ),
          const SizedBox(height: 8.0),
          ClipRRect(
            borderRadius: AppStyles.radiusSm,
            child: LinearProgressIndicator(
              value: robotProvider.inkLevel,
              minHeight: 8.0,
              backgroundColor: AppColors.secondary,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.tech),
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: robotProvider.refillInk,
                icon: const Icon(Icons.colorize_outlined, size: 14.0),
                label: const Text("Bơm mực", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: AppColors.tech),
              )
            ],
          )
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cài đặt hệ thống",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: AppColors.ink),
        ),
        const SizedBox(height: 2.0),
        Text(
          "Cấu hình sự kiện, robot và danh sách chữ.",
          style: TextStyle(fontSize: 13.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),
        
        // Split Event/Robot cards
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: eventCard),
              const SizedBox(width: 24.0),
              Expanded(child: robotCard),
            ],
          )
        else ...[
          eventCard,
          const SizedBox(height: 24.0),
          robotCard,
        ],
        const SizedBox(height: 24.0),
        
        // Active characters toggles pool
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DANH SÁCH CHỮ ĐANG BẬT",
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 0.8),
              ),
              const SizedBox(height: 16.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop ? 4 : (MediaQuery.of(context).size.width >= 540 ? 2 : 1),
                  crossAxisSpacing: 14.0,
                  mainAxisSpacing: 14.0,
                  childAspectRatio: 2.4,
                ),
                itemCount: calliProvider.charactersPool.length,
                itemBuilder: (context, index) {
                  final c = calliProvider.charactersPool[index];
                  final isEnabled = c.isEnabled;

                  return CustomCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                    backgroundColor: isEnabled ? AppColors.primary.withValues(alpha: 0.04) : AppColors.secondary.withValues(alpha: 0.4),
                    border: Border.all(
                      color: isEnabled ? AppColors.primary : AppColors.border,
                      width: isEnabled ? 1.5 : 1.0,
                    ),
                    onTap: () => calliProvider.toggleCharacter(c.char),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              c.char,
                              style: AppStyles.calligraphyStyle.copyWith(fontSize: 26.0, height: 1.1),
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              c.char,
                              style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: AppColors.ink),
                            )
                          ],
                        ),
                        
                        // Switch widget
                        Switch(
                          value: isEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.border,
                          onChanged: (bool value) {
                            calliProvider.toggleCharacter(c.char);
                          },
                        )
                      ],
                    ),
                  );
                },
              )
            ],
          ),
        ),
        const SizedBox(height: 24.0),
        
        // Settings Action buttons bottom row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                calliProvider.resetDefaults();
                _eventNameController.text = "Ngày hội tuyển sinh 2026";
                _locationController.text = "Sảnh chính";
                _boothController.text = "Khu trải nghiệm CalliBot";
                robotProvider.updateEventDetails(
                  name: "Ngày hội tuyển sinh 2026",
                  location: "Sảnh chính",
                  booth: "Khu trải nghiệm CalliBot",
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã khôi phục cài đặt mặc định")),
                );
              },
              icon: const Icon(Icons.restore, size: 16.0),
              label: const Text("Khôi phục mặc định"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryText,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
              ),
            ),
            const SizedBox(width: 12.0),
            ElevatedButton.icon(
              onPressed: () {
                robotProvider.updateEventDetails(
                  name: _eventNameController.text,
                  location: _locationController.text,
                  booth: _boothController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã lưu các cài đặt thành công")),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 16.0),
              label: const Text("Lưu cài đặt", style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
              ),
            ),
          ],
        )
      ],
    );
  }
}
