import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/repo_model.dart';

class RepoDetailsScreen extends StatelessWidget {
  final RepoModel repo;
  final String username;

  const RepoDetailsScreen({
    Key? key,
    required this.repo,
    required this.username,
  }) : super(key: key);

  String _formatDate(String iso) {
    final date = DateTime.parse(iso);
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Handle error if URL cannot be launched
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(repo.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _launchURL(repo.htmlUrl),
            tooltip: 'Open in browser',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Repository Name and Privacy Badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    repo.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(repo.isPrivate ? 'Private' : 'Public'),
                  backgroundColor: repo.isPrivate 
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.green.withOpacity(0.2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            if (repo.description.isNotEmpty) ...[
              Text(
                repo.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],

            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.star,
                    'Stars',
                    repo.stargazersCount.toString(),
                    Colors.amber,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.call_split,
                    'Forks',
                    repo.forksCount.toString(),
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.visibility,
                    'Watchers',
                    repo.watchersCount.toString(),
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    Icons.bug_report,
                    'Issues',
                    repo.openIssuesCount.toString(),
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Language
            if (repo.language != null) ...[
              _buildInfoRow(context, Icons.code, 'Language', repo.language!),
              const SizedBox(height: 16),
            ],

            // Default Branch
            _buildInfoRow(context, Icons.account_tree, 'Default Branch', repo.defaultBranch),
            const SizedBox(height: 16),

            // Created Date
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Created',
              _formatDate(repo.createdAt),
            ),
            const SizedBox(height: 16),

            // Updated Date
            _buildInfoRow(
              context,
              Icons.update,
              'Last Updated',
              _formatDate(repo.updatedAt),
            ),
            const SizedBox(height: 24),

            // Homepage
            if (repo.homepage != null && repo.homepage!.isNotEmpty) ...[
              _buildInfoRow(
                context,
                Icons.home,
                'Homepage',
                repo.homepage!,
                isLink: true,
              ),
              const SizedBox(height: 24),
            ],

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchURL(repo.htmlUrl),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open on GitHub'),
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

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value, {
    bool isLink = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              if (isLink)
                GestureDetector(
                  onTap: () => _launchURL(value),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                )
              else
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

