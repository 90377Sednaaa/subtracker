class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.premium,
    required this.premiumPlan,
  });

  final String id;
  final String email;
  final String displayName;
  final bool premium;
  final String premiumPlan; // 'free' | 'monthly' | 'annual'

  static UserProfile fromMap(String id, Map<String, dynamic> map) {
    return UserProfile(
      id: id,
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      premium: map['premium'] as bool? ?? false,
      premiumPlan: map['premiumPlan'] as String? ?? 'free',
    );
  }
}
