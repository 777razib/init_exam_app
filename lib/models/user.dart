class GitHubUser {
  final String login;
  final String name;
  final String bio;
  final String avatarUrl;
  final int publicRepos;
  final int followers;
  final int following;

  GitHubUser({
    required this.login,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    required this.publicRepos,
    required this.followers,
    required this.following,
  });

  factory GitHubUser.fromJson(Map<String, dynamic> json) {
    return GitHubUser(
      login: json['login'] ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      publicRepos: json['public_repos'] ?? 0,
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}

