import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'home/home_screen.dart';
import 'confirmation_screen.dart';
import 'robot_writing/robot_writing_screen.dart';
import 'completion_screen.dart';

class ProgressFlowScreen extends StatefulWidget {
  final Function(int)? onNavigateOutside;
  const ProgressFlowScreen({super.key, this.onNavigateOutside});

  @override
  State<ProgressFlowScreen> createState() => _ProgressFlowScreenState();
}

class _ProgressFlowScreenState extends State<ProgressFlowScreen> {
  int _currentStep = 0;

  void _setStep(int step) {
    if (step >= 0 && step < 4) {
      setState(() {
        _currentStep = step;
      });
    } else if (step == 4) {
      // Index 4 was history in old routing, here it might be index 2 or 3 in the new main routing
      widget.onNavigateOutside?.call(2); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> steps = [
      HomeScreen(onNavigate: _setStep),
      ConfirmationScreen(onNavigate: _setStep),
      RobotWritingScreen(onNavigate: _setStep),
      CompletionScreen(onNavigate: _setStep),
    ];

    return Column(
      children: [
        // Stepper
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _buildStepIndicator(0, "Chọn chữ"),
              _buildStepLine(0),
              _buildStepIndicator(1, "Xác nhận"),
              _buildStepLine(1),
              _buildStepIndicator(2, "Robot viết"),
              _buildStepLine(2),
              _buildStepIndicator(3, "Hoàn thành"),
            ],
          ),
        ),
        const SizedBox(height: 24),
        steps[_currentStep],
      ],
    );
  }

  Widget _buildStepIndicator(int stepIndex, String title) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;
    final color = isCompleted || isActive ? AppColors.primary : AppColors.muted;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? AppColors.primary : (isActive ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: isCompleted
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text(
                  "${stepIndex + 1}",
                  style: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.muted,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int stepIndex) {
    final isCompleted = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 2,
        color: isCompleted ? AppColors.primary : AppColors.border,
      ),
    );
  }
}
