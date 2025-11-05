class RepoModel {
  final String name;
  final String description;
  final String updatedAt;
  final String createdAt;
  final int stargazersCount;
  final int forksCount;
  final int watchersCount;
  final String? language;
  final String htmlUrl;
  final String defaultBranch;
  final int openIssuesCount;
  final bool isPrivate;
  final String? homepage;

  RepoModel({
    required this.name,
    required this.description,
    required this.updatedAt,
    required this.createdAt,
    required this.stargazersCount,
    required this.forksCount,
    required this.watchersCount,
    this.language,
    required this.htmlUrl,
    required this.defaultBranch,
    required this.openIssuesCount,
    required this.isPrivate,
    this.homepage,
  });

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      stargazersCount: json['stargazers_count'] ?? 0,
      forksCount: json['forks_count'] ?? 0,
      watchersCount: json['watchers_count'] ?? 0,
      language: json['language'],
      htmlUrl: json['html_url'] ?? '',
      defaultBranch: json['default_branch'] ?? 'main',
      openIssuesCount: json['open_issues_count'] ?? 0,
      isPrivate: json['private'] ?? false,
      homepage: json['homepage'],
    );
  }
}