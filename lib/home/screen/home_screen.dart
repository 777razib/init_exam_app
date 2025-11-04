
// Home Screen
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../model/repo_model.dart';
import '../../model/user_model.dart';
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
  final RxList<RepoModel> _repos = <RepoModel>[].obs; // Fixed: RxList
  final Rx<UserModel> _user = UserModel.empty().obs; // Fixed: Default
  final RxBool _isLoading = true.obs;
  final RxString _error = ''.obs;

  // Filters
  final RxString _filterBy = 'name'.obs;
  final Rx<DateTime?> _fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> _toDate = Rx<DateTime?>(null);

  @override
  void initState() {
    super.initState();
    _fetchUserAndRepos();
  }

  Future<void> _fetchUserAndRepos() async {
    _isLoading.value = true;
    await _fetchUser();
    await _fetchRepos();
    _isLoading.value = false;
  }

  Future<void> _fetchUser() async {
    try {
      final response = await _apiGet('https://api.github.com/users/${widget.username}');
      if (response.isSuccess) {
        _user.value = UserModel.fromJson(response.responseData!);
      } else {
        _error.value = 'User not found';
      }
    } catch (e) {
      _error.value = 'Network error';
    }
  }

  Future<void> _fetchRepos() async {
    try {
      final response = await _apiGet('https://api.github.com/users/${widget.username}/repos');
      if (response.isSuccess) {
        final List<dynamic> data = response.responseData!;
        _repos.value = data.map((repo) => RepoModel.fromJson(repo)).toList(); // Fixed: value =
      } else {
        _error.value = 'Failed to load repos';
      }
    } catch (e) {
      _error.value = 'Network error';
    }
  }

  Future<NetworkResponse> _apiGet(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final status = response.statusCode;
      if (status == 200) {
        final data = jsonDecode(response.body);
        return NetworkResponse(statusCode: status, isSuccess: true, responseData: data);
      } else {
        return NetworkResponse(
          statusCode: status,
          isSuccess: false,
          errorMessage: response.body,
        );
      }
    } catch (e) {
      return NetworkResponse(statusCode: -1, isSuccess: false, errorMessage: e.toString());
    }
  }

  List<RepoModel> _getFilteredRepos() {
    var repos = List<RepoModel>.from(_repos); // Copy
    final query = _searchController.text.toLowerCase();

    if (query.isNotEmpty) {
      repos = repos.where((r) => r.name.toLowerCase().contains(query)).toList();
    }

    final from = _fromDate.value;
    final to = _toDate.value;
    if (from != null) {
      repos = repos.where((r) => DateTime.parse(r.updatedAt).isAfter(from)).toList();
    }
    if (to != null) {
      repos = repos.where((r) => DateTime.parse(r.updatedAt).isBefore(to.add(const Duration(days: 1)))).toList();
    }

    switch (_filterBy.value) {
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

  Widget _buildUserInfo() {
    if (_error.value.isNotEmpty) {
      return Center(child: Text(_error.value, style: const TextStyle(color: Colors.red)));
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(_user.value.avatarUrl),
            ),
            const SizedBox(height: 12),
            Text(
              _user.value.name.isNotEmpty ? _user.value.name : widget.username,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (_user.value.bio.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_user.value.bio, style: const TextStyle(color: Colors.grey)),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Repos', _user.value.publicRepos.toString()),
                _buildStat('Followers', _user.value.followers.toString()),
                _buildStat('Following', _user.value.following.toString()),
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
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchUserAndRepos),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildUserInfo(),
            // Search & Filter
            Padding(
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
                      DropdownButton<String>(
                        value: _filterBy.value,
                        items: [
                          'name',
                          'updated',
                          'stars',
                        ].map((s) => DropdownMenuItem(value: s, child: Text(_capitalize(s)))).toList(),
                        onChanged: (v) => _filterBy.value = v!,
                      ),
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
            ),
            const SizedBox(height: 16),
            // Repo List/Grid
            Expanded(
              child: _buildRepoList(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRepoList() {
    final repos = _getFilteredRepos();
    if (repos.isEmpty) {
      return const Center(child: Text('No repositories found'));
    }

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
                  Text(
                    repo.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (repo.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      repo.description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Close')),
        ],
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
      _fromDate.value = picked.start;
      _toDate.value = picked.end;
      setState(() {});
    }
  }

  String _formatDate(String iso) {
    final date = DateTime.parse(iso);
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalize(String s) {
    return s[0].toUpperCase() + s.substring(1);
  }
}