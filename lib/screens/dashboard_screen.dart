import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/robot_stream_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/custom_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final robotProvider = Provider.of<RobotStreamProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 992;
    final isTablet = width >= 600;

    // ── Tính KPI từ lịch sử thật ──
    final logs = historyProvider.allLogs;
    final totalToday = logs.length;
    final totalCompleted = logs
        .where((l) => l['status'] == 'Hoàn thành')
        .length;
    final totalError = logs
        .where((l) => l['status'] == 'Lỗi' || l['status'] == 'Đã hủy')
        .length;

    // Tìm chữ được chọn nhiều nhất
    final charCounts = <String, int>{};
    for (final log in logs) {
      final c = log['char']?.toString() ?? '';
      if (c.isNotEmpty) charCounts[c] = (charCounts[c] ?? 0) + 1;
    }
    String mostChosenChar = '—';
    if (charCounts.isNotEmpty) {
      mostChosenChar = charCounts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    // 1. KPI Stats
    final List<Map<String, dynamic>> kpiStats = [
      {
        'label': 'Tổng lượt viết hôm nay',
        'value': '$totalToday',
        'icon': Icons.trending_up,
        'color': AppColors.primary,
        'bg': AppColors.primary.withValues(alpha: 0.1),
      },
      {
        'label': 'Được chọn nhiều nhất',
        'value': mostChosenChar,
        'icon': Icons.analytics_outlined,
        'color': AppColors.gold,
        'bg': AppColors.gold.withValues(alpha: 0.15),
        'isCalli': true,
      },
      {
        'label': 'Trạng thái robot',
        'value': robotProvider.isConnected ? 'Sẵn sàng' : 'Ngoại tuyến',
        'icon': Icons.smart_toy_outlined,
        'color': robotProvider.isConnected
            ? AppColors.success
            : AppColors.destructive,
        'bg':
            (robotProvider.isConnected
                    ? AppColors.success
                    : AppColors.destructive)
                .withValues(alpha: 0.1),
      },
      {
        'label': 'Lượt hoàn thành',
        'value': '$totalCompleted',
        'icon': Icons.check_circle_outline,
        'color': AppColors.tech,
        'bg': AppColors.tech.withValues(alpha: 0.1),
      },
      {
        'label': 'Lượt lỗi / hủy',
        'value': '$totalError',
        'icon': Icons.error_outline,
        'color': AppColors.destructive,
        'bg': AppColors.destructive.withValues(alpha: 0.1),
      },
    ];

    Widget buildKpiCard(Map<String, dynamic> kpi) {
      final isCalli = kpi['isCalli'] == true;
      return CustomCard(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 38.0,
              width: 38.0,
              decoration: BoxDecoration(
                color: kpi['bg'] as Color,
                borderRadius: AppStyles.radiusSm,
              ),
              child: Icon(
                kpi['icon'] as IconData,
                color: kpi['color'] as Color,
                size: 20.0,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              kpi['label'] as String,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              kpi['value'] as String,
              style: isCalli
                  ? AppStyles.calligraphyStyle.copyWith(fontSize: 28.0)
                  : const TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
            ),
          ],
        ),
      );
    }

    // 2. Bar Chart từ lịch sử thật (top 6 chữ)
    final sortedChars = charCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final barChartItems = sortedChars.take(6).map((e) {
      return {'char': e.key, 'val': e.value};
    }).toList();
    final double maxBarVal = barChartItems.isEmpty
        ? 1.0
        : (barChartItems.first['val'] as num).toDouble();

    Widget buildBarRow(Map<String, dynamic> item) {
      final val = item['val'] as int;
      final percentWidth = maxBarVal > 0 ? val / maxBarVal : 0.0;

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            SizedBox(
              width: 44.0,
              child: Text(
                item['char'] as String,
                style: AppStyles.calligraphyStyle.copyWith(
                  fontSize: 22.0,
                  height: 1.1,
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 24.0,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: percentWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.gold],
                          ),
                        ),
                        padding: const EdgeInsets.only(right: 12.0),
                        alignment: Alignment.centerRight,
                        child: Text(
                          '$val',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // 3. Diagnostics từ robot status thật
    final diagnosticDetails = [
      {
        'k': 'Kết nối',
        'v': robotProvider.isConnected ? 'Đã kết nối' : 'Ngoại tuyến',
      },
      {'k': 'Robot IP', 'v': robotProvider.robotIp},
      {'k': 'Chế độ', 'v': 'Tự động'},
      {
        'k': 'TCP Pose X',
        'v': robotProvider.tcpPose.isNotEmpty
            ? '${(robotProvider.tcpPose[0] as num).toStringAsFixed(1)} mm'
            : '—',
      },
      {
        'k': 'TCP Pose Y',
        'v': robotProvider.tcpPose.length > 1
            ? '${(robotProvider.tcpPose[1] as num).toStringAsFixed(1)} mm'
            : '—',
      },
    ];

    Widget buildDiagnosticItem(Map<String, String> row) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.border, width: 1.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              row['k']!,
              style: TextStyle(fontSize: 13.0, color: AppColors.muted),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 3.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppStyles.radiusSm,
              ),
              child: Text(
                row['v']!,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Log actions từ lịch sử thật (5 gần nhất)
    final recentLogs = logs.take(5).toList();

    Widget buildLogLine(Map<String, dynamic> log) {
      final status = log['status']?.toString() ?? '';
      final isSuccess = status == 'Hoàn thành';
      final isActive = status == 'Đang viết';
      final color = isSuccess
          ? AppColors.success
          : isActive
          ? AppColors.warning
          : AppColors.destructive;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          children: [
            SizedBox(
              width: 50.0,
              child: Text(
                log['time']?.toString() ?? '--:--',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 11.5,
                  color: AppColors.muted,
                ),
              ),
            ),
            Container(
              height: 6.0,
              width: 6.0,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                'Robot đã viết chữ ${log['char']} · $status',
                style: const TextStyle(fontSize: 13.0, color: AppColors.ink),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dashboard Robot Ông Đồ',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 2.0),
        Text(
          'Tổng quan hoạt động robot viết thư pháp hôm nay',
          style: TextStyle(fontSize: 13.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),

        // Grid metrics view
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isDesktop ? 5 : (isTablet ? 3 : 2),
            crossAxisSpacing: 14.0,
            mainAxisSpacing: 14.0,
            childAspectRatio: 1.3,
          ),
          itemCount: kpiStats.length,
          itemBuilder: (context, index) => buildKpiCard(kpiStats[index]),
        ),
        const SizedBox(height: 24.0),

        // Charts & Telemetry panel split
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thống kê lượt chọn theo từng chữ',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Số lượt sinh viên chọn mỗi chữ trong phiên này.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      if (barChartItems.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24.0),
                            child: Text(
                              'Chưa có dữ liệu thống kê',
                              style: TextStyle(
                                fontSize: 13.0,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: barChartItems.map(buildBarRow).toList(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24.0),
              Expanded(
                flex: 4,
                child: CustomCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Trạng thái robot',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Column(
                        children: diagnosticDetails
                            .map(buildDiagnosticItem)
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else ...[
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê lượt chọn theo từng chữ',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16.0),
                if (barChartItems.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Chưa có dữ liệu thống kê',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                  )
                else
                  Column(children: barChartItems.map(buildBarRow).toList()),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trạng thái robot',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16.0),
                Column(
                  children: diagnosticDetails.map(buildDiagnosticItem).toList(),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24.0),

        // Bottom log console panel
        CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hoạt động gần đây',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 14.0),
              if (recentLogs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: Text(
                      'Chưa có hoạt động nào trong phiên này',
                      style: TextStyle(fontSize: 13.0, color: AppColors.muted),
                    ),
                  ),
                )
              else
                Column(children: recentLogs.map(buildLogLine).toList()),
            ],
          ),
        ),
      ],
    );
  }
}
