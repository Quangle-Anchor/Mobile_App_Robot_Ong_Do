class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Mock memory database table
  final List<Map<String, dynamic>> _historyLogs = [
    {
      "id": "CB-001",
      "char": "Tâm",
      "meaning": "Sự chân thành, lòng tốt và sự tử tế",
      "time": "09:15",
      "status": "Hoàn thành",
      "who": "Sinh viên"
    },
    {
      "id": "CB-002",
      "char": "Phúc",
      "meaning": "May mắn, hạnh phúc và bình an",
      "time": "09:25",
      "status": "Hoàn thành",
      "who": "Sinh viên"
    },
    {
      "id": "CB-003",
      "char": "Đức",
      "meaning": "Phẩm chất tốt đẹp của con người",
      "time": "09:40",
      "status": "Đang viết",
      "who": "Sinh viên"
    },
    {
      "id": "CB-004",
      "char": "An",
      "meaning": "Bình an, nhẹ nhàng và ổn định",
      "time": "10:00",
      "status": "Hoàn thành",
      "who": "Sinh viên"
    },
    {
      "id": "CB-005",
      "char": "Lộc",
      "meaning": "Tài lộc, may mắn và thịnh vượng",
      "time": "10:12",
      "status": "Đã hủy",
      "who": "Sinh viên"
    },
    {
      "id": "CB-006",
      "char": "Trí",
      "meaning": "Tri thức, hiểu biết và sáng tạo",
      "time": "10:24",
      "status": "Lỗi",
      "who": "Sinh viên"
    },
  ];

  Future<List<Map<String, dynamic>>> fetchHistoryLogs() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate disk I/O
    return List<Map<String, dynamic>>.from(_historyLogs);
  }

  Future<void> saveHistoryLog(Map<String, dynamic> log) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _historyLogs.insert(0, log); // Add to the top
  }

  Future<void> clearHistoryLogs() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _historyLogs.clear();
  }
}
