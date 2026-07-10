class ActivityLogModel {
  final int id;
  final String actionType;
  final String description;
  final DateTime createdAt;

  ActivityLogModel({
    required this.id,
    required this.actionType,
    required this.description,
    required this.createdAt,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      id: json['id'],
      actionType: json['action_type'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }
}
