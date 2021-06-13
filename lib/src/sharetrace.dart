
import 'entity/index.dart';
import 'plugin_controller_factory.dart';
import 'sharetrace_controller.dart';

abstract class ShareTrace {

  ///
  /// 初始化ShareTrace
  /// [appKey]        ShareTrace平台的key值,如果appkey在AndroidManifest.xml或Info.plist中已经配置此处无需传入
  /// [serverDomain]  独立IP服务,如果serverDomain在AndroidManifest.xml中已经配置此处无需传入,iOS需要在Info.plist中配置
  ///
  Future<bool> initShareTrace({String appKey, String serverDomain});

  ///
  /// 获取安装携带的参数(该方法可以重复调用，请处理好反复调用的逻辑。)
  /// [defaultTimeout] 默认超时时间
  ///
  Future<AppData> getInstallTrace({int defaultTimeout = 10});

  ///
  /// 获取缓存的数据,比如某个时间获取了数据，下次可以直接从缓存中读取
  ///
  Future<AppData> getCacheTraceData();

  ///
  /// 注册唤醒监听,若使用此功能需要根据官方教程配置Scheme
  ///
  Stream<AppData> registerWakeupListener();
}

class ShareTraceImpl extends ShareTrace {

  ShareTraceImpl._() : _schemeController = PluginControllerFactory().create();

  static ShareTraceImpl _instance;

  static ShareTraceImpl getInstance() {
    if (_instance == null) {
      _instance = ShareTraceImpl._();
    }
    return _instance;
  }

  ShareTraceController _schemeController;

  @override
  Future<bool> initShareTrace({String appKey, String serverDomain}){
    return _schemeController.initShareTrace(appKey:appKey,serverDomain:serverDomain);
  }

  @override
  Future<AppData> getInstallTrace({int defaultTimeout = 10}) {
    return _schemeController.getInstallTrace(defaultTimeout:defaultTimeout);
  }

  @override
  Future<AppData> getCacheTraceData() {
    return _schemeController.getCacheTraceData();
  }

  @override
  Stream<AppData> registerWakeupListener() {
    return _schemeController.registerWakeupListener();
  }

}