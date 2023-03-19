class Category {
  Category({
    required this.image,
    required this.name,
  });
  String image; // Private id
  String name; // Public Adress of Category's wallet

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        image: json["image"],
        name: json["name"],
      );
  Map<String, dynamic> toJson() => {
        "image": image,
        "name": name,
      };
}
