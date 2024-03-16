class Messages {
  String? forid;
  String? toid;
  String? msg;
  String? sent;
  String? read;
  Type? type;

  Messages({this.forid, this.toid, this.msg, this.sent, this.read, this.type});

  Messages.fromJson(Map<String, dynamic> json) {
    forid = json['forid'].toString();
    toid = json['toid'].toString();
    msg = json['msg'].toString();
    sent = json['sent'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['forid'] = forid;
    data['toid'] = toid;
    data['msg'] = msg;
    data['sent'] = sent;
    data['read'] = read;
    data['type'] = type?.name;
    return data;
  }
}

enum Type { text, image }
