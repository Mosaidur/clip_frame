class WeeklyChecklistModel {
  final bool isFullDone;
  final List<ChecklistItem> checklist;

  WeeklyChecklistModel({required this.isFullDone, required this.checklist});

  factory WeeklyChecklistModel.fromJson(Map<String, dynamic> json) {
    return WeeklyChecklistModel(
      isFullDone: json['isFullDone'] ?? false,
      checklist: (json['checklist'] as List? ?? [])
          .map((item) => ChecklistItem.fromJson(item))
          .toList(),
    );
  }
}

class ChecklistItem {
  final String id;
  final String title;
  final String task;
  final int completed;
  final int target;
  final String description;
  final bool isDone;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.task,
    required this.completed,
    required this.target,
    required this.description,
    required this.isDone,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      task: json['task'] ?? '',
      completed: json['completed'] ?? 0,
      target: json['target'] ?? 1,
      description: json['description'] ?? '',
      isDone: json['isDone'] ?? false,
    );
  }

  double get progress => (completed / target).clamp(0.0, 1.0);
}
