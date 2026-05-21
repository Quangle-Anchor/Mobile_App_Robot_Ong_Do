import 'dart:async';
import 'dart:math';
import '../models/robot_command.dart';

class RobotService {
  // Singleton pattern
  static final RobotService _instance = RobotService._internal();
  factory RobotService() => _instance;
  RobotService._internal();

  bool _isConnected = false;
  double _inkLevel = 0.85; // 85% starting ink level
  bool _isPaperPresent = true;
  final String _robotId = "CALLIBOT-01";
  
  // Broadcast streams for external status listening
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  final StreamController<double> _inkLevelController = StreamController<double>.broadcast();
  final StreamController<double> _drawingProgressController = StreamController<double>.broadcast();
  final StreamController<String> _robotStatusMessageController = StreamController<String>.broadcast();
  
  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<double> get inkLevelStream => _inkLevelController.stream;
  Stream<double> get drawingProgressStream => _drawingProgressController.stream;
  Stream<String> get statusMessageStream => _robotStatusMessageController.stream;

  bool get isConnected => _isConnected;
  double get inkLevel => _inkLevel;
  bool get isPaperPresent => _isPaperPresent;
  String get robotId => _robotId;

  // Track active simulated printing timer
  Timer? _simulationTimer;

  Future<bool> connect(String ipAddress) async {
    _robotStatusMessageController.add("Connecting to $ipAddress...");
    await Future.delayed(const Duration(seconds: 1)); // Simulate handshake
    _isConnected = true;
    _connectionController.add(true);
    _robotStatusMessageController.add("Robot Connected!");
    return true;
  }

  Future<void> disconnect() async {
    _isConnected = false;
    _connectionController.add(false);
    _robotStatusMessageController.add("Disconnected from robot");
  }

  // Raw coordinate transmitter / executor simulation
  Future<void> executeCommand(RobotCommand command, {Function(double)? onProgress}) async {
    if (!_isConnected) {
      _robotStatusMessageController.add("Error: Device is not connected");
      throw Exception("Robot not connected");
    }

    _simulationTimer?.cancel();
    
    switch (command.action) {
      case RobotAction.connect:
        _robotStatusMessageController.add("Initiating Handshake...");
        break;
      case RobotAction.securePaper:
        _robotStatusMessageController.add("Securing Calligraphy paper...");
        await Future.delayed(const Duration(milliseconds: 800));
        _isPaperPresent = true;
        _robotStatusMessageController.add("Paper Secured successfully");
        break;
      case RobotAction.dipInk:
        _robotStatusMessageController.add("Dipping brush pen into inkwell...");
        await Future.delayed(const Duration(milliseconds: 1200));
        _inkLevel = max(0.0, _inkLevel - 0.05); // Consumes 5% ink
        _inkLevelController.add(_inkLevel);
        _robotStatusMessageController.add("Brush dipped successfully. Ink: ${(_inkLevel * 100).toInt()}%");
        break;
      case RobotAction.drawStroke:
        _robotStatusMessageController.add("Starting drawing execution coordinates...");
        double currentProgress = 0.0;
        
        // Simulating coordinate transmission speed and real progress
        final completer = Completer<void>();
        _simulationTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
          currentProgress += 0.05; // 5% increase every 200ms (~4 seconds total)
          if (currentProgress >= 1.0) {
            currentProgress = 1.0;
            timer.cancel();
            completer.complete();
          }
          _drawingProgressController.add(currentProgress);
          if (onProgress != null) onProgress(currentProgress);
        });
        
        await completer.future;
        _robotStatusMessageController.add("Stroke drawing completed!");
        break;
      case RobotAction.releasePaper:
        _robotStatusMessageController.add("Releasing paper clamps...");
        await Future.delayed(const Duration(milliseconds: 500));
        _isPaperPresent = false;
        _robotStatusMessageController.add("Paper released");
        break;
      case RobotAction.home:
        _robotStatusMessageController.add("Homing motor coordinates...");
        await Future.delayed(const Duration(milliseconds: 1000));
        _robotStatusMessageController.add("Motors homed");
        break;
      case RobotAction.pause:
        _simulationTimer?.cancel();
        _robotStatusMessageController.add("Execution paused by user");
        break;
      case RobotAction.emergencyStop:
        _simulationTimer?.cancel();
        _robotStatusMessageController.add("EMERGENCY STOP TRIGGERED!");
        break;
    }
  }

  void resetInk() {
    _inkLevel = 0.95;
    _inkLevelController.add(_inkLevel);
    _robotStatusMessageController.add("Ink refilled");
  }

  void dispose() {
    _connectionController.close();
    _inkLevelController.close();
    _drawingProgressController.close();
    _robotStatusMessageController.close();
    _simulationTimer?.cancel();
  }
}
