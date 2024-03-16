class Chatuser {
  String? id;
  String? name;
  String? email;
  String? image;
  String? createdAt;
  String? lastActive;
  bool? isOnline;
  String? about;
  String? pushToken;

  Chatuser(
      {this.id,
      this.name,
      this.email,
      this.image,
      this.createdAt,
      this.lastActive,
      this.isOnline,
      this.about,
      this.pushToken});

  Chatuser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    image = json['image'];
    createdAt = json['createdAt'];
    lastActive = json['lastActive'];
    isOnline = json['isOnline'];
    about = json['about'];
    pushToken = json['pushToken'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['image'] = image;
    data['createdAt'] = createdAt;
    data['lastActive'] = lastActive;
    data['isOnline'] = isOnline;
    data['about'] = about;
    data['pushToken'] = pushToken;
    return data;
  }
}
