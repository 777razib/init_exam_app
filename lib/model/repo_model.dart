class RepoModel {
  final String name;
  final String description;
  final String updatedAt;
  final int stargazersCount;

  RepoModel({
    required this.name,
    required this.description,
    required this.updatedAt,
    required this.stargazersCount,
  });

  factory RepoModel.fromJson(Map<String, dynamic> json) {
    return RepoModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      stargazersCount: json['stargazers_count'] ?? 0,
    );
  }
}