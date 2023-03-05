class Event {
  Event({
    required this.name,
    required this.owner,
    this.logo,
    this.banner,
    required this.id,
    required this.startDate,
    this.endDate,
  });
  String name; // Private id
  String owner; // Public Adress of user's wallet
  String? logo;
  String? banner; // Default: Public Adress, able to update
  String id; // Nonce of user
  String startDate;
  String? endDate;
  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json["_id"],
        owner: json["owner"],
        name: json["name"],
        banner: json["banner"],
        logo: json["logo"],
        startDate: json["startDate"],
        endDate: json["endDate"],
      );
  Map<String, dynamic> toJson() => {
        "_id": id,
        "owner": owner,
        "name": name,
        "logo": logo,
        "banner": banner,
        "startDate": startDate,
        "endDate": endDate
      };
}
