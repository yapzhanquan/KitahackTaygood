class AppUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final int contributionCount;

  AppUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.contributionCount = 0,
  });
}
