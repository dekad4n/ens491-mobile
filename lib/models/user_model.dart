class User {
  User(
      {required this.pid,
      required this.id,
      this.name,
      required this.username,
      required this.nonce});
  String pid; // Private id
  String id; // Public Adress of user's wallet
  String? name;
  String username; // Default: Public Adress, able to update
  String nonce; // Nonce of user

  factory User.fromJson(Map<String, dynamic> json) => User(
      pid: json["_id"],
      id: json["id"],
      name: json["name"],
      username: json["username"],
      nonce: json["nonce"]);
  Map<String, dynamic> toJson() => {
        "_id": pid,
        "id": id,
        "name": name,
        "username": username,
        "nonce": nonce
      };
}
