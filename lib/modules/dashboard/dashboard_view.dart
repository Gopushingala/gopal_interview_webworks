import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gopal_interview_webworks/main.dart';
import 'package:gopal_interview_webworks/routes/app_routes.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/feed_item.dart';
import 'dashboard_controller.dart';
import 'widgets/feed_card.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(AppStrings.dashboardGreeting),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              indicatorColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelColor: Colors.white,
              tabs: [
                Tab(text: AppStrings.imageFeedTab),
                Tab(text: AppStrings.videoFeedTab),
              ],
            ),
            actions: [
              IconButton(
                onPressed: controller.refreshAllInsights,
                icon: Obx(
                  () => controller.isAiRefreshing.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.refresh),
                ),
                tooltip: 'Re-run AI insights',
              ),

              TextButton(
                  onPressed: () {
                    getStorage.write("isLoggedIn", false);
                    Get.offAllNamed(AppRoutes.login);
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.red, fontSize: 17),
                  ))
            ],
          ),
          body: TabBarView(
            children: [
              Obx(
                () => _FeedList(
                  items: controller.imageFeed,
                  currentSort: controller.imageSort.value,
                  onSortSelected: controller.updateImageSort,
                  insightBuilder: (item) {
                    return controller.aiInsights[item.id] ??
                        AppStrings.aiAnalyzing;
                  },
                  dateFormatter: controller.formatDate,
                  controller: controller,
                ),
              ),
              Obx(
                () => _FeedList(
                  items: controller.videoFeed,
                  currentSort: controller.videoSort.value,
                  onSortSelected: controller.updateVideoSort,
                  insightBuilder: (item) =>
                      controller.aiInsights[item.id] ?? AppStrings.aiAnalyzing,
                  dateFormatter: controller.formatDate,
                  controller: controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeedList extends StatelessWidget {
  const _FeedList({
    required this.items,
    required this.currentSort,
    required this.onSortSelected,
    required this.insightBuilder,
    required this.dateFormatter,
    required this.controller,
  });

  final List<FeedItem> items;
  final SortOption currentSort;
  final ValueChanged<SortOption> onSortSelected;
  final String Function(FeedItem item) insightBuilder;
  final String Function(DateTime date) dateFormatter;
  final DashboardController controller;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onSortSelected(currentSort),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SortBar(
              currentSort: currentSort,
              onSortSelected: onSortSelected,
            );
          }
          final item = items[index - 1];
          return Obx(
            () => FeedCard(
              item: item,
              uploadedLabel: dateFormatter(item.uploadedAt),
              aiInsight:
                  controller.aiInsights[item.id] ?? AppStrings.aiAnalyzing,
            ),
          );
        },
      ),
    );
  }
}

class _SortBar extends StatelessWidget {
  const _SortBar({
    required this.currentSort,
    required this.onSortSelected,
  });

  final SortOption currentSort;
  final ValueChanged<SortOption> onSortSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            AppStrings.sortBy,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text(AppStrings.sortByDate),
            selected: currentSort == SortOption.date,
            onSelected: (_) => onSortSelected(SortOption.date),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text(AppStrings.sortByName),
            selected: currentSort == SortOption.name,
            onSelected: (_) => onSortSelected(SortOption.name),
          ),
        ],
      ),
    );
  }
}
