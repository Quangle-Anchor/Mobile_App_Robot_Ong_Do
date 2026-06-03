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
  Map<String, dynamic>? _lastActionResult;

  // ── Config được load từ API ──
  Map<String, dynamic> _configData = {};

  // ── Thông tin sự kiện (cấu hình local) ──
  String _eventName = 'Ngày hội tuyển sinh 2026';
  String _eventLocation = 'Sảnh chính';
  String _eventBooth = 'Khu trải nghiệm Robot Ông Đồ';

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
  String get backendUrl => _robotService.baseUrl;
  List<dynamic> get tcpPose => _tcpPose;
  List<dynamic> get errorCode => _errorCode;
  double get drawingProgress => _drawingProgress;
  int get activeStepIndex => _activeStepIndex;
  bool get isBusy => _activeStepIndex != -1;
  Map<String, dynamic>? get lastActionResult => _lastActionResult;
  Map<String, dynamic> get configData => _configData;
  String get eventName => _eventName;
  String get eventLocation => _eventLocation;
  String get eventBooth => _eventBooth;

  // Giữ tương thích với màn hình cũ (robotId, inkLevel, isPaperPresent)
  String get robotId => _configData['robot_ip'] ?? _robotIp;
  double get inkLevel => 1.0; // legacy UI metric, giữ full
  bool get isPaperPresent => true;

  // ── Step labels cho timeline ──
  final List<String> stepLabels = [
    'Nhận lệnh từ ứng dụng',
    'Robot viết chữ',
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
    _robotIp = _robotService.baseUrl.replaceAll(RegExp(r'^https?://'), '');
    notifyListeners();
    _pollStatus();
  }

  Future<bool> checkHealth() async {
    final ok = await _robotService.checkHealth();
    return ok;
  }

  Future<bool> checkRobotConnection() async {
    await _pollStatus();
    return _isConnected;
  }

  bool _statusFlag(dynamic value) {
    if (value == true) return true;
    if (value is num) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  bool _isRobotStatusConnected(Map<String, dynamic> status) {
    return _statusFlag(status['connected']) || _statusFlag(status['xmlrpc_ok']);
  }

  Future<Map<String, dynamic>> _fetchBestRobotStatus() async {
    final status = await _robotService.fetchRobotStatus();
    if (_isRobotStatusConnected(status)) return status;

    try {
      final rawStatus = await _robotService.fetchRawRobotStatus();
      if (_isRobotStatusConnected(rawStatus)) {
        return {...status, ...rawStatus, 'connected': true};
      }
    } catch (e) {
      debugPrint('Raw robot status fallback error: $e');
    }

    return status;
  }

  Future<void> _pollStatus() async {
    if (_activeStepIndex != -1) return; // Không poll khi đang viết
    try {
      final status = await _fetchBestRobotStatus();
      final wasConnected = _isConnected;
      _isConnected = _isRobotStatusConnected(status);
      if (status['robot_ip'] is String) {
        _robotIp = status['robot_ip'] as String;
      } else if (status['controller_ip'] is String) {
        _robotIp = status['controller_ip'] as String;
      }
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

  Future<Map<String, dynamic>?> previewTypedText(
    String text, {
    bool continuous = false,
    bool outlineTimes = false,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _statusMessage = 'Vui lòng nhập chữ cần preview';
      notifyListeners();
      return null;
    }

    try {
      final modeLabel = outlineTimes ? 'outline Times New Roman' : 'chữ';
      _statusMessage = 'Đang tạo preview $modeLabel "$trimmed"...';
      notifyListeners();
      final result = outlineTimes
          ? await _robotService.previewTextOutlineTimes(
              trimmed,
              continuous: continuous,
            )
          : await _robotService.previewTextSkeleton(trimmed, continuous: continuous);
      _lastActionResult = result;
      final strokeCount = result['stroke_count'] ?? '-';
      final poseCount = (result['poses'] as List?)?.length ?? '-';
      _statusMessage =
          'Preview $modeLabel "$trimmed": $strokeCount nét, $poseCount pose';
      notifyListeners();
      return result;
    } catch (e) {
      _statusMessage =
          'Lỗi preview chữ: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
      return null;
    }
  }

  Future<Map<String, dynamic>?> previewShape(String shapeName) async {
    try {
      _statusMessage = 'Đang tạo preview hình "$shapeName"...';
      notifyListeners();
      final result = await _robotService.previewShape(shapeName);
      _lastActionResult = result;
      final poseCount = (result['poses'] as List?)?.length ?? '-';
      _statusMessage = 'Preview hình "$shapeName": $poseCount pose';
      notifyListeners();
      return result;
    } catch (e) {
      _statusMessage =
          'Lỗi preview hình: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
      return null;
    }
  }

  Future<void> drawTypedText(
    String text, {
    bool continuous = false,
    double vel = 12,
    bool outlineTimes = false,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      _statusMessage = 'Vui lòng nhập chữ cần viết';
      notifyListeners();
      return;
    }

    final modeLabel = outlineTimes ? 'outline Times New Roman' : 'chữ';
    await _runDirectRobotAction(
      startMessage: 'Robot đang viết $modeLabel "$trimmed"...',
      doneMessage: 'Hoàn tất viết $modeLabel "$trimmed"',
      action: () => outlineTimes
          ? _robotService.drawTextOutlineTimes(
              trimmed,
              vel: vel,
              continuous: continuous,
            )
          : _robotService.drawTextSkeleton(trimmed, vel: vel, continuous: continuous),
    );
  }

  Future<void> drawShapeByName(String shapeName, {double vel = 20}) async {
    await _runDirectRobotAction(
      startMessage: 'Robot đang vẽ "$shapeName"...',
      doneMessage: 'Hoàn tất vẽ "$shapeName"',
      action: () => _robotService.drawShape(shapeName, vel: vel),
    );
  }

  Future<void> drawMeasuredLine({double vel = 20}) async {
    await _runDirectRobotAction(
      startMessage: 'Robot đang vẽ đường thẳng theo vùng giấy...',
      doneMessage: 'Hoàn tất vẽ đường thẳng',
      action: () => _robotService.drawLine(vel: vel),
    );
  }

  Future<void> drawMeasuredCircle({double vel = 20}) async {
    await _runDirectRobotAction(
      startMessage: 'Robot đang vẽ hình tròn theo vùng giấy...',
      doneMessage: 'Hoàn tất vẽ hình tròn',
      action: () => _robotService.drawCircle(vel: vel),
    );
  }

  Future<void> _runDirectRobotAction({
    required String startMessage,
    required String doneMessage,
    required Future<Map<String, dynamic>> Function() action,
  }) async {
    if (_activeStepIndex != -1) return;

    if (!_isConnected) {
      await _pollStatus();
    }
    if (!_isConnected) {
      _statusMessage = 'Lỗi: Robot chưa kết nối';
      notifyListeners();
      return;
    }

    _activeStepIndex = 0;
    _drawingProgress = 0.05;
    _statusMessage = startMessage;
    notifyListeners();

    try {
      final result = await action();
      _lastActionResult = result;
      _drawingProgress = 1.0;
      _statusMessage = doneMessage;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      _drawingProgress = 0.0;
      _statusMessage = 'Lỗi: ${e.toString().replaceAll('Exception: ', '')}';
      notifyListeners();
    } finally {
      _activeStepIndex = -1;
      notifyListeners();
      unawaited(_pollStatus());
    }
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

      // ── Step 1: Viết chữ ──
      _activeStepIndex = 1;
      notifyListeners();
      _statusMessage = 'Robot đang viết chữ "${character.char}"...';
      _drawingProgress = 0.2;
      notifyListeners();

      // Gọi API viết — thao tác này blocking cho đến khi robot hoàn thành
      await _robotService.drawText(character.char, vel: 12);
      if (_activeStepIndex == -1) return;

      _drawingProgress = 0.85;
      notifyListeners();

      // ── Step 2: Hoàn tất ──
      _activeStepIndex = 2;
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
