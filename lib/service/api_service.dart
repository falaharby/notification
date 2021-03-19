import 'package:notifikasi/model/Notifikasi.dart';
import 'package:http/http.dart' show Client;

class ApiService {
  Client client = Client();

  Future<List<Notifikasi>> getNotif() async {
    print('tulisan');
    final response =
        await client.get('http://c7dd91125b2a.ngrok.io/api/sounds');
    print(response.body);
    if (response.statusCode == 200) {
      return notifFromJson(response.body);
    } else {
      return null;
    }
  }
}
