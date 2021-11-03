class Places {
  final String description;
  final String placeId;

  Places({this.description, this.placeId});

  factory Places.fromJson(Map<String, dynamic> json) {
    return Places(description: json['description'], placeId: json['place_id']);
  }
}
