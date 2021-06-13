import 'entity/index.dart';

abstract class ShareTraceController {
  Future<bool> initShareTrace({String appKey, String serverDomain});
  Future<AppData> getInstallTrace({int defaultTimeout = 10});
  Future<AppData> getCacheTraceData();
  Stream<AppData> registerWakeupListener();
}