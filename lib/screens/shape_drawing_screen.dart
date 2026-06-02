import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_card.dart';

class ShapeDrawingScreen extends StatelessWidget {
  const ShapeDrawingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vẽ hình cơ bản",
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: AppColors.ink),
        ),
        const SizedBox(height: 8.0),
        const Text(
          "Chọn một hình khối cơ bản để robot vẽ.",
          style: TextStyle(fontSize: 14.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width >= 1024 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.2,
          children: [
            _buildShapeCard("Hình tròn", Icons.circle_outlined),
            _buildShapeCard("Hình vuông", Icons.square_outlined),
            _buildShapeCard("Hình tam giác", Icons.change_history),
            _buildShapeCard("Hình elip", Icons.egg_outlined),
          ],
        )
      ],
    );
  }

  Widget _buildShapeCard(String name, IconData icon) {
    return CustomCard(
      child: InkWell(
        onTap: () {
          // Add interaction logic later
        },
        borderRadius: BorderRadius.circular(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64.0, color: AppColors.primary),
            const SizedBox(height: 16.0),
            Text(
              name,
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
