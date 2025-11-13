import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_strings.dart';
import '../../core/services/api_service.dart';
import '../../data/models/feed_item.dart';

enum SortOption { name, date }

class DashboardController extends GetxController {
  DashboardController(this._apiService);

  final ApiService _apiService;

  final RxList<FeedItem> imageFeed = <FeedItem>[].obs;
  final RxList<FeedItem> videoFeed = <FeedItem>[].obs;
  final Rx<SortOption> imageSort = SortOption.date.obs;
  final Rx<SortOption> videoSort = SortOption.date.obs;
  final RxMap<String, String> aiInsights = <String, String>{}.obs;
  final RxBool isAiRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _seedFeeds();
    _applySort(imageFeed, imageSort.value);
    _applySort(videoFeed, videoSort.value);
    refreshAllInsights();
  }

  void updateImageSort(SortOption option) {
    if (imageSort.value == option) return;
    imageSort.value = option;
    _applySort(imageFeed, option);
  }

  void updateVideoSort(SortOption option) {
    if (videoSort.value == option) return;
    videoSort.value = option;
    _applySort(videoFeed, option);
  }

  Future<void> refreshAllInsights() async {
    isAiRefreshing.value = true;
    final allItems = <FeedItem>[
      ...imageFeed,
      ...videoFeed,
    ];

    for (final item in allItems) {
      aiInsights[item.id] = AppStrings.aiAnalyzing;
    }
    aiInsights.refresh(); // Force reactivity update

    await Future.wait(
      allItems.map(_analyzeCaption),
      eagerError: false,
    );
    isAiRefreshing.value = false;
  }

  String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy • hh:mm a').format(date);
  }

  Future<void> _analyzeCaption(FeedItem item) async {
    final insight = await _apiService.analyzeSentiment(item.caption);
    aiInsights[item.id] = insight;
    aiInsights.refresh();
  }


  Future<String> analyzeCaptionSentiment(String caption) async {
    return await _apiService.analyzeSentiment(caption);
  }

  Future<String> generateImageCaption(List<int> imageBytes) async {
    return await _apiService.generateImageCaption(imageBytes);
  }

  Future<String> generateImageCaptionFromFile(String imagePath) async {
    return await _apiService.generateImageCaptionFromFile(imagePath);
  }

  Future<String> summarizeVideoTitle(String title) async {
    return await _apiService.summarizeVideoTitle(title);
  }

  Future<String> summarizeText(String text, {int maxLength = 50}) async {
    return await _apiService.summarizeText(text, maxLength: maxLength);
  }


  void _applySort(RxList<FeedItem> feed, SortOption option) {
    switch (option) {
      case SortOption.name:
        feed.sort((a, b) => a.title.compareTo(b.title));
      case SortOption.date:
        feed.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
    }
    feed.refresh();
  }

  void _seedFeeds() {
    imageFeed.assignAll([
      FeedItem(
        id: 'img-1',
        title: 'Sunset Boulevard',
        caption: 'Golden hour painting the skyline with vibrant hues.',
        mediaUrl:
            'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 3)),
        type: FeedType.image,
      ),
      FeedItem(
        id: 'img-2',
        title: 'Mountain Escape',
        caption: 'Snow-capped peaks towering above the valley floor.',
        mediaUrl:
            'https://images.unsplash.com/photo-1470770903676-69b98201ea1c?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        type: FeedType.image,
      ),
      FeedItem(
        id: 'img-3',
        title: 'City Reflections',
        caption: 'Night lights shimmering across the river.',
        mediaUrl:
            'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2)),
        type: FeedType.image,
      ),
      FeedItem(
        id: 'img-4',
        title: 'Forest Trail',
        caption: 'Morning jog through the misty woodland path.',
        mediaUrl:
            'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
        type: FeedType.image,
      ),
      FeedItem(
        id: 'img-5',
        title: 'Coastal Breeze',
        caption: 'Waves crashing gently against the cliffs.',
        mediaUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 4, hours: 6)),
        type: FeedType.image,
      ),
    ]);

    videoFeed.assignAll([
      FeedItem(
        id: 'vid-1',
        title: 'Product Launch Recap',
        caption: 'Highlights from the WebWorks 2025 product keynote.',
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1551817958-20204d6ab1c8?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(hours: 22)),
        type: FeedType.video,
      ),
      FeedItem(
        id: 'vid-2',
        title: 'Behind the Scenes',
        caption: 'Creative process behind our latest campaign.',
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1521737604893-d14cc237f11d?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        type: FeedType.video,
      ),
      FeedItem(
        id: 'vid-3',
        title: 'Weekly Standup',
        caption: 'Rapid-fire updates from the engineering team.',
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1532074205216-d0e1f4b87368?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
        type: FeedType.video,
      ),
      FeedItem(
        id: 'vid-4',
        title: 'Design Review',
        caption: 'UI polish and interaction feedback session.',
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1487014679447-9f8336841d58?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 3, hours: 6)),
        type: FeedType.video,
      ),
      FeedItem(
        id: 'vid-5',
        title: 'Customer Spotlight',
        caption: 'Success story from a logistics partner using WebWorks.',
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=800&q=80',
        uploadedAt: DateTime.now().subtract(const Duration(days: 4, hours: 9)),
        type: FeedType.video,
      ),
    ]);
  }
}
