import 'package:flutter/widgets.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:pitjarus/Screen/StoreScreen.dart';
import 'package:pitjarus/func/Controller.dart';
import 'package:pitjarus/temp/jembatan.dart';
import 'package:sqflite/sqflite.dart';

class basisData {
  static main(param, body) async {
    // Avoid errors caused by flutter upgrade.
    // Importing 'package:flutter/widgets.dart' is required.
    WidgetsFlutterBinding.ensureInitialized();
    // Open the database and store the reference.
    final database = openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'testflutter.db'),
      // When the database is first created, create a table to store tokos.
      onCreate: (db, version) {
        // Run the CREATE TABLE statement on the database.
        return db.execute(
          'CREATE TABLE tokos (id INTEGER, storeid VARCHAR(255), storecode VARCHAR(255), storename VARCHAR(255), address VARCHAR(255), dcid VARCHAR(255), dcname VARCHAR(255), accid VARCHAR(255), accname VARCHAR(255), subchanid VARCHAR(255), subchanname VARCHAR(255), chanid VARCHAR(255), channame VARCHAR(255), areaid VARCHAR(255), areaname VARCHAR(255), regid VARCHAR(255), regname VARCHAR(255), lat VARCHAR(255), long VARCHAR(255), kunjungan VARCHAR(255))',
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );

    // Define a function that inserts tokos into the database
    Future<void> insertToko(Toko toko) async {
      // Get a reference to the database.
      final db = await database;

      // Insert the Toko into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same toko is inserted twice.
      //
      // In this case, replace any previous data.
      await db.insert(
        'tokos',
        toko.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    Future<dynamic> selectToko() async {
      // Get a reference to the database.
      final db = await database;

      // Insert the Toko into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same toko is inserted twice.
      //
      // In this case, replace any previous data.
      var nyelek = await db.rawQuery("SELECT *  FROM tokos ");
      return nyelek;
    }

    Future<dynamic> cariToko(kata) async {
      // Get a reference to the database.
      final db = await database;

      // Insert the Toko into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same toko is inserted twice.
      //
      // In this case, replace any previous data.
      var nyelek = await db
          .rawQuery("SELECT *  FROM tokos WHERE storename LIKE '$kata'");
      return nyelek;
    }

    Future<dynamic> hitungToko(kolom) async {
      // Get a reference to the database.
      final db = await database;

      // Insert the Toko into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same toko is inserted twice.
      //
      // In this case, replace any previous data.
      var nyelek = await db.rawQuery("SELECT count($kolom) FROM tokos ");
      return nyelek;
    }

    // A method that retrieves all the tokos from the tokos table.
    Future<List<Toko>> tokos() async {
      // Get a reference to the database.
      final db = await database;

      // Query the table for all The Tokos.
      final List<Map<String, dynamic>> maps = await db.query('tokos');

      // Convert the List<Map<String, dynamic> into a List<Toko>.
      return List.generate(maps.length, (i) {
        return Toko(
            id: maps[i]["id"],
            storeid: maps[i]["storeid"],
            storecode: maps[i]["storecode"],
            storename: maps[i]["storename"],
            address: maps[i]["address"],
            dcid: maps[i]["dcid"],
            dcname: maps[i]["dcname"],
            accid: maps[i]["accid"],
            accname: maps[i]["accname"],
            subchanid: maps[i]["subchanid"],
            subchanname: maps[i]["subchanname"],
            chanid: maps[i]["chanid"],
            channame: maps[i]["channame"],
            areaid: maps[i]["areaid"],
            areaname: maps[i]["areaname"],
            regid: maps[i]["regid"],
            regname: maps[i]["regname"],
            lat: maps[i]["lat"],
            long: maps[i]["long"],
            kunjungan: maps[i]["kunjungan"]);
      });
    }

    Future<void> updateToko(Toko toko) async {
      // Get a reference to the database.
      final db = await database;

      // Update the given Toko.
      await db.update(
        'tokos',
        toko.toMap(),
        // Ensure that the Toko has a matching id.
        where: 'id = ?',
        // Pass the Toko's id as a whereArg to prevent SQL injection.
        whereArgs: [toko.id],
      );
    }

    Future<void> deleteToko(int id) async {
      // Get a reference to the database.
      final db = await database;

      // Remove the Toko from the database.
      await db.delete('tokos'
          // Use a `where` clause to delete a specific toko
          );
    }

    if (param == "hitung") {
      var c = await hitungToko(body);
      print(c);
      API.hitungvar = c;
      print(API.hitungvar);
    }
    if (param == "insert") {
      await insertToko(body);
    }
    if (param == "update") {
      await updateToko(body);
    }
    if (param == "delete") {
      await deleteToko(body);
    }
    if (param == "select") {
      var datadb = await selectToko();
      print(datadb);
      API.simpan = datadb;
      print(API.simpan);
    }
    if (param == "cari") {
      var datadb = await cariToko(body);
      print(datadb);
      API.simpan = datadb;
      print(API.simpan);
    }

    // Create a Toko and add it to the tokos table

    // Now, use the method above to retrieve all the tokos.
  }
}

class Toko {
  var id;
  var storeid;
  String storecode;
  String storename;
  String address;
  var dcid;
  String dcname;
  var accid;
  String accname;
  var subchanid;
  String subchanname;
  var chanid;
  String channame;
  var areaid;
  String areaname;
  var regid;
  String regname;
  String lat;
  String long;
  String kunjungan;

  Toko(
      {required this.id,
      required this.storeid,
      required this.storecode,
      required this.storename,
      required this.address,
      required this.dcid,
      required this.dcname,
      required this.accid,
      required this.accname,
      required this.subchanid,
      required this.subchanname,
      required this.chanid,
      required this.channame,
      required this.areaid,
      required this.areaname,
      required this.regid,
      required this.regname,
      required this.lat,
      required this.long,
      required this.kunjungan});

  // Convert a Toko into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {
      "id": id,
      "storeid": storeid,
      "storecode": storecode,
      "storename": storename,
      "address": address,
      "dcid": dcid,
      "dcname": dcname,
      "accid": accid,
      "accname": accname,
      "subchanid": subchanid,
      "subchanname": subchanname,
      "chanid": chanid,
      "channame": channame,
      "areaid": areaid,
      "areaname": areaname,
      "regid": regid,
      "regname": regname,
      "lat": lat,
      "long": long,
      "kunjungan": kunjungan
    };
  }

  // Implement toString to make it easier to see information about
  // each toko when using the print statement.
  @override
  String toString() {
    return 'Toko{id: $id, storeid: $storeid, storecode: $storecode, storename: $storename, address: $address, dcid: $dcid, dcname: $dcname, accid: $accid, accname: $accname, subchanid: $subchanid, subchanname: $subchanname, chanid: $chanid, channame: $channame, areaname: $areaname, regid: $regid, regname: $regname, lat: $lat, long: $long, kunjungan: $kunjungan}';
  }
}
