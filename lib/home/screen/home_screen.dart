import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../cores/theme_controller.dart';
import '../../models/repo.dart';
import '../../models/user.dart';
import '../controller/home_controller.dart';
import '../../report/screen/report_screen.dart';


class HomeScreen extends StatelessWidget {
  final GitHubUser user;
  final _ctrl = Get.put(HomeController());
  final _theme = Get.find<ThemeController>();

  HomeScreen({super.key, required this.user}) {
    _ctrl.loadRepos(user.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(user.login),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _ctrl.loadRepos(user.login),
          ),
          Obx(
            () => IconButton(
              icon: Icon(
                _theme.isDark.value ? Icons.light_mode : Icons.dark_mode,
              ),
              onPressed: _theme.toggle,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ---- User card ----
          Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: user.avatarUrl.isEmpty
                    ? const Icon(Icons.person)
                    : null,
                onBackgroundImageError: (_, __) {},
              ),
              title: Text(user.name.isEmpty ? user.login : user.name),
              subtitle: Text(user.bio.isEmpty ? 'No bio' : user.bio),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user.publicRepos}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'repos',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // ---- Search and Filters ----
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _ctrl.searchController,
                  decoration: InputDecoration(
                    hintText: 'Search repositories...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (_) => _ctrl.applyFilter(),
                ),
                const SizedBox(height: 8),
                // Controls row
                Row(
                  children: [
                    // View toggle
                    Obx(
                      () => IconButton(
                        icon: Icon(
                          _ctrl.isGrid.value ? Icons.grid_view : Icons.list,
                        ),
                        onPressed: _ctrl.toggleView,
                        tooltip: _ctrl.isGrid.value ? 'List View' : 'Grid View',
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Sort dropdown
                    Obx(() => DropdownButton<SortBy>(
                      value: _ctrl.sortBy.value,
                      items: const [
                        DropdownMenuItem(value: SortBy.name, child: Text('Name')),
                        DropdownMenuItem(value: SortBy.stars, child: Text('Stars')),
                        DropdownMenuItem(
                          value: SortBy.created,
                          child: Text('Created'),
                        ),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          _ctrl.sortBy.value = v;
                          _ctrl.applyFilter();
                        }
                      },
                    )),
                    const SizedBox(width: 8),
                    // Sort order
                    Obx(() => IconButton(
                      icon: Icon(
                        _ctrl.order.value == SortOrder.asc
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                      ),
                      onPressed: () {
                        _ctrl.order.value = _ctrl.order.value == SortOrder.asc
                            ? SortOrder.desc
                            : SortOrder.asc;
                        _ctrl.applyFilter();
                      },
                      tooltip: _ctrl.order.value == SortOrder.asc ? 'Ascending' : 'Descending',
                    )),
                    const Spacer(),
                    // Date filter
                    Obx(() => ElevatedButton.icon(
                      onPressed: _ctrl.pickDateRange,
                      icon: const Icon(Icons.date_range, size: 16),
                      label: Text(
                        _ctrl.hasDateFilter.value ? 'Date ✓' : 'Date',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    )),
                  ],
                ),
              ],
            ),
          ),

          // ---- Error display ----
          Obx(() {
            if (_ctrl.error.value.isNotEmpty) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _ctrl.error.value,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => _ctrl.error.value = '',
                      color: Colors.red,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // ---- Repo list / grid ----
          Expanded(
            child: Obx(() {
              if (_ctrl.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_ctrl.filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _ctrl.searchController.text.isNotEmpty
                            ? 'No repositories found matching "${_ctrl.searchController.text}"'
                            : 'No repositories',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              if (_ctrl.isGrid.value) {
                return GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _ctrl.filtered.length,
                  itemBuilder: (_, i) => _repoCard(_ctrl.filtered[i]),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _ctrl.filtered.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _repoTile(_ctrl.filtered[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _repoCard(Repository r) => InkWell(
    onTap: () => Get.to(() => RepoDetailScreen(repo: r)),
    borderRadius: BorderRadius.circular(12),
    child: Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: r.ownerAvatar.isNotEmpty
                  ? NetworkImage(r.ownerAvatar)
                  : null,
              child: r.ownerAvatar.isEmpty
                  ? const Icon(Icons.person)
                  : null,
              onBackgroundImageError: (_, __) {},
            ),
            title: Text(
              r.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(r.language),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${r.stargazersCount}'),
              ],
            ),
          ),
          if (r.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                r.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created ${DateFormat.yMMMd().format(r.createdAt)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (r.isPrivate)
                  const Icon(Icons.lock, size: 14, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _repoTile(Repository r) => Card(
    elevation: 1,
    child: ListTile(
      leading: CircleAvatar(
        backgroundImage: r.ownerAvatar.isNotEmpty
            ? NetworkImage(r.ownerAvatar)
            : null,
        child: r.ownerAvatar.isEmpty
            ? const Icon(Icons.person)
            : null,
        onBackgroundImageError: (_, __) {},
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              r.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (r.isPrivate)
            const Icon(Icons.lock, size: 16, color: Colors.orange),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r.description.isNotEmpty)
            Text(
              r.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (r.language.isNotEmpty && r.language != 'N/A')
                Chip(
                  label: Text(
                    r.language,
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              const Spacer(),
              Text(
                'Updated ${DateFormat.yMMMd().format(r.updatedAt)}',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 18, color: Colors.amber),
          const SizedBox(width: 4),
          Text('${r.stargazersCount}'),
          const SizedBox(width: 12),
          const Icon(Icons.call_split, size: 18, color: Colors.blue),
          const SizedBox(width: 4),
          Text('${r.forksCount}'),
        ],
      ),
      onTap: () => Get.to(() => RepoDetailScreen(repo: r)),
      isThreeLine: r.description.isNotEmpty,
    ),
  );
}

