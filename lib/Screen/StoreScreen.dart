import 'package:flutter/material.dart';
import 'package:pitjarus/func/Database.dart';
import 'package:pitjarus/main.dart';
import '../func/Controller.dart';
import 'package:flutter_awesome_buttons/flutter_awesome_buttons.dart';
import 'package:pitjarus/temp/jembatan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:page_transition/page_transition.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:math';
import 'package:cool_alert/cool_alert.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreScreen extends StatefulWidget {
  StoreScreen({super.key});

  @override
  _StoreScreenState createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  TextEditingController editingController = TextEditingController();
  var username;
  var password;
  var dataJSON;
  var sementaraToko;
  var count;
  var latAPI;
  //var count = int.parse(hitung);

  final ScrollController _scrollController = ScrollController();

  hapus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("user");
    prefs.remove("password");
    await basisData.main("delete", "");
  }

  load() {
    count = int.parse(API.hitungvar
        .toString()
        .replaceAll('[{count(id): ', '')
        .replaceAll('}]', ''));
  }

  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;
  String long = "", lat = "";
  String showlat = "";
  String showlong = "";
  late StreamSubscription<Position> positionStream;
  double l1 = 0;
  double l2 = 0;

  @override
  void initState() {
    checkGps();
    load();
    super.initState();
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            title: 'Lokasi',
            text: 'Lokasi tidak diizinkan',
            loopAnimation: false,
          );
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
          CoolAlert.show(
            context: context,
            type: CoolAlertType.error,
            title: 'Lokasi',
            text: 'Lokasi tidak diizinkan',
            loopAnimation: false,
          );
        } else {
          haspermission = true;
        }
      } else {
        haspermission = true;
      }

      if (haspermission) {
        setState(() {
          //refresh the UI
        });

        getLocation();
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  var cos;
  List jarak = [];
  List latacuan = [];
  List longacuan = [];

  getLocation() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position.longitude); //Output: 80.24599079
    print(position.latitude); //Output: 29.6593457

    long = position.longitude.toString();
    lat = position.latitude.toString();
    l1 = double.parse(lat);
    l2 = double.parse(long);
    LatLng initialcameraposition = LatLng(l1, l2);

    for (var i = 0;
        i <
            int.parse(API.hitungvar
                .toString()
                .replaceAll('[{count(id): ', '')
                .replaceAll('}]', ''));
        i++) {
      var meter = Geolocator.distanceBetween(
          double.parse(lat),
          double.parse(long),
          double.parse(API.simpan[i]["lat"]),
          double.parse(API.simpan[i]["long"]));
      print(meter);
      API.jarak[i] = meter;
    }
    print(jarak);

    setState(() {
      //refresh UI
    });

    LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high, //accuracy of the location data
      distanceFilter: 100, //minimum distance (measured in meters) a
      //device must move horizontally before an update event is generated;
    );

    StreamSubscription<Position> positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position position) {
      print(position.longitude); //Output: 80.24599079
      print(position.latitude); //Output: 29.6593457

      long = position.longitude.toString();
      lat = position.latitude.toString();
      l1 = double.parse(lat);
      l2 = double.parse(long);

      setState(() {
        //refresh UI on update
      });
    });
  }

  late LatLng kMapCenter = LatLng(l1, l2);

  late CameraPosition _kInitialPosition =
      CameraPosition(target: kMapCenter, zoom: 11.0, tilt: 0, bearing: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Store",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SafeArea(
                child: Text('Hi! ' + '\n' + API.user),
              ),
              TextButton(
                  child: Text("  Logout  ", style: TextStyle(fontSize: 14)),
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: BorderSide(color: Colors.black)))),
                  onPressed: () {
                    hapus();
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.fade, child: MyApp()));
                  }),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: editingController,
            decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
        ),
        SizedBox(
          height: 200,
          width: 400,
          child: GoogleMap(
            initialCameraPosition: _kInitialPosition,
          ),
        ),
        Center(
          child: Text(lat + ', ' + long),
        ),
        Expanded(
            child: Scrollbar(
          isAlwaysShown: true,
          controller: _scrollController,
          child: ListView.builder(
              shrinkWrap: true,
              controller: _scrollController,
              itemCount: int.parse(API.hitungvar
                  .toString()
                  .replaceAll('[{count(id): ', '')
                  .replaceAll('}]', '')),
              itemBuilder: (BuildContext context, index) {
                return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: ListTile(
                      leading: SizedBox(
                        height: 64.0,
                        width: 64.0,
                        child: Icon(Icons.location_pin),
                      ),
                      title: Text(
                          API.simpan[index]['storename']
                              .toString()
                              .replaceAll('{', '')
                              .replaceAll('}', ''),
                          style: const TextStyle(
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold)),
                      subtitle: Text(API.simpan[index]['address'].toString() +
                          '\n' +
                          API.simpan[index]['regname'].toString() +
                          '\n' +
                          API.simpan[index]['lat'].toString() +
                          '\n' +
                          API.simpan[index]['long'].toString() +
                          '\n' +
                          API.jarak[index].toString() +
                          ' m' +
                          '\n' +
                          API.simpan[index]["kunjungan"]
                              .toString()
                              .replaceAll('kosong', '')),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: StoreView(
                                  data: API.simpan[index],
                                )));
                        print(index);
                      },
                      onLongPress: () {},
                    ));
              }),
        ))
      ],
    ));
  }
}

