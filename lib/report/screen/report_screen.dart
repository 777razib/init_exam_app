import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../models/repo.dart';

class RepoDetailScreen extends StatelessWidget {
  final Repository repo;
  const RepoDetailScreen({super.key, required this.repo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(repo.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: repo.ownerAvatar.isNotEmpty
                      ? NetworkImage(repo.ownerAvatar)
                      : null,
                  child: repo.ownerAvatar.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                  onBackgroundImageError: (_, __) {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repo.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'by ${repo.ownerAvatar.split('/').reversed.elementAt(1)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat(Icons.star, repo.stargazersCount, 'Stars'),
                _stat(Icons.fork_left, repo.forksCount, 'Forks'),
                _stat(Icons.language, 1, repo.language),
              ],
            ),
            const Divider(height: 30),

            // Description
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              repo.description.isEmpty ? 'No description' : repo.description,
            ),

            const SizedBox(height: 20),

            // Dates
            _infoRow(
              'Created',
              DateFormat.yMMMMd().add_jm().format(repo.createdAt),
            ),
            _infoRow(
              'Updated',
              DateFormat.yMMMMd().add_jm().format(repo.updatedAt),
            ),

            const SizedBox(height: 30),

            // Open in browser
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open on GitHub'),
                onPressed: () async {
                  try {
                    await launchUrl(
                      Uri.parse(repo.htmlUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to open URL: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(IconData icon, int value, String label) => Column(
    children: [
      Icon(icon, size: 32),
      const SizedBox(height: 4),
      Text('$value', style: const TextStyle(fontSize: 20)),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ],
  );

  Widget _infoRow(String title, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
