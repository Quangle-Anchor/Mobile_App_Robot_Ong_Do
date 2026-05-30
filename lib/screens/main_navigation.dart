import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/robot_stream_provider.dart';
import 'progress_flow_screen.dart';
import 'shape_drawing_screen.dart';
import 'history_screen.dart';
import 'dashboard_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Navigates directly to any screen by index
  void setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Get screen headers/titles
  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return "Tiến trình viết";
      case 1:
        return "Vẽ hình";
      case 2:
        return "Lịch sử viết thư pháp";
      case 3:
        return "Dashboard CalliBot";
      case 4:
        return "Cài đặt hệ thống";
      default:
        return "CalliBot";
    }
  }

  @override
  Widget build(BuildContext context) {
    final robotProvider = Provider.of<RobotStreamProvider>(context);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    
    // Screens list
    final List<Widget> screens = [
      ProgressFlowScreen(onNavigateOutside: setIndex),
      const ShapeDrawingScreen(),
      const HistoryScreen(),
      const DashboardScreen(),
      const SettingsScreen(),
    ];

    // Navigation Menu Items mapping AppLayout.tsx
    final List<Map<String, dynamic>> menuItems = [
      {"label": "Tiến trình viết", "icon": Icons.timeline},
      {"label": "Vẽ hình", "icon": Icons.category_outlined},
      {"label": "Lịch sử", "icon": Icons.history_rounded},
      {"label": "Dashboard", "icon": Icons.dashboard_outlined},
      {"label": "Cài đặt", "icon": Icons.settings_outlined},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // Desktop sidebar (Left side navigation)
          if (isDesktop)
            Container(
              width: 250.0,
              color: AppColors.sidebar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Title & Header Logo
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                    child: Row(
                      children: [
                        Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: AppStyles.radiusMd,
                          ),
                          child: const Icon(Icons.brush, color: AppColors.sidebar, size: 22.0),
                        ),
                        const SizedBox(width: 12.0),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CalliBot",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.sidebarForeground,
                              ),
                            ),
                            Text(
                              "ROBOT VIẾT THƯ PHÁP",
                              style: TextStyle(
                                fontSize: 9.0,
                                color: Colors.white54,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.sidebarBorder, height: 1.0),
                  const SizedBox(height: 12.0),
                  
                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        final isSelected = _currentIndex == index;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 2.0),
                          child: InkWell(
                            onTap: () => setIndex(index),
                            borderRadius: AppStyles.radiusSm,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.sidebarAccent : Colors.transparent,
                                borderRadius: AppStyles.radiusSm,
                                border: isSelected 
                                    ? const Border(left: BorderSide(color: AppColors.gold, width: 3.0))
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    color: isSelected ? AppColors.gold : Colors.white70,
                                    size: 20.0,
                                  ),
                                  const SizedBox(width: 14.0),
                                  Text(
                                    item['label'] as String,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? AppColors.sidebarAccentForeground : Colors.white70,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Footer Versioning
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "v1.0 · Flutter Mobile",
                      style: TextStyle(fontSize: 10.0, color: Colors.white24),
                    ),
                  ),
                ],
              ),
            ),
            
          // Main Body Wrapper containing AppBar and Page Screens
          Expanded(
            child: Column(
              children: [
                // Premium Styled Custom Header/AppBar
                Container(
                  height: 72.0,
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    border: Border(bottom: BorderSide(color: AppColors.border, width: 1.0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Screen title & Robot status badge
                      Row(
                        children: [
                          if (!isDesktop) ...[
                            IconButton(
                              icon: const Icon(Icons.menu, color: AppColors.ink),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                            const SizedBox(width: 8.0),
                          ],
                          Text(
                            _getScreenTitle(_currentIndex),
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: robotProvider.isConnected
                                  ? AppColors.success.withValues(alpha: 0.12)
                                  : AppColors.destructive.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  height: 6.0,
                                  width: 6.0,
                                  decoration: BoxDecoration(
                                    color: robotProvider.isConnected ? AppColors.success : AppColors.destructive,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  robotProvider.isConnected ? "Robot: Sẵn sàng" : "Robot: Ngoại tuyến",
                                  style: TextStyle(
                                    fontSize: 10.0,
                                    fontWeight: FontWeight.bold,
                                    color: robotProvider.isConnected ? AppColors.success : AppColors.destructive,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      // Event details / Admin status info
                      Row(
                        children: [
                          if (isDesktop) ...[
                            Text(
                              "Sự kiện: ",
                              style: TextStyle(fontSize: 12.0, color: AppColors.muted),
                            ),
                            Text(
                              robotProvider.eventName,
                              style: const TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: AppColors.ink),
                            ),
                            const SizedBox(width: 24.0),
                          ],
                          
                          // Notification Bell
                          Stack(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_none, color: AppColors.muted),
                                onPressed: () {},
                              ),
                              Positioned(
                                top: 12.0,
                                right: 12.0,
                                child: Container(
                                  height: 6.0,
                                  width: 6.0,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 8.0),
                          
                          // User Avatar info
                          Row(
                            children: [
                              Container(
                                height: 36.0,
                                width: 36.0,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  "QT",
                                  style: TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                                ),
                              ),
                              if (isDesktop) ...[
                                const SizedBox(width: 10.0),
                                const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Quản trị viên",
                                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.ink),
                                    ),
                                    Text(
                                      "Admin",
                                      style: TextStyle(fontSize: 10.0, color: AppColors.secondaryText),
                                    ),
                                  ],
                                ),
                              ]
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Screen content loader
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: screens[_currentIndex],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      // Mobile Drawer (Left sidebar fallback)
      drawer: !isDesktop
          ? Drawer(
              backgroundColor: AppColors.sidebar,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: AppColors.sidebar),
                    child: Row(
                      children: [
                        Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: AppStyles.radiusMd,
                          ),
                          child: const Icon(Icons.brush, color: AppColors.sidebar, size: 22.0),
                        ),
                        const SizedBox(width: 12.0),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "CalliBot",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.sidebarForeground,
                              ),
                            ),
                            Text(
                              "ROBOT VIẾT THƯ PHÁP",
                              style: TextStyle(
                                fontSize: 9.0,
                                color: Colors.white54,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final item = menuItems[index];
                        final isSelected = _currentIndex == index;
                        return ListTile(
                          onTap: () {
                            setIndex(index);
                            Navigator.of(context).pop();
                          },
                          leading: Icon(
                            item['icon'] as IconData,
                            color: isSelected ? AppColors.gold : Colors.white70,
                          ),
                          title: Text(
                            item['label'] as String,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? AppColors.sidebarAccentForeground : Colors.white70,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: AppColors.sidebarAccent,
                          shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusSm),
                        );
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "v1.0 · Flutter Mobile",
                      style: TextStyle(fontSize: 10.0, color: Colors.white24),
                    ),
                  ),
                ],
              ),
            )
          : null,
      
      // Mobile Bottom Bar fallback
      bottomNavigationBar: !isDesktop
          ? BottomNavigationBar(
              currentIndex: _currentIndex >= 4 ? 3 : _currentIndex, // Collapse complex views on mobile bottom bar
              onTap: (index) {
                setIndex(index);
              },
              backgroundColor: AppColors.card,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.muted,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0),
              unselectedLabelStyle: const TextStyle(fontSize: 11.0),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.timeline), label: "Thực hiện"),
                BottomNavigationBarItem(icon: Icon(Icons.category_outlined), label: "Vẽ hình"),
                BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "Lịch sử"),
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Dashboard"),
              ],
            )
          : null,
    );
  }
}
