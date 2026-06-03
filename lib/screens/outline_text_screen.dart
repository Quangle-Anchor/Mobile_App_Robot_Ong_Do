import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/robot_stream_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/trajectory_preview_card.dart';

class OutlineTextScreen extends StatefulWidget {
  const OutlineTextScreen({super.key});

  @override
  State<OutlineTextScreen> createState() => _OutlineTextScreenState();
}

class _OutlineTextScreenState extends State<OutlineTextScreen> {
  final TextEditingController _textController = TextEditingController();
  Map<String, dynamic>? _lastResult;
  bool _continuousText = false;
  double _textVelocity = 12;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final robotProvider = Provider.of<RobotStreamProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Viết chữ outline Times New Roman',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Nhập chữ từ bàn phím để tạo nét outline font Times New Roman trước khi cho robot viết.',
          style: TextStyle(fontSize: 14.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),
        _buildOutlineCommand(robotProvider),
        if (_lastResult != null) ...[
          const SizedBox(height: 24.0),
          TrajectoryPreviewCard(result: _lastResult!),
        ],
      ],
    );
  }

  Future<void> _previewOutline(RobotStreamProvider provider) async {
    final result = await provider.previewTypedText(
      _textController.text,
      continuous: _continuousText,
      outlineTimes: true,
    );
    if (!mounted) return;
    setState(() => _lastResult = result);
  }

  Future<void> _drawOutline(RobotStreamProvider provider) async {
    await provider.drawTypedText(
      _textController.text,
      continuous: _continuousText,
      vel: _textVelocity,
      outlineTimes: true,
    );
    if (!mounted) return;
    setState(() => _lastResult = provider.lastActionResult);
  }

  Widget _buildOutlineCommand(RobotStreamProvider provider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'OUTLINE FONT TIMES NEW ROMAN',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: AppColors.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _textController,
            enabled: !provider.isBusy,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Tâm, An, Phúc...',
              filled: true,
              fillColor: AppColors.secondary.withValues(alpha: 0.3),
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
          const SizedBox(height: 14.0),
          Wrap(
            spacing: 18.0,
            runSpacing: 10.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: _continuousText,
                    onChanged: provider.isBusy
                        ? null
                        : (value) => setState(() => _continuousText = value),
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                  ),
                  const Text('Viết liền nét'),
                ],
              ),
              SizedBox(
                width: 260.0,
                child: Row(
                  children: [
                    const Text('Tốc độ'),
                    Expanded(
                      child: Slider(
                        value: _textVelocity,
                        min: 5,
                        max: 30,
                        divisions: 25,
                        label: _textVelocity.toStringAsFixed(0),
                        onChanged: provider.isBusy
                            ? null
                            : (value) => setState(() => _textVelocity = value),
                      ),
                    ),
                    Text(_textVelocity.toStringAsFixed(0)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 12.0,
            runSpacing: 10.0,
            children: [
              OutlinedButton.icon(
                onPressed: provider.isBusy
                    ? null
                    : () => _previewOutline(provider),
                icon: const Icon(Icons.visibility_outlined, size: 16.0),
                label: const Text('Preview outline'),
              ),
              ElevatedButton.icon(
                onPressed: provider.isBusy
                    ? null
                    : () => _drawOutline(provider),
                icon: provider.isBusy
                    ? const SizedBox(
                        width: 15.0,
                        height: 15.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : const Icon(Icons.title, size: 16.0),
                label: const Text('Cho robot viết outline'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
