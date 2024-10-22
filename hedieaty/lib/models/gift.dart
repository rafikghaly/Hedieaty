class Gift {
  final String name;
  final String description;
  final String category;
  final String status;
  final bool isPledged;
  final String? imageUrl;

  Gift({
    required this.name,
    required this.description,
    required this.category,
    required this.status,
    this.isPledged = false,
    this.imageUrl,
  });
}