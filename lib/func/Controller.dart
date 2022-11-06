import 'dart:io';
import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:page_transition/page_transition.dart';
import 'package:pitjarus/Screen/StoreScreen.dart';
import 'package:pitjarus/func/Database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class API {
  static var simpan;
  static var hitungvar;
  static var ceklogintemp;
  static var user;
  static var pass;
  static var pesantemp;
  static List jarak = [];

  static login(username, password) async {
    String apiUrl =
        'http://dev.pitjarus.co/api/sariroti_md/index.php/login/loginTest';
    var map = new Map<String, dynamic>();
    map["username"] = username;
    map["password"] = password;
    var response = await http.post(Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: map);

    var ceklogin = json.decode(response.body)["status"];
    if (ceklogin == 'success') {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('user', username);
      prefs.setString('password', password);
      user = username;
      pass = password;

      var cekstore = json.decode(response.body)["stores"];
      var item;
      for (var i = 0; i < cekstore.length; i++) {
        item = Toko(
            id: i,
            storeid: cekstore[i]["store_id"].toString(),
            storecode: cekstore[i]["store_code"].toString(),
            storename: cekstore[i]["store_name"].toString(),
            address: cekstore[i]["address"].toString(),
            dcid: cekstore[i]["dc_id"].toString(),
            dcname: cekstore[i]["dc_name"].toString(),
            accid: cekstore[i]["account_id"].toString(),
            accname: cekstore[i]["account_name"].toString(),
            subchanid: cekstore[i]["subchannel_id"].toString(),
            subchanname: cekstore[i]["subchannel_name"].toString(),
            chanid: cekstore[i]["channel_id"].toString(),
            channame: cekstore[i]["channel_name"].toString(),
            areaid: cekstore[i]["area_id"].toString(),
            areaname: cekstore[i]["area_name"].toString(),
            regid: cekstore[i]["region_id"].toString(),
            regname: cekstore[i]["region_name"].toString(),
            lat: cekstore[i]["latitude"].toString(),
            long: cekstore[i]["longitude"].toString(),
            kunjungan: "kosong");

        await basisData.main("insert", item);
        jarak.add(0);
      }
    } else {
      var pesan = json.decode(response.body)["message"];
      pesantemp = pesan;
    }

    print(ceklogin);

    ceklogintemp = ceklogin;
  }

  static lihat(body) async {
    await basisData.main("select", "$body");
    for (var i = 0; i < simpan.length; i++) {
      jarak.add(0);
    }
  }

  static hitung(body) async {
    await basisData.main("hitung", "$body");
  }

  static delete(body) async {
    await basisData.main("delete", "");
  }
}
