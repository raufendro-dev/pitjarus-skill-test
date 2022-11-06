import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_awesome_buttons/flutter_awesome_buttons.dart';
import 'package:pitjarus/func/Controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pitjarus/Screen/StoreScreen.dart';
import 'package:pitjarus/temp/jembatan.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pitjarus',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      builder: EasyLoading.init(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final username = TextEditingController();
  final password = TextEditingController();
  List<dynamic> data = [];
  bool servicestatus = false;
  bool haspermission = false;
  late LocationPermission permission;
  late Position position;

  login(username, password) async {
    await API.login(username, password);

    if (API.ceklogintemp == "success") {
      print("bisa");

      await memuat();

      Navigator.push(context,
          PageTransition(type: PageTransitionType.fade, child: StoreScreen()));
    } else {
      CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        title: 'Gagal Login',
        text: API.pesantemp,
        loopAnimation: false,
        confirmBtnText: 'Coba Lagi',
      );

      print(API.ceklogintemp);
    }
  }

  memuat() async {
    await API.hitung("id");

    await API.lihat("");

    print(API.simpan);
  }

  checkGps() async {
    servicestatus = await Geolocator.isLocationServiceEnabled();
    if (servicestatus) {
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
        } else if (permission == LocationPermission.deniedForever) {
          print("'Location permissions are permanently denied");
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
      }
    } else {
      print("GPS Service is not enabled, turn on GPS location");
    }

    setState(() {
      //refresh the UI
    });
  }

  cek() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString('user'));
    if (prefs.getString('user') != null &&
        prefs.getString('password') != null) {
      EasyLoading.show(status: 'Mengambil Sesi Login');
      API.user = prefs.getString('user');
      API.pass = prefs.getString('password');
      await memuat();

      if (API.simpan != null && API.hitungvar != null) {
        await Future.delayed(const Duration(seconds: 3));
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.fade, child: StoreScreen()));
        EasyLoading.dismiss();
      }
    }
  }

  @override
  void initState() {
    checkGps();
    cek();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/background.png'), fit: BoxFit.cover)),
      child: Column(
        children: [
          SizedBox(
            height: 300,
          ),
          Center(
            child: Stack(
              children: [
                SafeArea(
                    child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                          textAlign: TextAlign.center,
                          controller: username,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: 'Username')),
                      width: 283,
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(220, 220, 220, 220))),
                )),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Center(
            child: Stack(
              children: [
                SafeArea(
                    child: Center(
                  child: Container(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                          textAlign: TextAlign.center,
                          controller: password,
                          decoration: const InputDecoration(
                              border: InputBorder.none, hintText: 'Password')),
                      width: 283,
                      height: 50,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(220, 220, 220, 220))),
                )),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 200,
            height: 40,
            child: ElevatedButton(
                onPressed: () async {
                  EasyLoading.show(status: 'Login');
                  await login(username.text, password.text);
                  EasyLoading.dismiss();
                },
                child: Text("Login")),
          )
        ],
      ),
    ));
  }
}
