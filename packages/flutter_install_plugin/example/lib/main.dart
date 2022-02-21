import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_install_plugin/flutter_install_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _apkFilePath = '';
  @override
  void initState() {
    super.initState();
  }

  void onClickInstallApk() async {
    // if (_apkFilePath.isEmpty) {
    //   print('make sure the apk file is set');
    //   return;
    // }
    final permissions =
    await Permission.storage.request();
    if (permissions == PermissionStatus.granted) {
      FlutterInstallPlugin.installApk('/sdcard/Download/app-debug1.apk', 'com.example.flutter_install_plugin_example')
          .then((result) {
        print('install apk $result');
      }).catchError((error) {
        print('install apk error: $error');
      });
    } else {
      print('Permission request fail!');
    }
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(onPressed: (){
               FlutterInstallPlugin.gotoAppStore('https://itunes.apple.com/cn/app/%E5%86%8D%E6%83%A0%E5%90%88%E4%BC%99%E4%BA%BA/id1375433239?l=zh&ls=1&mt=8');
              }, child: Text('gotoAppStore')),
              SizedBox(height: 20,),
              TextField(

                decoration: InputDecoration(
                    hintText:
                    'apk file path to install. Like /storage/emulated/0/demo/update.apk'),
                onChanged: (path) => _apkFilePath = path,
              ),
              SizedBox(height: 20,),
              TextButton(onPressed: (){
                  onClickInstallApk();
              }, child: Text('download apk')),

            ],
          ),
        ),
      ),
    );
  }
}
