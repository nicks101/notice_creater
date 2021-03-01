class Notice {
  final String title;
  final String description;
  final String party1;
  final String party2;
  final String party3;

  Notice({this.title, this.description, this.party1, this.party2, this.party3});

  @override
  String toString() {
    return '$title, $description';
  }
}
