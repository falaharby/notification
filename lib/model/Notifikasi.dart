import 'dart:convert';

class Notifikasi {
  int id;
  String title;
  String path;

  Notifikasi({
    this.id,
    this.title,
    this.path,
  });

  factory Notifikasi.fromJson(Map<String, dynamic> json) {
    return Notifikasi(
      id: json["id"],
      title: json["title"],
      path: json["path"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "path": path,
    };
  }

  @override
  String toString() {
    return 'Notifikasi{id: $id, title: $title, path: $path}';
  }
}

List<Notifikasi> notifFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<Notifikasi>.from(data.map((item) => Notifikasi.fromJson(item)));
}

String notifToJson(Notifikasi data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}
