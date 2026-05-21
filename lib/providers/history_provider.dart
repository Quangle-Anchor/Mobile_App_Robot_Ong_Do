import 'package:flutter/material.dart';
import '../services/database_service.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();

  List<Map<String, dynamic>> _allLogs = [];
  bool _isLoading = false;
  
  // Active filters
  String _searchQuery = "";
  String _statusFilter = "Tất cả";

  List<Map<String, dynamic>> get allLogs => _allLogs;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get statusFilter => _statusFilter;

  // Computed property applying search and filters
  List<Map<String, dynamic>> get filteredLogs {
    return _allLogs.where((log) {
      // 1. Filter by search query (id or char)
      final idMatch = log['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final charMatch = log['char'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final meaningMatch = log['meaning'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSearch = idMatch || charMatch || meaningMatch;

      // 2. Filter by status dropdown
      final matchesStatus = _statusFilter == "Tất cả" || log['status'] == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  HistoryProvider() {
    loadLogs();
  }

  Future<void> loadLogs() async {
    _isLoading = true;
    notifyListeners();
    
    _allLogs = await _dbService.fetchHistoryLogs();
    
    _isLoading = false;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  Future<void> addLog(String char, String meaning, String status) async {
    final newId = "CB-0${_allLogs.length + 1}";
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    final newLog = {
      "id": newId,
      "char": char,
      "meaning": meaning,
      "time": timeStr,
      "status": status,
      "who": "Sinh viên"
    };

    await _dbService.saveHistoryLog(newLog);
    await loadLogs(); // Reload data
  }

  Future<void> clearLogs() async {
    await _dbService.clearHistoryLogs();
    await loadLogs();
  }
}
