class AppUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? email;
  final String role; // "user", "mod", "admin"
  final int contributionCount;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.email,
    this.role = 'user',
    this.contributionCount = 0,
    this.createdAt,
  });

  // ── Firestore serialization ─────────────────────────────────

  factory AppUser.fromJson(Map<String, dynamic> json, {String? docId}) {
    return AppUser(
      id: docId ?? json['id'] as String? ?? '',
      name: json['displayName'] as String? ?? json['name'] as String? ?? '',
      avatarUrl: json['photoURL'] as String? ?? json['avatarUrl'] as String?,
      email: json['email'] as String?,
      role: json['role'] as String? ?? 'user',
      contributionCount: (json['contributionCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': name,
        'photoURL': avatarUrl,
        'email': email,
        'role': role,
        'contributionCount': contributionCount,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };
}
