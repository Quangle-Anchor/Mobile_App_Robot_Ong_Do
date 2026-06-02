/// Lưu lịch sử viết chữ theo phiên (in-memory).
/// Backend không có API history → dữ liệu chỉ tồn tại trong phiên chạy app.
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Danh sách lịch sử — bắt đầu rỗng, chỉ thêm khi có lệnh viết thật
  final List<Map<String, dynamic>> _historyLogs = [];

  Future<List<Map<String, dynamic>>> fetchHistoryLogs() async {
    return List<Map<String, dynamic>>.from(_historyLogs);
  }

  Future<void> saveHistoryLog(Map<String, dynamic> log) async {
    _historyLogs.insert(0, log); // Thêm vào đầu danh sách (mới nhất trên cùng)
  }

  Future<void> clearHistoryLogs() async {
    _historyLogs.clear();
  }
}
