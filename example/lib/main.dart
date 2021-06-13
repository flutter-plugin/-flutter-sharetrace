import 'package:flutter/material.dart';
import 'package:flutter_sharetrace/flutter_sharetrace.dart';

ShareTrace shareTrace = ShareTraceImpl.getInstance();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  shareTrace.initShareTrace(appKey:'25fc8bad65fa67eb').then((value){
    print("==========> 初始化 value:$value");
  });
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    shareTrace.getInstallTrace().then((value){
      if(value == null){
        print("getInstallTrace ==============> 数据为空");
      }else{
        print("getInstallTrace ==============value:${value.toJson()}");
      }
    }).whenComplete((){
      shareTrace.getCacheTraceData().then((value){
        if(value == null){
          print("getCacheTraceData ==============> 数据为空");
        }else{
          print("getCacheTraceData ==============value:${value.toJson()}");
        }
      }).whenComplete((){
        shareTrace.registerWakeupListener().listen((event) { 
          if(event == null){
            print(" registerWakeupListener ==============> 数据为空");
          }else{
            print("registerWakeupListener ==============event:${event.toJson()}");
          }

          shareTrace.getCacheTraceData().then((value){
            if(value == null){
              print("getCacheTraceData ==============> 数据为空");
            }else{
              print("getCacheTraceData ==============value:${value.toJson()}");
            }
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
