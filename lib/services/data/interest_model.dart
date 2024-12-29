class Interest {
  final int id;
  final String name;
  final String category;

  Interest({
    required this.id,
    required this.name,
    required this.category,
  });

  factory Interest.fromJson(Map<String, dynamic> json) {
    return Interest(
      id: json['id'],
      name: json['name'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
    };
  }
}
