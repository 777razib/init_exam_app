import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cores/network_service.dart';
import '../../models/repo.dart';


enum SortBy { name, stars, created }

enum SortOrder { asc, desc }

class HomeController extends GetxController {
  final RxList<Repository> repos = <Repository>[].obs;
  final RxList<Repository> filtered = <Repository>[].obs;
  final RxBool isGrid = true.obs;
  final Rx<SortBy> sortBy = SortBy.name.obs;
  final Rx<SortOrder> order = SortOrder.asc.obs;
  final RxBool loading = true.obs;
  final RxString error = ''.obs;
  
  // Search and date filter
  final TextEditingController searchController = TextEditingController();
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final RxBool hasDateFilter = false.obs;

  String username = '';

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() => applyFilter());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadRepos(String user) async {
    username = user;
    loading.value = true;
    error.value = '';
    try {
      final list = await GitHubApi.getRepos(user);
      repos.assignAll(list);
      applyFilter();
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  void applyFilter() {
    var list = List<Repository>.from(repos);

    // ---- Search filter ----
    final searchQuery = searchController.text.toLowerCase().trim();
    if (searchQuery.isNotEmpty) {
      list = list.where((repo) {
        return repo.name.toLowerCase().contains(searchQuery) ||
            (repo.description.isNotEmpty && 
             repo.description.toLowerCase().contains(searchQuery)) ||
            (repo.language.isNotEmpty && 
             repo.language.toLowerCase().contains(searchQuery));
      }).toList();
    }

    // ---- Date filter ----
    if (fromDate.value != null) {
      list = list.where((repo) {
        return repo.updatedAt.isAfter(fromDate.value!) ||
            repo.updatedAt.isAtSameMomentAs(fromDate.value!);
      }).toList();
    }
    if (toDate.value != null) {
      list = list.where((repo) {
        final endDate = toDate.value!.add(const Duration(days: 1));
        return repo.updatedAt.isBefore(endDate);
      }).toList();
    }

    // ---- Sorting ----
    list.sort((a, b) {
      int cmp = 0;
      switch (sortBy.value) {
        case SortBy.name:
          cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case SortBy.stars:
          cmp = a.stargazersCount.compareTo(b.stargazersCount);
          break;
        case SortBy.created:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return order.value == SortOrder.asc ? cmp : -cmp;
    });

    filtered.assignAll(list);
  }

  void toggleView() => isGrid.value = !isGrid.value;

  Future<void> pickDateRange() async {
    final context = Get.context;
    if (context == null) return;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: fromDate.value != null && toDate.value != null
          ? DateTimeRange(start: fromDate.value!, end: toDate.value!)
          : null,
    );

    if (picked != null) {
      fromDate.value = picked.start;
      toDate.value = picked.end;
      hasDateFilter.value = true;
      applyFilter();
    } else {
      // Clear date filter if user cancels
      fromDate.value = null;
      toDate.value = null;
      hasDateFilter.value = false;
      applyFilter();
    }
  }

  void clearDateFilter() {
    fromDate.value = null;
    toDate.value = null;
    hasDateFilter.value = false;
    applyFilter();
  }
}
