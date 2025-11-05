class Repository {
  final String name;
  final String description;
  final String language;
  final int stargazersCount;
  final int forksCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String htmlUrl;
  final String ownerAvatar;
  final bool isPrivate;
  final String defaultBranch;
  final int openIssuesCount;
  final int watchersCount;
  final String? homepage;

  Repository({
    required this.name,
    required this.description,
    required this.language,
    required this.stargazersCount,
    required this.forksCount,
    required this.createdAt,
    required this.updatedAt,
    required this.htmlUrl,
    required this.ownerAvatar,
    required this.isPrivate,
    required this.defaultBranch,
    required this.openIssuesCount,
    required this.watchersCount,
    this.homepage,
  });

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      language: json['language'] ?? 'N/A',
      stargazersCount: json['stargazers_count'] ?? 0,
      forksCount: json['forks_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
      htmlUrl: json['html_url'] ?? '',
      ownerAvatar: json['owner']?['avatar_url'] ?? '',
      isPrivate: json['private'] ?? false,
      defaultBranch: json['default_branch'] ?? 'main',
      openIssuesCount: json['open_issues_count'] ?? 0,
      watchersCount: json['watchers_count'] ?? 0,
      homepage: json['homepage'],
    );
  }
}

