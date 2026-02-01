class ContentTemplateModel {
  final String? id;
  final String? title;
  final String? description;
  final String? type;
  final String? category;
  final String? thumbnail;
  final List<TemplateStep>? steps;
  final List<String>? hashtags;
  final bool? isActive;
  final TemplateStats? stats;
  final CreatedBy? createdBy;
  final String? createdAt;
  final String? updatedAt;

  ContentTemplateModel({
    this.id,
    this.title,
    this.description,
    this.type,
    this.category,
    this.thumbnail,
    this.steps,
    this.hashtags,
    this.isActive,
    this.stats,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ContentTemplateModel.fromJson(Map<String, dynamic> json) {
    return ContentTemplateModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      category: json['category'],
      thumbnail: json['thumbnail'],
      steps: json['steps'] != null
          ? (json['steps'] as List)
                .map((i) => TemplateStep.fromJson(i))
                .toList()
          : null,
      hashtags: json['hashtags'] != null
          ? List<String>.from(json['hashtags'])
          : null,
      isActive: json['isActive'],
      stats: json['stats'] != null
          ? TemplateStats.fromJson(json['stats'])
          : null,
      createdBy: json['createdBy'] != null
          ? CreatedBy.fromJson(json['createdBy'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class TemplateStep {
  final String? id;
  final String? title;
  final String? description;
  final String? mediaType;
  final String? url;
  final String? shotType;
  final int? duration;

  TemplateStep({
    this.id,
    this.title,
    this.description,
    this.mediaType,
    this.url,
    this.shotType,
    this.duration,
  });

  factory TemplateStep.fromJson(Map<String, dynamic> json) {
    return TemplateStep(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      mediaType: json['mediaType'],
      url: json['url'],
      shotType: json['shotType'],
      duration: _toInt(json['duration']),
    );
  }
}

class TemplateStats {
  final int? loveCount;
  final int? reuseCount;
  final List<String>? lovedBy;

  TemplateStats({this.loveCount, this.reuseCount, this.lovedBy});

  factory TemplateStats.fromJson(Map<String, dynamic> json) {
    return TemplateStats(
      loveCount: _toInt(json['loveCount']),
      reuseCount: _toInt(json['reuseCount']),
      lovedBy: json['lovedBy'] != null
          ? List<String>.from(json['lovedBy'])
          : null,
    );
  }
}

class CreatedBy {
  final String? id;
  final String? name;
  final String? email;

  CreatedBy({this.id, this.name, this.email});

  factory CreatedBy.fromJson(Map<String, dynamic> json) {
    return CreatedBy(id: json['_id'], name: json['name'], email: json['email']);
  }
}

// Helper to safely parse int from dynamic (String or int)
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}
