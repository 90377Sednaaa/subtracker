class CancellationLink {
  const CancellationLink({
    required this.id,
    required this.name,
    required this.category,
    required this.cancelUrl,
    required this.notes,
  });

  final String id;
  final String name;
  final String category;
  final String cancelUrl;
  final String notes;

  static CancellationLink fromMap(String id, Map<String, dynamic> map) =>
      CancellationLink(
        id: id,
        name: map['name'] as String,
        category: map['category'] as String? ?? '',
        cancelUrl: map['cancelUrl'] as String,
        notes: map['notes'] as String? ?? '',
      );
}
