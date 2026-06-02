import 'dart:async';
import 'package:flutter/material.dart';
import '../models/calli_character.dart';
import '../services/robot_service.dart';

enum WritingStepStatus { pending, active, done }

class RobotStreamProvider extends ChangeNotifier {
  final RobotService _robotService = RobotService();

  // ── Trạng thái kết nối & robot ──
  bool _isConnected = false;
  String _statusMessage = 'Chưa kết nối';
  String _robotIp = 'localhost:8000';
  List<dynamic> _tcpPose = [0, 0, 0, 0, 0, 0];
  List<dynamic> _errorCode = [0, 0];

  // ── Tiến độ viết ──
  double _drawingProgress = 0.0;
  int _activeStepIndex = -1; // -1 = không đang viết

  // ── Config được load từ API ──
  Map<String, dynamic> _configData = {};

  // ── Thông tin sự kiện (cấu hình local) ──
  String _eventName = 'Ngày hội tuyển sinh 2026';
  String _eventLocation = 'Sảnh chính';
  String _eventBooth = 'Khu trải nghiệm CalliBot';

  // ── Stream subscription từ service ──
  StreamSubscription<String>? _msgSub;

  // ── Poll timer ──
  Timer? _pollTimer;

  // ────────────────────────────────────────────────
  // Getters
  // ────────────────────────────────────────────────

  bool get isConnected => _isConnected;
  String get statusMessage => _statusMessage;
  String get robotIp => _robotIp;
  List<dynamic> get tcpPose => _tcpPose;
  List<dynamic> get errorCode => _errorCode;
  double get drawingProgress => _drawingProgress;
  int get activeStepIndex => _activeStepIndex;
  Map<String, dynamic> get configData => _configData;
  String get eventName => _eventName;
  String get eventLocation => _eventLocation;
  String get eventBooth => _eventBooth;

  // Giữ tương thích với màn hình cũ (robotId, inkLevel, isPaperPresent)
  String get robotId => _configData['robot_ip'] ?? _robotIp;
  double get inkLevel => 1.0; // gripper không có ink metric, giữ full
  bool get isPaperPresent => true;

  // ── Step labels cho timeline ──
  final List<String> stepLabels = [
    'Nhận lệnh từ ứng dụng',
    'Cố định giấy',
    'Robot viết chữ',
    'Thả giấy',
    'Hoàn tất',
  ];

  WritingStepStatus getStepStatus(int index) {
    if (_activeStepIndex == -1) return WritingStepStatus.pending;
    if (index < _activeStepIndex) return WritingStepStatus.done;
    if (index == _activeStepIndex) return WritingStepStatus.active;
    return WritingStepStatus.pending;
  }

  // ────────────────────────────────────────────────
  // Khởi tạo
  // ────────────────────────────────────────────────

  RobotStreamProvider() {
    _init();
  }

