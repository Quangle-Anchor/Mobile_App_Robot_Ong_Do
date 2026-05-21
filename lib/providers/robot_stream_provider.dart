import 'dart:async';
import 'package:flutter/material.dart';
import '../models/calli_character.dart';
import '../models/robot_command.dart';
import '../services/robot_service.dart';

enum WritingStepStatus { pending, active, done }

class RobotStreamProvider extends ChangeNotifier {
  final RobotService _robotService = RobotService();

  // State fields
  bool _isConnected = false;
  double _inkLevel = 0.85;
  bool _isPaperPresent = true;
  double _drawingProgress = 0.0;
  String _statusMessage = "Sẵn sàng";
  String _robotId = "CALLIBOT-01";
  
  // Event config fields
  String _eventName = "Ngày hội tuyển sinh 2026";
  String _eventLocation = "Sảnh chính";
  String _eventBooth = "Khu trải nghiệm CalliBot";

  // Stream Subscriptions
  StreamSubscription<bool>? _connSub;
  StreamSubscription<double>? _inkSub;
  StreamSubscription<double>? _progSub;
  StreamSubscription<String>? _msgSub;

  // Active steps checklist tracking
  final List<String> stepLabels = [
    "Nhận lệnh từ ứng dụng",
    "Cố định giấy",
    "Nhúng mực",
    "Viết chữ thư pháp",
    "Hoàn tất"
  ];
  
  int _activeStepIndex = -1; // -1 means not writing
  int get activeStepIndex => _activeStepIndex;

  WritingStepStatus getStepStatus(int index) {
    if (_activeStepIndex == -1) return WritingStepStatus.pending;
    if (index < _activeStepIndex) return WritingStepStatus.done;
    if (index == _activeStepIndex) return WritingStepStatus.active;
    return WritingStepStatus.pending;
  }

  // Getters
  bool get isConnected => _isConnected;
  double get inkLevel => _inkLevel;
  bool get isPaperPresent => _isPaperPresent;
  double get drawingProgress => _drawingProgress;
  String get statusMessage => _statusMessage;
  String get robotId => _robotId;
  String get eventName => _eventName;
  String get eventLocation => _eventLocation;
  String get eventBooth => _eventBooth;

  RobotStreamProvider() {
    _initStreams();
  }

  void _initStreams() {
    // Initial sync
    _isConnected = _robotService.isConnected;
    _inkLevel = _robotService.inkLevel;
    _isPaperPresent = _robotService.isPaperPresent;
    _robotId = _robotService.robotId;

    // Listen to device service events
    _connSub = _robotService.connectionStream.listen((connected) {
      _isConnected = connected;
      notifyListeners();
    });
    _inkSub = _robotService.inkLevelStream.listen((ink) {
      _inkLevel = ink;
      notifyListeners();
    });
    _progSub = _robotService.drawingProgressStream.listen((progress) {
      _drawingProgress = progress;
      notifyListeners();
    });
    _msgSub = _robotService.statusMessageStream.listen((msg) {
      _statusMessage = msg;
      notifyListeners();
    });
    
    // Auto connect in simulation mode
    connectToRobot("192.168.1.100");
  }

  Future<void> connectToRobot(String ip) async {
    await _robotService.connect(ip);
  }

  Future<void> disconnectFromRobot() async {
    await _robotService.disconnect();
  }

  void refillInk() {
    _robotService.resetInk();
  }

  void updateEventDetails({required String name, required String location, required String booth}) {
    _eventName = name;
    _eventLocation = location;
    _eventBooth = booth;
    notifyListeners();
  }

  // Orchestrate the fully animated writing sequence matching robot-viet.tsx steps
  Future<void> triggerWriteSequence(CalliCharacter character, Function onCompleted) async {
    if (!_isConnected) return;
    
    _drawingProgress = 0.0;
    _activeStepIndex = 0;
    notifyListeners();

    // Step 0: Nhận lệnh từ ứng dụng
    await _robotService.executeCommand(RobotCommand(id: "CMD_RECV", action: RobotAction.connect));
    if (_activeStepIndex == -1) return;
    await Future.delayed(const Duration(milliseconds: 800));
    if (_activeStepIndex == -1) return;
    
    // Step 1: Cố định giấy
    _activeStepIndex = 1;
    notifyListeners();
    await _robotService.executeCommand(RobotCommand(id: "CMD_CLAMP", action: RobotAction.securePaper));
    if (_activeStepIndex == -1) return;
    
    // Step 2: Nhúng mực
    _activeStepIndex = 2;
    notifyListeners();
    await _robotService.executeCommand(RobotCommand(id: "CMD_INK", action: RobotAction.dipInk));
    if (_activeStepIndex == -1) return;
    
    // Step 3: Viết chữ thư pháp
    _activeStepIndex = 3;
    notifyListeners();
    await _robotService.executeCommand(
      RobotCommand(id: "CMD_DRAW", action: RobotAction.drawStroke),
      onProgress: (prog) {
        if (_activeStepIndex == -1) return;
        _drawingProgress = prog;
        notifyListeners();
      }
    );
    if (_activeStepIndex == -1) return;
    
    // Step 4: Hoàn tất
    _activeStepIndex = 4;
    notifyListeners();
    await _robotService.executeCommand(RobotCommand(id: "CMD_RELEASE", action: RobotAction.releasePaper));
    if (_activeStepIndex == -1) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (_activeStepIndex == -1) return;
    
    _activeStepIndex = -1; // Reset active state
    notifyListeners();
    onCompleted();
  }

  void pauseWrite() {
    _robotService.executeCommand(RobotCommand(id: "CMD_PAUSE", action: RobotAction.pause));
  }

  void stopEmergency() {
    _activeStepIndex = -1;
    _drawingProgress = 0.0;
    _robotService.executeCommand(RobotCommand(id: "CMD_STOP", action: RobotAction.emergencyStop));
    notifyListeners();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    _inkSub?.cancel();
    _progSub?.cancel();
    _msgSub?.cancel();
    super.dispose();
  }
}
