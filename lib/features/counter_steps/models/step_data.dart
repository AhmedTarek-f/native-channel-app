class StepData {
  final int steps;
  final DateTime timestamp;
  final String sensorType;
  final String accuracy;

  StepData({
    required this.steps,
    required this.timestamp,
    required this.sensorType,
    required this.accuracy,
  });

  factory StepData.fromMap(Map<String, dynamic> map) {
    return StepData(
      steps: map['steps'] as int? ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch
      ),
      sensorType: map['sensor_type'] as String? ?? 'unknown',
      accuracy: map['accuracy'] as String? ?? 'medium',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'sensor_type': sensorType,
      'accuracy': accuracy,
    };
  }
}