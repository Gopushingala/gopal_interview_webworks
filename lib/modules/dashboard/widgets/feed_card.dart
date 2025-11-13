import 'package:flutter/material.dart';
import 'package:gopal_interview_webworks/modules/dashboard/widgets/video_player.dart';

import '../../../data/models/feed_item.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/constants/app_strings.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    required this.item,
    required this.uploadedLabel,
    required this.aiInsight,
    super.key,
  });

  final FeedItem item;
  final String uploadedLabel;
  final String aiInsight;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MediaPreview(item: item),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        item.type == FeedType.image ? 'Image' : 'Video',
                      ),
                      backgroundColor: AppColors.accent.withOpacity(0.2),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.caption,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  uploadedLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Divider(height: 24),
                Text(
                  AppStrings.aiInsightHeading,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  aiInsight,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  const _MediaPreview({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    final imageUrl = item.type == FeedType.video
        ? item.thumbnailUrl ?? ''
        : item.mediaUrl;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: borderRadius.topLeft,
        topRight: borderRadius.topRight,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (_, __, ___) => const _Placeholder(),
                  )
                : const _Placeholder(),
          ),
          if (item.type == FeedType.video)
            InkWell(
              onTap: () {
                print("object.............. ${item.mediaUrl}");
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => VlcVideoPlayer(videoUrl: item.mediaUrl,),));
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// class _MediaPreview extends StatelessWidget {
//   const _MediaPreview({required this.item});
//
//   final FeedItem item;
//
//   @override
//   Widget build(BuildContext context) {
//     final borderRadius = BorderRadius.circular(16);
//
//     if (item.type == FeedType.video) {
//       return ClipRRect(
//         borderRadius: BorderRadius.only(
//           topLeft: borderRadius.topLeft,
//           topRight: borderRadius.topRight,
//         ),
//         child: VlcVideoPlayer(videoUrl: item.mediaUrl),
//       );
//     }
//
//     final imageUrl = item.mediaUrl;
//     return ClipRRect(
//       borderRadius: BorderRadius.only(
//         topLeft: borderRadius.topLeft,
//         topRight: borderRadius.topRight,
//       ),
//       child: AspectRatio(
//         aspectRatio: 16 / 9,
//         child: imageUrl.isNotEmpty
//             ? Image.network(
//           imageUrl,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, progress) {
//             if (progress == null) return child;
//             return const Center(child: CircularProgressIndicator());
//           },
//           errorBuilder: (_, __, ___) => const _Placeholder(),
//         )
//             : const _Placeholder(),
//       ),
//     );
//   }
// }

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.border,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}