class StoreView extends StatelessWidget {
  StoreView({super.key, required this.data});

  var data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        SizedBox(
          height: 100,
        ),
        Card(
          elevation: 50,
          child: Column(children: [
            Container(
              width: 370,
              child: Image.asset(
                'assets/indomaret.jpg',
                fit: BoxFit.fitHeight,
              ),
            ),
            SizedBox(
                width: 370,
                height: 212,
                child: Column(
                  children: [
                    Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Icon(Icons.store),
                            ),
                            Text(
                              data['storename'].toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        )),
                    Padding(
                      padding: EdgeInsets.only(left: 50),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                'Store Code: ' +
                                    data['storecode'].toString() +
                                    '\n' +
                                    'Address: ' +
                                    data['address'].toString() +
                                    '\n' +
                                    'DC Name: ' +
                                    data['dcname'].toString() +
                                    '\n' +
                                    'Account Name: ' +
                                    data['accname'].toString() +
                                    '\n' +
                                    'Subchannel Name: ' +
                                    data['subchanname'].toString() +
                                    '\n' +
                                    'Channel Name: ' +
                                    data['channame'].toString() +
                                    '\n' +
                                    'Area Name: ' +
                                    data['areaname'].toString() +
                                    '\n' +
                                    'Region Name: ' +
                                    data['regname'].toString(),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ))
          ]),
        ),
        SizedBox(
          height: 10,
        ),
        Padding(
          padding: EdgeInsets.all(22),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                height: 40,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {},
                    child: Text("No Visit")),
              ),
              SizedBox(
                width: 27,
              ),
              SizedBox(
                width: 100,
                height: 40,
                child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    onPressed: () async {
                      var item = Toko(
                          id: data["id"],
                          storeid: data["storeid"].toString(),
                          storecode: data["storecode"].toString(),
                          storename: data["storename"].toString(),
                          address: data["address"].toString(),
                          dcid: data["dcid"].toString(),
                          dcname: data["dcname"].toString(),
                          accid: data["accid"].toString(),
                          accname: data["accname"].toString(),
                          subchanid: data["subchanid"].toString(),
                          subchanname: data["subchanname"].toString(),
                          chanid: data["chanid"].toString(),
                          channame: data["channame"].toString(),
                          areaid: data["areaid"].toString(),
                          areaname: data["areaname"].toString(),
                          regid: data["regid"].toString(),
                          regname: data["regname"].toString(),
                          lat: data["lat"].toString(),
                          long: data["long"].toString(),
                          kunjungan: "Sudah dikunjungi \u2705");
                      print(item);
                      await basisData.main("update", item);
                      await API.lihat("");
                      Navigator.pushReplacement(
                          context,
                          PageTransition(
                              type: PageTransitionType.fade,
                              child: StoreScreen()));
                    },
                    child: Text("Visit")),
              ),
            ],
          ),
        )
      ],
    ));
  }
}

class itemStore {
  var id;
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

  itemStore(
      this.id,
      this.storecode,
      this.storename,
      this.address,
      this.dcid,
      this.dcname,
      this.accname,
      this.subchanid,
      this.subchanname,
      this.chanid,
      this.channame,
      this.areaname,
      this.regid,
      this.regname,
      this.lat,
      this.long);

  @override
  String toString() {
    return '${id}  ${storecode}  ${storename}  ${address}  ${dcid}  ${dcname}  ${accname}  ${subchanid}  ${subchanname}  ${chanid}  ${channame}  ${areaname}  ${regid}  ${regname}  ${lat}  ${long}';
  }
}
