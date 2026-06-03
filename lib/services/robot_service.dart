import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RobotService {
  // Singleton pattern
  static final RobotService _instance = RobotService._internal();
  factory RobotService() => _instance;
  RobotService._internal();

  // Base URL có thể thay đổi qua setBaseUrl()
  String _baseUrl = 'http://localhost:8000';

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    final trimmed = url.trim();
    final withScheme = trimmed.startsWith(RegExp(r'https?://'))
        ? trimmed
        : 'http://$trimmed';
    _baseUrl = withScheme.endsWith('/')
        ? withScheme.substring(0, withScheme.length - 1)
        : withScheme;
  }

  // Broadcast streams để UI lắng nghe
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  final StreamController<String> _robotStatusMessageController =
      StreamController<String>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  Stream<String> get statusMessageStream =>
      _robotStatusMessageController.stream;

  // ────────────────────────────────────────────────
  // Internal HTTP helpers
  // ────────────────────────────────────────────────

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http
        .get(uri, headers: _headers)
        .timeout(const Duration(seconds: 8));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    }
    throw Exception(
      'GET $path failed: ${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> _post(
    String path, [
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 30),
  ]) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http
        .post(
          uri,
          headers: _headers,
          body: body != null ? json.encode(body) : null,
        )
        .timeout(timeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    }
    throw Exception(
      'POST $path failed: ${response.statusCode} ${response.body}',
    );
  }

  Future<Map<String, dynamic>> _patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$_baseUrl$path');
    final response = await http
        .patch(uri, headers: _headers, body: json.encode(body))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    }
    throw Exception(
      'PATCH $path failed: ${response.statusCode} ${response.body}',
    );
  }

  // ────────────────────────────────────────────────
  // Health
  // ────────────────────────────────────────────────

  /// GET /health → { "status": "ok" }
  Future<bool> checkHealth() async {
    try {
      final data = await _get('/health');
      return data['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  // ────────────────────────────────────────────────
  // Robot Status
  // ────────────────────────────────────────────────

  /// GET /robot/status → { connected, xmlrpc_ok, tcp_pose, error_code }
  Future<Map<String, dynamic>> fetchRobotStatus() async {
    return _get('/robot/status');
  }

  Future<Map<String, dynamic>> fetchRawRobotStatus() async {
    return _get('/robot/raw_status');
  }

  /// GET /robot/ports
  Future<Map<String, dynamic>> fetchRobotPorts() async {
    return _get('/robot/ports');
  }

  // ────────────────────────────────────────────────
  // Config
  // ────────────────────────────────────────────────

  /// GET /config → toàn bộ config object
  Future<Map<String, dynamic>> fetchConfig() async {
    return _get('/config');
  }

  /// PATCH /config với body { data: {...} }
  Future<Map<String, dynamic>> patchConfig(Map<String, dynamic> updates) async {
    return _patch('/config', {'data': updates});
  }

  /// POST /config/reload
  Future<Map<String, dynamic>> reloadConfig() async {
    return _post('/config/reload');
  }

  // ────────────────────────────────────────────────
  // Motion
  // ────────────────────────────────────────────────

  /// POST /robot/move/start → di chuyển robot về vị trí bắt đầu
  Future<Map<String, dynamic>> moveToStart({double vel = 20}) async {
    _robotStatusMessageController.add('Di chuyển về vị trí bắt đầu...');
    final result = await _post('/robot/move/start', {
      'vel': vel,
    }, const Duration(minutes: 3));
    _robotStatusMessageController.add('Robot đã về vị trí bắt đầu');
    return result;
  }

  /// POST /robot/draw/text → viết chữ thư pháp
  /// Trả về { stroke_count, pose_count, planned_pose_count, result, ... }
  Future<Map<String, dynamic>> drawText(
    String text, {
    double vel = 12,
    bool continuous = false,
  }) async {
    _robotStatusMessageController.add('Bắt đầu viết chữ "$text"...');
    final result = await _post('/robot/draw/text', {
      'text': text,
      'continuous': continuous,
      'vel': vel,
    }, const Duration(minutes: 10));
    _robotStatusMessageController.add('Đã viết xong chữ "$text"');
    _connectionController.add(true);
    return result;
  }

  Future<Map<String, dynamic>> drawTextOutlineTimes(
    String text, {
    double vel = 12,
    bool continuous = false,
  }) async {
    _robotStatusMessageController.add(
      'Bắt đầu viết outline Times New Roman "$text"...',
    );
    final result = await _post('/robot/draw/text/outline', {
      'text': text,
      'continuous': continuous,
      'vel': vel,
    }, const Duration(minutes: 10));
    _robotStatusMessageController.add(
      'Đã viết xong outline Times New Roman "$text"',
    );
    _connectionController.add(true);
    return result;
  }

  Future<Map<String, dynamic>> drawShape(
    String shapeName, {
    double vel = 20,
  }) async {
    _robotStatusMessageController.add('Bắt đầu vẽ "$shapeName"...');
    final result = await _post('/robot/draw/shape', {
      'shape_name': shapeName,
      'vel': vel,
    }, const Duration(minutes: 10));
    _robotStatusMessageController.add('Đã vẽ xong "$shapeName"');
    return result;
  }

  Future<Map<String, dynamic>> drawLine({double vel = 20}) async {
    _robotStatusMessageController.add('Bắt đầu vẽ đường thẳng...');
    final result = await _post('/robot/draw/line', {
      'vel': vel,
    }, const Duration(minutes: 10));
    _robotStatusMessageController.add('Đã vẽ xong đường thẳng');
    return result;
  }

  Future<Map<String, dynamic>> drawCircle({double vel = 20}) async {
    _robotStatusMessageController.add('Bắt đầu vẽ hình tròn...');
    final result = await _post('/robot/draw/circle', {
      'vel': vel,
    }, const Duration(minutes: 10));
    _robotStatusMessageController.add('Đã vẽ xong hình tròn');
    return result;
  }

  Future<Map<String, dynamic>> previewText(
    String text, {
    bool continuous = false,
  }) async {
    return _post('/trajectory/text/preview', {
      'text': text,
      'continuous': continuous,
    });
  }

  Future<Map<String, dynamic>> previewTextOutlineTimes(
    String text, {
    bool continuous = false,
  }) async {
    return _post('/trajectory/text/outline/preview', {
      'text': text,
      'continuous': continuous,
    });
  }

  Future<Map<String, dynamic>> previewShape(String shapeName) async {
    return _post('/trajectory/shape/preview', {'shape_name': shapeName});
  }

  /// POST /robot/draw/svg với word_key hoặc svg_path
  Future<Map<String, dynamic>> drawSvgByWordKey(
    String wordKey, {
    double vel = 12,
  }) async {
    _robotStatusMessageController.add('Bắt đầu viết "$wordKey" (SVG)...');
    final result = await _post('/robot/draw/svg', {
      'word_key': wordKey,
      'vel': vel,
    }, const Duration(minutes: 10));
    _robotStatusMessageController.add('Đã viết xong "$wordKey"');
    return result;
  }

  // ────────────────────────────────────────────────
  // Lifecycle
  // ────────────────────────────────────────────────

  void dispose() {
    _connectionController.close();
    _robotStatusMessageController.close();
  }
}
