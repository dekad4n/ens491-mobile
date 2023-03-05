class Event {
  Event(
      {this.id,
      this.title,
      this.owner,
      this.coverImageURL,
      this.startDate,
      this.endDate,
      this.startTime,
      this.endTime,
      this.category,
      this.description});

  String? id; // Nonce of user
  String? title; // Private id
  String? owner; // Public Adress of user's wallet
  String? coverImageURL;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  String? category;
  String? description;

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json["_id"],
        owner: json["owner"],
        title: json["title"],
        coverImageURL: json["coverImageURL"],
        startDate: json["startDate"],
        endDate: json["endDate"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        category: json["category"],
        description: json["description"],
      );
  Map<String, dynamic> toJson() => {
        "_id": id,
        "owner": owner,
        "title": title,
        "coverImageURL": coverImageURL,
        "startDate": startDate,
        "endDate": endDate,
        "startTime": startTime,
        "endTime": endTime,
        "category": category,
        "description": description,
      };
}
