class MyContentsResponse {
  final int statusCode;
  final bool success;
  final String message;
  final ContentData data;

  MyContentsResponse({
    required this.statusCode,
    required this.success,
    required this.message,
    required this.data,
  });

  factory MyContentsResponse.fromJson(Map<String, dynamic> json) {
    return MyContentsResponse(
      statusCode: json['statusCode'] ?? 500,
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ContentData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ContentData {
  final Meta meta;
  final List<ContentItem> data;

  ContentData({
    required this.meta,
    required this.data,
  });

  factory ContentData.fromJson(Map<String, dynamic> json) {
    return ContentData(
      meta: Meta.fromJson(json['meta'] ?? {}),
      data: (json['data'] is List)
          ? (json['data'] as List)
              .map((item) => ContentItem.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meta': meta.toJson(),
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

class Meta {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  Meta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPages': totalPages,
    };
  }
}

class ContentItem {
  final ScheduledAt scheduledAt;
  final String id;
  final String templateId;
  final String caption;
  final List<String> mediaUrls;
  final String contentType;
  final bool remindMe;
  final String status;
  final User user;
  final List<String> platform;
  final List<String> tags;
  final List<dynamic> clips;
  final List<dynamic> stats;
  final Map<String, dynamic> platformStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ContentItem({
    required this.scheduledAt,
    required this.id,
    required this.templateId,
    required this.caption,
    required this.mediaUrls,
    required this.contentType,
    required this.remindMe,
    required this.status,
    required this.user,
    required this.platform,
    required this.tags,
    required this.clips,
    required this.stats,
    required this.platformStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    return ContentItem(
      scheduledAt: ScheduledAt.fromJson(json['scheduledAt'] ?? {}),
      id: json['_id'] ?? '',
      templateId: json['templateId'] ?? '',
      caption: json['caption'] ?? '',
      mediaUrls: json['mediaUrls'] != null ? List<String>.from(json['mediaUrls']) : [],
      contentType: json['contentType'] ?? '',
      remindMe: json['remindMe'] ?? false,
      status: json['status'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      platform: json['platform'] != null ? List<String>.from(json['platform']) : [],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      clips: json['clips'] ?? [],
      stats: json['stats'] ?? [],
      platformStatus: json['platformStatus'] ?? {},
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now() : DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduledAt': scheduledAt.toJson(),
      '_id': id,
      'templateId': templateId,
      'caption': caption,
      'mediaUrls': mediaUrls,
      'contentType': contentType,
      'remindMe': remindMe,
      'status': status,
      'user': user.toJson(),
      'platform': platform,
      'tags': tags,
      'clips': clips,
      'stats': stats,
      'platformStatus': platformStatus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class ScheduledAt {
  final String type;
  final DateTime date;
  final String time;

  ScheduledAt({
    required this.type,
    required this.date,
    required this.time,
  });

  factory ScheduledAt.fromJson(Map<String, dynamic> json) {
    return ScheduledAt(
      type: json['type'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) ?? DateTime.now() : DateTime.now(),
      time: json['time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'date': date.toIso8601String(),
      'time': time,
    };
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final bool verified;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.verified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'verified': verified,
    };
  }
}