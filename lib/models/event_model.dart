class Event {
  Event(
      {required this.name,
      required this.owner,
      this.logo,
      this.banner,
      required this.id});
  String name; // Private id
  String owner; // Public Adress of user's wallet
  String? logo;
  String? banner; // Default: Public Adress, able to update
  String id; // Nonce of user

  factory Event.fromJson(Map<String, dynamic> json) => Event(
      id: json["_id"],
      owner: json["owner"],
      name: json["name"],
      banner: json["banner"],
      logo: json["logo"]);
  Map<String, dynamic> toJson() =>
      {"_id": id, "owner": owner, "name": name, "logo": logo, "banner": banner};
}
