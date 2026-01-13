class Item {
  int? id;
  String title;
  String? author;
  int? year;
  String description;
  String? pdfPath;
  String? coverPath;

  Item({
    this.id,
    required this.title,
    this.author,
    this.year,
    required this.description,
    this.pdfPath,
    this.coverPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'year': year,
      'description': description,
      'pdfPath': pdfPath,
      'coverPath': coverPath,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      year: map['year'],
      description: map['description'],
      pdfPath: map['pdfPath'],
      coverPath: map['coverPath'],
    );
  }
}
