class Suggestion {
  final String placeId;
  final String description;

  Suggestion({this.placeId, this.description});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
        description: json['description'], placeId: json['place_id']);
  }

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}
