enum RobotAction {
  connect,
  securePaper,
  dipInk,
  drawStroke,
  releasePaper,
  home,
  pause,
  emergencyStop,
}

enum CommandStatus {
  pending,
  executing,
  completed,
  failed,
}

class RobotCommand {
  final String id;
  final RobotAction action;
  final List<DrawingCoordinate>? coordinates; // Coordinates for standard drawing stroke actions
  final double speed; // Movement speed in mm/s
  final double pressure; // Pen pressure factor 0.0 - 1.0
  final DateTime timestamp;
  final CommandStatus status;
  final String? errorMessage;

  RobotCommand({
    required this.id,
    required this.action,
    this.coordinates,
    this.speed = 100.0,
    this.pressure = 0.5,
    DateTime? timestamp,
    this.status = CommandStatus.pending,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  RobotCommand copyWith({
    String? id,
    RobotAction? action,
    List<DrawingCoordinate>? coordinates,
    double? speed,
    double? pressure,
    DateTime? timestamp,
    CommandStatus? status,
    String? errorMessage,
  }) {
    return RobotCommand(
      id: id ?? this.id,
      action: action ?? this.action,
      coordinates: coordinates ?? this.coordinates,
      speed: speed ?? this.speed,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action.name,
      'coordinates': coordinates?.map((c) => c.toJson()).toList(),
      'speed': speed,
      'pressure': pressure,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'errorMessage': errorMessage,
    };
  }
}

class DrawingCoordinate {
  final double x;
  final double y;
  final double z; // Z axis controls height/contact: 0.0=up, 1.0=brush touch
  final double t; // Normalized time step along the stroke path

  const DrawingCoordinate({
    required this.x,
    required this.y,
    this.z = 0.0,
    this.t = 0.0,
  });

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'z': z, 't': t};
}
