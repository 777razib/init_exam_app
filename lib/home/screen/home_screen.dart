// lib/feature/home/screen/home_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/repo_model.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RxBool _isGridView = true.obs;
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HomeController());
    controller.fetchUserAndRepos(widget.username);
  }

  List<RepoModel> _getFilteredRepos() {
    var repos = List<RepoModel>.from(controller.repos);
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      repos = repos.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    final from = controller.fromDate.value;
    final to = controller.toDate.value;
    if (from != null) {
      repos = repos.where((r) => DateTime.parse(r.updatedAt).isAfter(from)).toList();
    }
    if (to != null) {
      repos = repos.where((r) => DateTime.parse(r.updatedAt).isBefore(to.add(const Duration(days: 1)))).toList();
    }

    switch (controller.filterBy.value) {
      case 'updated':
        repos.sort((a, b) => DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));
        break;
      case 'stars':
        repos.sort((a, b) => b.stargazersCount.compareTo(a.stargazersCount));
        break;
      default:
        repos.sort((a, b) => a.name.compareTo(b.name));
    }

    return repos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub: ${widget.username}'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(_isGridView.value ? Icons.list : Icons.grid_view),
            onPressed: () => _isGridView.value = !_isGridView.value,
          )),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.fetchUserAndRepos(widget.username)),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(child: Text(controller.error.value, style: const TextStyle(color: Colors.red)));
        }

        return Column(
          children: [
            _buildUserInfo(),
            _buildSearchAndFilter(),
            const SizedBox(height: 16),
            Expanded(child: _buildRepoList()),
          ],
        );
      }),
    );
  }

  Widget _buildUserInfo() {
    final user = controller.user.value;
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.avatarUrl)),
            const SizedBox(height: 12),
            Text(
              user.name.isNotEmpty ? user.name : widget.username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (user.bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(user.bio, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Repos', user.publicRepos.toString()),
                _buildStat('Followers', user.followers.toString()),
                _buildStat('Following', user.following.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search repositories',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Obx(() => DropdownButton<String>(
                value: controller.filterBy.value,
                items: ['name', 'updated', 'stars']
                    .map((s) => DropdownMenuItem(value: s, child: Text(_capitalize(s))))
                    .toList(),
                onChanged: controller.updateFilter,
              )),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range, size: 16),
                label: const Text('Date'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRepoList() {
    final repos = _getFilteredRepos();
    if (repos.isEmpty) return const Center(child: Text('No repositories found'));

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _isGridView.value ? 2 : 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: _isGridView.value ? 1.8 : 3.5,
      ),
      itemCount: repos.length,
      itemBuilder: (context, index) {
        final repo = repos[index];
        return Card(
          child: InkWell(
            onTap: () => _showRepoDetails(repo),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(repo.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (repo.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(repo.description, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('${repo.stargazersCount}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRepoDetails(RepoModel repo) {
    Get.dialog(
      AlertDialog(
        title: Text(repo.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repo.description.isNotEmpty) Text(repo.description),
            const SizedBox(height: 8),
            Text('Stars: ${repo.stargazersCount}'),
            Text('Updated: ${_formatDate(repo.updatedAt)}'),
          ],
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Close'))],
      ),
    );
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.updateDateRange(picked.start, picked.end);
      setState(() {});
    }
  }

  String _formatDate(String iso) {
    final date = DateTime.parse(iso);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}