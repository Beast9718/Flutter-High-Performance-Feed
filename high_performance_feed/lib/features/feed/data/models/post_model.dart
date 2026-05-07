class PostModel {
  final String id;
  final DateTime createdAt;
  final String mediaThumbUrl;
  final String mediaMobileUrl;
  final String mediaRawUrl;
  final int likeCount;
  final bool isLiked;

  const PostModel({
    required this.id,
    required this.createdAt,
    required this.mediaThumbUrl,
    required this.mediaMobileUrl,
    required this.mediaRawUrl,
    this.likeCount = 0,
    this.isLiked = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      mediaThumbUrl: json['media_thumb_url'] as String,
      mediaMobileUrl: json['media_mobile_url'] as String,
      mediaRawUrl: json['media_raw_url'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'media_thumb_url': mediaThumbUrl,
      'media_mobile_url': mediaMobileUrl,
      'media_raw_url': mediaRawUrl,
      'like_count': likeCount,
      'is_liked': isLiked,
    };
  }

  PostModel copyWith({
    String? id,
    DateTime? createdAt,
    String? mediaThumbUrl,
    String? mediaMobileUrl,
    String? mediaRawUrl,
    int? likeCount,
    bool? isLiked,
  }) {
    return PostModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      mediaThumbUrl: mediaThumbUrl ?? this.mediaThumbUrl,
      mediaMobileUrl: mediaMobileUrl ?? this.mediaMobileUrl,
      mediaRawUrl: mediaRawUrl ?? this.mediaRawUrl,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
