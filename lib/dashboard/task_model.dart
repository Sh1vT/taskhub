class Task {
  final int id;
  final String title;
  final String userId;
  final DateTime createdAt;
  final bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    this.isCompleted = false,
  });

  Task copyWith({
    int? id,
    String? title,
    String? userId,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      title: map['title'] as String,
      userId: map['user_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      isCompleted: map['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'is_completed': isCompleted,
    };
  }
}
