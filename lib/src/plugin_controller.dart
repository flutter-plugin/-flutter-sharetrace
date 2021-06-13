import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'entity/index.dart';
import 'sharetrace_controller.dart';

class PluginController implements ShareTraceController {
  final MethodChannel _traceChannel;
  final EventChannel _eventChannel;

  PluginController({
    @required MethodChannel traceChannel,
    @required EventChannel eventChannel,
  })  : _traceChannel = traceChannel,
        _eventChannel = eventChannel;

  @override
  Future<AppData> getCacheTraceData() async{
    dynamic data = await _traceChannel.invokeMethod('getCacheTraceData');
    if (data != null && data is Map && data.isNotEmpty) {
      return AppData(
        code: int.parse(data['code'] as String),
        msg: data['msg'] as String,
        paramsData: data['paramsData'] as String,
        channel: data['channel'] as String,
      );
    }
    return null;
  }

  @override
  Future<AppData> getInstallTrace({int defaultTimeout = 10}) async{
    dynamic data = await _traceChannel.invokeMethod('getInstallTrace',{'defaultTimeout':defaultTimeout});
    if (data != null && data is Map && data.isNotEmpty) {
      return AppData(
        code: int.parse(data['code'] as String),
        msg: data['msg'] as String,
        paramsData: data['paramsData'] as String,
        channel: data['channel'] as String,
      );
    }
    return null;
  }

  @override
  Future<bool> initShareTrace({String appKey, String serverDomain}) async{
    Map<String,String> data = {};
    if(appKey != null && appKey.isNotEmpty){
      data['appKey'] = appKey;
    }
    if(serverDomain != null && serverDomain.isNotEmpty){
      data['serverDomain'] = serverDomain;
    }
    return await _traceChannel.invokeMethod('init',data);
  }

  @override
  Stream<AppData> registerWakeupListener(){
    _traceChannel.invokeMethod('registerWakeup').asStream().asyncMap((event) =>event is bool).first.then((value){});
    Stream<AppData> stream = _eventChannel.receiveBroadcastStream('12344')
      .map((event) => event)
      .asBroadcastStream()
      .map(
        (event) => (event != null && event is Map && event.isNotEmpty)
        ? AppData(
        code: int.parse(event['code'] as String),
        msg: event['msg'] as String,
        paramsData: event['paramsData'] as String,
        channel: event['channel'] as String,): null
      );
    return stream;
  }
}