import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/repo.dart';

class RepoDetailScreen extends StatelessWidget {
  final Repository repo;
  final String username;

  const RepoDetailScreen({super.key, required this.repo, required this.username});

  String _formatDate(DateTime date) => DateFormat.yMMMd().format(date);

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Cannot open $url', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(repo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: () => _launchURL(repo.htmlUrl),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 30, backgroundImage: NetworkImage(repo.ownerAvatar)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(repo.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('by $username', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
                Chip(label: Text(repo.isPrivate ? 'Private' : 'Public')),
              ],
            ),
            const Divider(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat(Icons.star, repo.stargazersCount, 'Stars', Colors.amber),
                _stat(Icons.fork_left, repo.forksCount, 'Forks', Colors.blue),
                _stat(Icons.visibility, repo.watchersCount, 'Watchers', Colors.purple),
              ],
            ),
            const Divider(height: 30),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(repo.description.isEmpty ? 'No description' : repo.description),
            const SizedBox(height: 20),
            _infoRow('Language', repo.language),
            _infoRow('Default Branch', repo.defaultBranch),
            _infoRow('Issues', '${repo.openIssuesCount}'),
            _infoRow('Created', _formatDate(repo.createdAt)),
            _infoRow('Updated', _formatDate(repo.updatedAt)),
            if (repo.homepage != null && repo.homepage!.isNotEmpty)
              _infoRow('Homepage', repo.homepage!, isLink: true, onTap: () => _launchURL(repo.homepage!)),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open on GitHub'),
              onPressed: () => _launchURL(repo.htmlUrl),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, int value, String label, Color color) => Column(
    children: [
      Icon(icon, size: 32, color: color),
      const SizedBox(height: 4),
      Text('$value', style: const TextStyle(fontSize: 20)),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ],
  );

  Widget _infoRow(String title, String value, {bool isLink = false, VoidCallback? onTap}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        SizedBox(width: 100, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: isLink
              ? GestureDetector(
            onTap: onTap,
            child: Text(value, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          )
              : Text(value),
        ),
      ],
    ),
  );
}