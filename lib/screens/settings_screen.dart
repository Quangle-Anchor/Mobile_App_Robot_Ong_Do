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
  late TextEditingController _robotUrlController;
  bool _isInit = true;
  bool _isCheckingConnection = false;
  String? _connectionResult;
  bool _connectionSuccess = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      final robotProvider = Provider.of<RobotStreamProvider>(
        context,
        listen: false,
      );
      _eventNameController = TextEditingController(
        text: robotProvider.eventName,
      );
      _locationController = TextEditingController(
        text: robotProvider.eventLocation,
      );
      _boothController = TextEditingController(text: robotProvider.eventBooth);
      _robotUrlController = TextEditingController(
        text: robotProvider.backendUrl,
      );
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _locationController.dispose();
    _boothController.dispose();
    _robotUrlController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection(RobotStreamProvider robotProvider) async {
    setState(() {
      _isCheckingConnection = true;
      _connectionResult = null;
    });

    // Cập nhật base URL từ input
    robotProvider.setBaseUrl(_robotUrlController.text.trim());

    final backendOk = await robotProvider.checkHealth();
    final robotOk = backendOk
        ? await robotProvider.checkRobotConnection()
        : false;

    setState(() {
      _isCheckingConnection = false;
      _connectionSuccess = robotOk;
      if (robotOk) {
        _connectionResult =
            '✓ Robot đã kết nối qua ${_robotUrlController.text.trim()}';
      } else if (backendOk) {
        _connectionResult =
            '✗ Backend hoạt động nhưng robot đang ngoại tuyến. Kiểm tra robot_ip hoặc /robot/status.';
      } else {
        _connectionResult =
            '✗ Không thể kết nối đến ${_robotUrlController.text.trim()}';
      }
    });
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

  Widget buildTextInput(
    String label,
    TextEditingController controller, {
    String? hint,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6.0),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13.5),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.muted, fontSize: 13.0),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 12.0,
              ),
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
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calliProvider = Provider.of<CalligraphyProvider>(context);
    final robotProvider = Provider.of<RobotStreamProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    // ── Card thông tin sự kiện ──
    final eventCard = CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THÔNG TIN SỰ KIỆN',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16.0),
          buildTextInput('Tên sự kiện', _eventNameController),
          buildTextInput('Địa điểm', _locationController),
          buildTextInput('Tên booth', _boothController),
        ],
      ),
    );

    // ── Card cấu hình robot ──
    final robotCard = CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CẤU HÌNH ROBOT',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16.0),

          // Robot IP từ config API
          buildFieldRow(
            'Robot IP',
            Text(
              robotProvider.robotIp,
              style: const TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          buildFieldRow(
            'Trạng thái kết nối',
            StatusBadge(
              status: robotProvider.isConnected ? 'Đã kết nối' : 'Ngoại tuyến',
            ),
          ),
          buildFieldRow('Chế độ', const StatusBadge(status: 'Tự động')),

          // TCP Pose
          if (robotProvider.tcpPose.length >= 3) ...[
            buildFieldRow(
              'Tọa độ TCP',
              Text(
                'X:${(robotProvider.tcpPose[0] as num).toStringAsFixed(1)}'
                ' Y:${(robotProvider.tcpPose[1] as num).toStringAsFixed(1)}'
                ' Z:${(robotProvider.tcpPose[2] as num).toStringAsFixed(1)}',
                style: const TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16.0),

          // Input URL backend
          buildTextInput(
            'Backend URL',
            _robotUrlController,
            hint: 'http://192.168.x.x:8000',
          ),

          // Kết quả kiểm tra kết nối
          if (_connectionResult != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color:
                    (_connectionSuccess
                            ? AppColors.success
                            : AppColors.destructive)
                        .withValues(alpha: 0.08),
                borderRadius: AppStyles.radiusSm,
                border: Border.all(
                  color:
                      (_connectionSuccess
                              ? AppColors.success
                              : AppColors.destructive)
                          .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                _connectionResult!,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: _connectionSuccess
                      ? AppColors.success
                      : AppColors.destructive,
                ),
              ),
            ),
            const SizedBox(height: 12.0),
          ],

          // Nút kiểm tra kết nối
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isCheckingConnection
                  ? null
                  : () => _checkConnection(robotProvider),
              icon: _isCheckingConnection
                  ? const SizedBox(
                      height: 14.0,
                      width: 14.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.wifi_find_outlined, size: 16.0),
              label: Text(
                _isCheckingConnection ? 'Đang kiểm tra...' : 'Kiểm tra kết nối',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tech,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt hệ thống',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          'Cấu hình sự kiện, kết nối robot và danh sách chữ.',
          style: TextStyle(fontSize: 13.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),

        // Split Event / Robot cards
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
                'DANH SÁCH CHỮ ĐANG BẬT',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isDesktop
                      ? 4
                      : (MediaQuery.of(context).size.width >= 540 ? 2 : 1),
                  crossAxisSpacing: 14.0,
                  mainAxisSpacing: 14.0,
                  childAspectRatio: 2.4,
                ),
                itemCount: calliProvider.charactersPool.length,
                itemBuilder: (context, index) {
                  final c = calliProvider.charactersPool[index];
                  final isEnabled = c.isEnabled;

                  return CustomCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    backgroundColor: isEnabled
                        ? AppColors.primary.withValues(alpha: 0.04)
                        : AppColors.secondary.withValues(alpha: 0.4),
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
                              style: AppStyles.calligraphyStyle.copyWith(
                                fontSize: 26.0,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 10.0),
                            Text(
                              c.char,
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isEnabled,
                          activeThumbColor: Colors.white,
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.border,
                          onChanged: (bool value) {
                            calliProvider.toggleCharacter(c.char);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24.0),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                calliProvider.resetDefaults();
                _eventNameController.text = 'Ngày hội tuyển sinh 2026';
                _locationController.text = 'Sảnh chính';
                _boothController.text = 'Khu trải nghiệm Robot Ông Đồ';
                _robotUrlController.text = 'http://localhost:8000';
                robotProvider.updateEventDetails(
                  name: 'Ngày hội tuyển sinh 2026',
                  location: 'Sảnh chính',
                  booth: 'Khu trải nghiệm Robot Ông Đồ',
                );
                setState(() {
                  _connectionResult = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã khôi phục cài đặt mặc định'),
                  ),
                );
              },
              icon: const Icon(Icons.restore, size: 16.0),
              label: const Text('Khôi phục mặc định'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.secondaryText,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
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
                // Cập nhật URL nếu có thay đổi
                robotProvider.setBaseUrl(_robotUrlController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã lưu các cài đặt thành công'),
                  ),
                );
              },
              icon: const Icon(Icons.save_outlined, size: 16.0),
              label: const Text(
                'Lưu cài đặt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 16.0,
                ),
                shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMd),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
