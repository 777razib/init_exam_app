import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../cores/theme_controller.dart';
import '../../models/repo.dart';
import '../../models/user.dart';
import '../../repo_details/repo_details_screen.dart';
import '../controller/home_controller.dart';

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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(user.login),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _ctrl.loadRepos(user.login)),
          Obx(() => IconButton(
            icon: Icon(_theme.isDark.value ? Icons.light_mode : Icons.dark_mode),
            onPressed: _theme.toggle,
          )),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(user.avatarUrl), onBackgroundImageError: (_, __) {}),
                title: Text(user.name.isEmpty ? user.login : user.name),
                subtitle: Text(user.bio.isEmpty ? 'No bio' : user.bio),
                trailing: Text('${user.publicRepos} repos'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _ctrl.searchController,
                    decoration: InputDecoration(
                      hintText: 'Search repositories...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Obx(() => IconButton(icon: Icon(_ctrl.isGrid.value ? Icons.grid_view : Icons.list), onPressed: _ctrl.toggleView)),
                      Obx(() => DropdownButton<SortBy>(
                        value: _ctrl.sortBy.value,
                        items: const [
                          DropdownMenuItem(value: SortBy.name, child: Text('Name')),
                          DropdownMenuItem(value: SortBy.stars, child: Text('Stars')),
                          DropdownMenuItem(value: SortBy.created, child: Text('Created')),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            _ctrl.sortBy.value = v;
                            _ctrl.applyFilter();
                          }
                        },
                      )),
                      Obx(() => IconButton(
                        icon: Icon(_ctrl.order.value == SortOrder.asc ? Icons.arrow_upward : Icons.arrow_downward),
                        onPressed: _ctrl.toggleSortOrder,
                      )),
                      const Spacer(),
                      Obx(() => ElevatedButton.icon(
                        onPressed: _ctrl.pickDateRange,
                        icon: const Icon(Icons.date_range, size: 16),
                        label: Text(_ctrl.hasDateFilter.value ? 'Date [Check]' : 'Date'),
                      )),
                      if (_ctrl.hasDateFilter.value)
                        IconButton(icon: const Icon(Icons.clear), onPressed: _ctrl.clearDateFilter),
                    ],
                  ),
                ],
              ),
            ),
            Obx(() => _ctrl.error.value.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Card(
                color: Colors.red.shade100,
                child: ListTile(
                  leading: const Icon(Icons.error, color: Colors.red),
                  title: Text(_ctrl.error.value),
                  trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => _ctrl.error.value = ''),
                ),
              ),
            )
                : const SizedBox.shrink()),
            Expanded(
              child: Obx(() {
                if (_ctrl.loading.value) return const Center(child: CircularProgressIndicator());
                if (_ctrl.filtered.isEmpty) return const Center(child: Text('No repositories'));

                return _ctrl.isGrid.value
                    ? GridView.builder(
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2, // Changed from 1.4 to 1.2
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _ctrl.filtered.length,
                  itemBuilder: (_, i) => _repoCard(_ctrl.filtered[i]),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _ctrl.filtered.length,
                  itemBuilder: (_, i) => _repoTile(_ctrl.filtered[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _repoCard(Repository r) => InkWell(
    onTap: () => Get.to(() => RepoDetailScreen(repo: r, username: _ctrl.username)),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundImage: NetworkImage(r.ownerAvatar)),
              title: Text(
                r.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(r.language),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [const Icon(Icons.star, size: 16), Text('${r.stargazersCount}')],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  r.description.isEmpty ? 'No description' : r.description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ),
            Text(
              'Updated: ${DateFormat.yMMMd().format(r.updatedAt)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _repoTile(Repository r) => ListTile(
    leading: CircleAvatar(backgroundImage: NetworkImage(r.ownerAvatar)),
    title: Text(r.name),
    subtitle: Text(r.description),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star),
        Text('${r.stargazersCount}'),
        const SizedBox(width: 8),
        const Icon(Icons.fork_left),
        Text('${r.forksCount}'),
      ],
    ),
    onTap: () => Get.to(() => RepoDetailScreen(repo: r, username: _ctrl.username)),
  );
}