  void _init() {
    // Lắng nghe status message từ service
    _msgSub = _robotService.statusMessageStream.listen((msg) {
      _statusMessage = msg;
      notifyListeners();
    });

    // Load config + kiểm tra kết nối lần đầu
    _initialConnect();

    // Poll trạng thái robot mỗi 5 giây
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollStatus();
    });
  }

  Future<void> _initialConnect() async {
    await _loadConfig();
    await _pollStatus();
  }

  // ────────────────────────────────────────────────
  // Config
  // ────────────────────────────────────────────────

  Future<void> _loadConfig() async {
    try {
      final config = await _robotService.fetchConfig();
      _configData = config;
      if (config['robot_ip'] != null) {
        _robotIp = config['robot_ip'] as String;
      }
      notifyListeners();
    } catch (e) {
      // Config load thất bại — giữ giá trị mặc định
      debugPrint('Config load error: $e');
    }
  }

  Future<void> reloadConfig() async {
    await _loadConfig();
  }

  Future<void> patchConfig(Map<String, dynamic> updates) async {
    final result = await _robotService.patchConfig(updates);
    _configData = result;
    if (result['robot_ip'] != null) {
      _robotIp = result['robot_ip'] as String;
    }
    notifyListeners();
  }

  // ────────────────────────────────────────────────
  // Kết nối & Poll
  // ────────────────────────────────────────────────

  void setBaseUrl(String url) {
    _robotService.setBaseUrl(url);
    _robotIp = url.replaceAll(RegExp(r'^https?://'), '');
    notifyListeners();
    _pollStatus();
  }

  Future<bool> checkHealth() async {
    final ok = await _robotService.checkHealth();
    return ok;
  }

  Future<void> _pollStatus() async {
    if (_activeStepIndex != -1) return; // Không poll khi đang viết
    try {
      final status = await _robotService.fetchRobotStatus();
      final wasConnected = _isConnected;
      _isConnected = status['connected'] == true;
      _tcpPose = (status['tcp_pose'] as List?) ?? _tcpPose;
      _errorCode = (status['error_code'] as List?) ?? _errorCode;

      if (_isConnected && !wasConnected) {
        _statusMessage = 'Robot đã kết nối';
      } else if (!_isConnected && wasConnected) {
        _statusMessage = 'Mất kết nối robot';
      }
      notifyListeners();
    } catch (_) {
      if (_isConnected) {
        _isConnected = false;
        _statusMessage = 'Không thể kết nối robot';
        notifyListeners();
      }
    }
  }

  Future<void> refreshStatus() async {
    await _pollStatus();
  }

  // ────────────────────────────────────────────────
  // Event details
  // ────────────────────────────────────────────────

  void updateEventDetails({
    required String name,
    required String location,
    required String booth,
  }) {
    _eventName = name;
    _eventLocation = location;
    _eventBooth = booth;
    notifyListeners();
  }

  // ────────────────────────────────────────────────
  // Write Sequence (thật)
  // ────────────────────────────────────────────────

  /// Điều phối toàn bộ luồng viết chữ qua API thật.
  Future<void> triggerWriteSequence(
    CalliCharacter character,
    Function onCompleted,
  ) async {
    if (!_isConnected) {
      _statusMessage = 'Lỗi: Robot chưa kết nối';
      notifyListeners();
      return;
    }

    _drawingProgress = 0.0;
    _activeStepIndex = 0;
    notifyListeners();

    try {
      // ── Step 0: Nhận lệnh ──
      _statusMessage = 'Nhận lệnh từ ứng dụng...';
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400));
      if (_activeStepIndex == -1) return;

      // ── Step 1: Cố định giấy (đóng gripper) ──
      _activeStepIndex = 1;
      notifyListeners();
      await _robotService.closeGripper();
      if (_activeStepIndex == -1) return;
      _drawingProgress = 0.15;
      notifyListeners();

      // ── Step 2: Viết chữ ──
      _activeStepIndex = 2;
      notifyListeners();
      _statusMessage = 'Robot đang viết chữ "${character.char}"...';
      _drawingProgress = 0.2;
      notifyListeners();

      // Gọi API viết — thao tác này blocking cho đến khi robot hoàn thành
      await _robotService.drawText(character.char, vel: 12);
      if (_activeStepIndex == -1) return;

      _drawingProgress = 0.85;
      notifyListeners();

      // ── Step 3: Thả giấy (mở gripper) ──
      _activeStepIndex = 3;
      notifyListeners();
      await _robotService.openGripper();
      if (_activeStepIndex == -1) return;
      _drawingProgress = 0.95;
      notifyListeners();

      // ── Step 4: Hoàn tất ──
      _activeStepIndex = 4;
      _drawingProgress = 1.0;
      _statusMessage = 'Hoàn tất viết chữ "${character.char}"!';
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 600));
      if (_activeStepIndex == -1) return;

      _activeStepIndex = -1;
      notifyListeners();
      onCompleted();
    } catch (e) {
      _statusMessage = 'Lỗi: ${e.toString().replaceAll('Exception: ', '')}';
      _activeStepIndex = -1;
      _drawingProgress = 0.0;
      notifyListeners();
      // Vẫn callback để UI không bị treo
      onCompleted();
    }
  }

  void pauseWrite() {
    // Không có API pause trong backend → chỉ cập nhật UI state
    _statusMessage = 'Đã tạm dừng (không hỗ trợ pause qua API)';
    notifyListeners();
  }

  void stopEmergency() {
    _activeStepIndex = -1;
    _drawingProgress = 0.0;
    _statusMessage = 'DỪNG KHẨN CẤP!';
    notifyListeners();
  }

  // Legacy – giữ tương thích
  void refillInk() {
    _statusMessage = 'Đã làm mới trạng thái mực';
    notifyListeners();
  }

  // ────────────────────────────────────────────────
  // Dispose
  // ────────────────────────────────────────────────

  @override
  void dispose() {
    _msgSub?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }
}
