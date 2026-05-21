import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/history_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final logs = historyProvider.filteredLogs;
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return CustomCard(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title and search inputs row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Lịch sử viết thư pháp",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    "Danh sách các lượt viết của robot trong sự kiện.",
                    style: TextStyle(fontSize: 13.0, color: AppColors.muted),
                  ),
                ],
              ),

              // Trash clear database button
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.destructive),
                tooltip: "Xóa toàn bộ lịch sử",
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Xác nhận xóa"),
                      content: const Text("Bạn có chắc chắn muốn xóa sạch toàn bộ lịch sử viết không?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Hủy"),
                        ),
                        TextButton(
                          onPressed: () {
                            historyProvider.clearLogs();
                            Navigator.pop(context);
                          },
                          child: const Text("Xóa sạch", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Search & Dropdown Filters Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: historyProvider.updateSearchQuery,
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: "Tìm theo chữ hoặc mã lượt",
                    prefixIcon: const Icon(Icons.search, size: 18.0, color: AppColors.muted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    filled: true,
                    fillColor: AppColors.secondary.withValues(alpha: 0.4),
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
              ),
              const SizedBox(width: 14.0),

              // Status dropdown filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: AppStyles.radiusSm,
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: historyProvider.statusFilter,
                    icon: const Icon(Icons.filter_list_rounded, size: 18.0),
                    style: const TextStyle(fontSize: 13.0, color: AppColors.ink, fontWeight: FontWeight.bold),
                    onChanged: (String? val) {
                      if (val != null) historyProvider.updateStatusFilter(val);
                    },
                    items: <String>['Tất cả', 'Hoàn thành', 'Đang viết', 'Đã hủy', 'Lỗi']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Responsive history list table/list cards loader
          if (historyProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (logs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40.0),
                child: Text(
                  "Không tìm thấy lịch sử phù hợp.",
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
            )
          else if (isDesktop)
            // Desktop horizontal table layout — use SingleChildScrollView for horizontal overflow
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: AppStyles.radiusLg,
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: AppStyles.radiusLg,
                  child: DataTable(
                    // backgroundColor no longer available on DataTable directly — wrap via decoration
                    headingRowColor: WidgetStateProperty.all( // MaterialStateProperty → WidgetStateProperty
                      AppColors.secondary.withValues(alpha: 0.4),
                    ),
                    columnSpacing: 18.0,
                    horizontalMargin: 16.0,
                    columns: const [
                      DataColumn(label: Text("MÃ LƯỢT", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("CHỮ ĐÃ CHỌN", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("Ý NGHĨA", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("THỜI GIAN", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("TRẠNG THÁI", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("NGƯỜI THAO TÁC", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold))),
                      DataColumn(label: Text("HÀNH ĐỘNG", style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold))),
                    ],
                    rows: logs.map((row) {
                      return DataRow(cells: [
                        DataCell(Text(
                          row["id"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Courier'),
                        )),
                        DataCell(Text(
                          row["char"]!,
                          style: AppStyles.calligraphyStyle.copyWith(fontSize: 22.0),
                        )),
                        DataCell(Text(
                          row["meaning"]!,
                          style: const TextStyle(color: AppColors.secondaryText, fontSize: 13.0),
                        )),
                        DataCell(Text(
                          row["time"]!,
                          style: const TextStyle(fontFamily: 'Courier', fontSize: 13.0),
                        )),
                        DataCell(StatusBadge(status: row["status"]!)),
                        DataCell(Text(
                          row["who"]!,
                          style: const TextStyle(color: AppColors.secondaryText, fontSize: 13.0),
                        )),
                        DataCell(
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.remove_red_eye_outlined, size: 12.0),
                            label: const Text("Xem", style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.ink,
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                              shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusSm),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            )
          else
            // Mobile list card wrapper layout
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final row = logs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppStyles.radiusLg,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            row["id"]!,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Courier'),
                          ),
                          StatusBadge(status: row["status"]!),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        children: [
                          Container(
                            height: 48.0,
                            width: 48.0,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: AppStyles.radiusSm,
                              border: Border.all(color: AppColors.border),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              row["char"]!,
                              style: AppStyles.calligraphyStyle.copyWith(fontSize: 28.0),
                            ),
                          ),
                          const SizedBox(width: 14.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  row["meaning"]!,
                                  style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 3.0),
                                Text(
                                  "Thời gian: ${row["time"]} · Thao tác: ${row["who"]}",
                                  style: TextStyle(fontSize: 11.0, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
