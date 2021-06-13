package com.plugin.sharetrace.flutter;

import android.app.Application;
import android.content.Intent;

import androidx.annotation.NonNull;
import java.util.HashMap;
import java.util.Map;
import cn.net.shoot.sharetracesdk.AppData;
import cn.net.shoot.sharetracesdk.ShareTrace;
import cn.net.shoot.sharetracesdk.ShareTraceInstallListener;
import cn.net.shoot.sharetracesdk.ShareTraceWakeUpListener;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;

public class ShareTracePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.NewIntentListener{

  private Application mContext;
  private MethodChannel channel;
  private AppData cacheAppData = null;
  private boolean hasWakeupRegisted = false;

  private EventChannel.EventSink  eventSink;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding pluginBinding) {
    mContext = (Application) pluginBinding.getApplicationContext();
    register(pluginBinding.getBinaryMessenger(), this);
  }

  private void register(BinaryMessenger messenger, ShareTracePlugin plugin) {
    channel = new MethodChannel(messenger, "sharetrace/flutter.app.method");
    channel.setMethodCallHandler(this);
    EventChannel eventChannel = new EventChannel(messenger,"sharetrace/flutter.app.event");
    eventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object arguments, EventChannel.EventSink events) {
        eventSink = events;
      }

      @Override
      public void onCancel(Object arguments) {
        eventSink = null;
      }
    });
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call,final  @NonNull Result result) {
    if ("init".equals(call.method)) {
      if(call.hasArgument("serverDomain")){
        String serverDomain = call.argument("serverDomain");
        ShareTrace.setServerDomain(serverDomain);
      }
      if(call.hasArgument("appKey")){
        String appKey = call.argument("appKey");
        ShareTrace.init(mContext,appKey);
      }else{
        ShareTrace.init(mContext);
      }
      result.success(true);
    } else if("getInstallTrace".equals(call.method)){
      int defaultTimeout = 10;
      if(call.hasArgument("defaultTimeout")){
        defaultTimeout = call.argument("defaultTimeout");
      }

      ShareTrace.getInstallTrace(new ShareTraceInstallListener() {
        @Override
        public void onInstall(AppData app) {
          Map<String, String> ret;
          if (app == null) {
            ret = parseToResult(-1, "Extract data fail.", "", "");
          }else{
            cacheAppData = app;
            ret = parseToSuccessMap(app);
          }
          result.success(ret);
        }

        @Override
        public void onError(int code, String message) {
          Map<String, String> ret = parseToResult(code, message, "", "");
          result.success(ret);
        }
      },defaultTimeout * 1000);

    }else if("getCacheTraceData".equals(call.method)){
      Map<String, String> ret;
      if(cacheAppData == null){
        ret = parseToResult(-1, "未发现数据", "", "");
      }else{
        ret = parseToSuccessMap(cacheAppData);
      }
      result.success(ret);
    }else if("registerWakeup".equals(call.method)){
      hasWakeupRegisted = true;
      if (cacheAppData != null) {
        Map<String, String> ret = parseToSuccessMap(cacheAppData);
        wakeupResponse(ret);
      }
      result.success(true);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }


  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    Intent intent = binding.getActivity().getIntent();
    if (intent != null) {
      ShareTrace.getWakeUpTrace(intent,wakeUpListener);
    }
    binding.addOnNewIntentListener(this);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
  }

  @Override
  public void onDetachedFromActivity() {
  }

  private void wakeupResponse(Map<String, String> ret) {
    if(eventSink != null){
      eventSink.success(ret);
    }
  }

  private Map<String, String> parseToSuccessMap(AppData appData) {
    if (appData == null) {
      return new HashMap<>();
    }
    String paramsData = (appData.getParamsData() == null) ? "" : appData.getParamsData();
    String channel = (appData.getChannel() == null) ? "" : appData.getChannel();
    return parseToResult(200, "Success", paramsData, channel);
  }

  private Map<String, String> parseToResult(int code, String msg, String paramsData, String channel) {
    Map<String, String> result = new HashMap<>();
    result.put("code", String.valueOf(code));
    result.put("msg", msg);
    result.put("paramsData", paramsData);
    result.put("channel", channel);
    return result;
  }

  @Override
  public boolean onNewIntent(Intent intent) {
    return ShareTrace.getWakeUpTrace(intent, wakeUpListener);
  }

  ShareTraceWakeUpListener wakeUpListener = new ShareTraceWakeUpListener() {
    @Override
    public void onWakeUp(AppData appData) {
      if (hasWakeupRegisted) {
        wakeupResponse(parseToSuccessMap(appData));
      }else{
        cacheAppData = appData;
      }
    }
  };
}
