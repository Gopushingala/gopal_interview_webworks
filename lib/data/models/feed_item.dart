enum FeedType { image, video }

class FeedItem {
  FeedItem({
    required this.id,
    required this.title,
    required this.caption,
    required this.mediaUrl,
    required this.uploadedAt,
    required this.type,
    this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String caption;
  final String mediaUrl;
  final DateTime uploadedAt;
  final FeedType type;
  final String? thumbnailUrl;
}


