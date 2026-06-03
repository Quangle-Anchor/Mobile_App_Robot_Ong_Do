import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../providers/robot_stream_provider.dart';
import '../widgets/custom_card.dart';
import '../widgets/trajectory_preview_card.dart';

class ShapeDrawingScreen extends StatefulWidget {
  const ShapeDrawingScreen({super.key});

  @override
  State<ShapeDrawingScreen> createState() => _ShapeDrawingScreenState();
}

class _ShapeDrawingScreenState extends State<ShapeDrawingScreen> {
  final TextEditingController _textController = TextEditingController();
  Map<String, dynamic>? _lastResult;
  bool _continuousText = false;
  double _textVelocity = 12;
  double _shapeVelocity = 20;

  final List<_ShapeAction> _shapeActions = const [
    _ShapeAction('Hình tròn', 'circle', Icons.circle_outlined),
    _ShapeAction('Hình vuông', 'square', Icons.square_outlined),
    _ShapeAction('Hình chữ nhật', 'rectangle', Icons.crop_16_9_outlined),
    _ShapeAction('Hình tam giác', 'triangle', Icons.change_history),
    _ShapeAction('Nét ngang', 'line_horizontal', Icons.horizontal_rule),
    _ShapeAction('Nét dọc', 'line_vertical', Icons.more_vert),
    _ShapeAction('Chéo xuống', 'line_diagonal_down', Icons.south_east),
    _ShapeAction('Chéo lên', 'line_diagonal_up', Icons.north_east),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _setShapeVelocity(double value) {
    setState(() => _shapeVelocity = value);
  }

  @override
  Widget build(BuildContext context) {
    final robotProvider = Provider.of<RobotStreamProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final columns = isDesktop ? 4 : (width >= 640 ? 2 : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kiểu vẽ hình và viết chữ nhập từ bàn phím',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          'Nhập chữ theo cấu hình hiện tại hoặc chọn hình cơ bản để gửi trực tiếp đến backend robot-ong-do.',
          style: TextStyle(fontSize: 14.0, color: AppColors.muted),
        ),
        const SizedBox(height: 24.0),
        _buildTextCommand(robotProvider),
        const SizedBox(height: 24.0),
        _buildShapeToolbar(robotProvider),
        const SizedBox(height: 16.0),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: isDesktop ? 1.25 : 1.55,
          ),
          itemCount: _shapeActions.length,
          itemBuilder: (context, index) {
            return _buildShapeCard(robotProvider, _shapeActions[index]);
          },
        ),
        if (_lastResult != null) ...[
          const SizedBox(height: 24.0),
          _buildLastResult(_lastResult!),
        ],
      ],
    );
  }

  Future<void> _captureLastResult(
    RobotStreamProvider provider,
    Future<void> Function() action,
  ) async {
    await action();
    if (!mounted) return;
    setState(() => _lastResult = provider.lastActionResult);
  }

  Future<void> _previewText(RobotStreamProvider provider) async {
    final result = await provider.previewTypedText(
      _textController.text,
      continuous: _continuousText,
      outlineTimes: false,
    );
    if (!mounted) return;
    setState(() => _lastResult = result);
  }

  Widget _buildTextCommand(RobotStreamProvider provider) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VIẾT CHỮ NHẬP TỪ BÀN PHÍM',
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
                    : () => _previewText(provider),
                icon: const Icon(Icons.visibility_outlined, size: 16.0),
                label: const Text('Preview đường viết'),
              ),
              ElevatedButton.icon(
                onPressed: provider.isBusy
                    ? null
                    : () => _captureLastResult(
                        provider,
                        () => provider.drawTypedText(
                          _textController.text,
                          continuous: _continuousText,
                          vel: _textVelocity,
                          outlineTimes: false,
                        ),
                      ),
                icon: provider.isBusy
                    ? const SizedBox(
                        width: 15.0,
                        height: 15.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                    : const Icon(Icons.brush_outlined, size: 16.0),
                label: const Text('Cho robot viết'),
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

  Widget _buildShapeToolbar(RobotStreamProvider provider) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hình cơ bản',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12.0),
          Wrap(
            spacing: 14.0,
            runSpacing: 12.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Tốc độ vẽ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              ChoiceChip(
                label: const Text('Chậm 10'),
                selected: _shapeVelocity == 10,
                onSelected: provider.isBusy
                    ? null
                    : (_) => _setShapeVelocity(10),
              ),
              ChoiceChip(
                label: const Text('Vừa 20'),
                selected: _shapeVelocity == 20,
                onSelected: provider.isBusy
                    ? null
                    : (_) => _setShapeVelocity(20),
              ),
              ChoiceChip(
                label: const Text('Nhanh 30'),
                selected: _shapeVelocity == 30,
                onSelected: provider.isBusy
                    ? null
                    : (_) => _setShapeVelocity(30),
              ),
              SizedBox(
                width: 300.0,
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _shapeVelocity,
                        min: 5,
                        max: 40,
                        divisions: 35,
                        label: _shapeVelocity.toStringAsFixed(0),
                        onChanged: provider.isBusy ? null : _setShapeVelocity,
                      ),
                    ),
                    Container(
                      width: 44.0,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppStyles.radiusSm,
                      ),
                      child: Text(
                        _shapeVelocity.toStringAsFixed(0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShapeCard(RobotStreamProvider provider, _ShapeAction action) {
    return CustomCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(action.icon, size: 46.0, color: AppColors.primary),
          const SizedBox(height: 12.0),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            action.backendName,
            style: TextStyle(fontSize: 11.0, color: AppColors.muted),
          ),
          const SizedBox(height: 14.0),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              IconButton.outlined(
                tooltip: 'Preview',
                onPressed: provider.isBusy
                    ? null
                    : () async {
                        final result = await provider.previewShape(
                          action.backendName,
                        );
                        if (!mounted) return;
                        setState(() => _lastResult = result);
                      },
                icon: const Icon(Icons.visibility_outlined, size: 18.0),
              ),
              ElevatedButton.icon(
                onPressed: provider.isBusy
                    ? null
                    : () => _captureLastResult(
                        provider,
                        () => provider.drawShapeByName(
                          action.backendName,
                          vel: _shapeVelocity,
                        ),
                      ),
                icon: const Icon(Icons.play_arrow_rounded, size: 17.0),
                label: const Text('Vẽ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tech,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastResult(Map<String, dynamic> result) {
    return TrajectoryPreviewCard(result: result);
  }
}

class _ShapeAction {
  final String label;
  final String backendName;
  final IconData icon;

  const _ShapeAction(this.label, this.backendName, this.icon);
}
