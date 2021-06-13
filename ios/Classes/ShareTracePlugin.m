#import "ShareTracePlugin.h"
#import <SharetraceSDK/SharetraceSDK.h>

@interface ShareTracePlugin()<SharetraceDelegate,FlutterStreamHandler>

@property (nonatomic, strong)AppData *cacheAppData;
@property (nonatomic, assign)BOOL hasWakeupRegisted;

@end

@implementation ShareTracePlugin{
    FlutterEventSink _eventSink;
}
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"sharetrace/flutter.app.method" binaryMessenger:[registrar messenger]];
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:@"sharetrace/flutter.app.event" binaryMessenger:[registrar messenger]];
    ShareTracePlugin* instance = [[ShareTracePlugin alloc] init];
    [registrar addApplicationDelegate:instance];
    [registrar addMethodCallDelegate:instance channel:channel];
    [eventChannel setStreamHandler:instance];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"init" isEqualToString:call.method]) {
      if(call.arguments[@"serverDomain"]){
          NSString *serverDomain = call.arguments[@"serverDomain"];
          NSLog(@"=======> %@",serverDomain);
      }
      if(call.arguments[@"appKey"]){
          NSString *appKey = call.arguments[@"appKey"];
          [Sharetrace initWithDelegate:self appKey:appKey];
      }else{
          [Sharetrace initWithDelegate:self];
      }
    result(@YES);
      
  }else if([@"getInstallTrace" isEqualToString:call.method]){
      NSTimeInterval timeout = 10;
      if(call.arguments[@"defaultTimeout"]){
          NSNumber *timeoutSeconds = call.arguments[@"defaultTimeout"];
          NSTimeInterval targetTimeInterval  = [timeoutSeconds doubleValue];;
          if (targetTimeInterval > 0) {
              timeout = targetTimeInterval;
          }
      }
      NSTimeInterval targetTimeout = timeout * 1000;
      [Sharetrace getInstallTraceWithTimeout:targetTimeout success:^(AppData * _Nullable appData) {
          NSDictionary *resultData;
          if (appData == nil || [appData paramsData] == nil || [[appData paramsData] length]<=0) {
              resultData = [self parseToResultCode:-1 msg:@"Extract data fail." params:@"" channel:@""];
          }else{
              [self setCacheAppData:appData];
              resultData = [self parseToResultCode:200 msg:@"Success" params:[appData paramsData] channel:[appData channel]];
          }
          result(resultData);
      } fail:^(NSInteger code, NSString * _Nonnull msg) {
          NSDictionary *resultData = [self parseToResultCode:code msg:msg params:@"" channel:@""];
          result(resultData);
      }];
  }else if([@"getCacheTraceData" isEqualToString:call.method]){
      NSDictionary *resultData;
      if (self.cacheAppData == nil || [self.cacheAppData paramsData] == nil || [[self.cacheAppData paramsData] length]<=0) {
          resultData = [self parseToResultCode:-1 msg:@"未发现数据." params:@"" channel:@""];
      }else{
          resultData = [self parseToResultCode:200 msg:@"Success" params:[self.cacheAppData paramsData] channel:[self.cacheAppData channel]];
      }
      result(resultData);
  }else if([@"registerWakeup" isEqualToString:call.method]){
      [self setHasWakeupRegisted:YES];
      if (self.cacheAppData && [self.cacheAppData paramsData] && [[self.cacheAppData paramsData] length]>0) {
          [self wakeupResponse: [self parseToResultCode:200 msg:@"Success" params:[self.cacheAppData paramsData] channel:[self.cacheAppData channel]]];
      }
      result(@YES);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)getWakeUpTrace:(AppData *)appData{
    if(self.hasWakeupRegisted){
        if(appData == nil || appData.paramsData == nil || [appData.paramsData length] <= 0){
            return;
        }
        [self setCacheAppData:appData];
        NSDictionary *ret = [self parseToResultCode:200 msg:@"Success" params:appData.paramsData channel:appData.channel];
        [self wakeupResponse:ret];
    }
}

- (void)wakeupResponse:(NSDictionary *) ret {
    if(_eventSink){
        _eventSink(ret);
    }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

-(NSDictionary *)parseToResultCode:(NSInteger)code msg:(NSString*)msg params:(NSString*)paramsData channel:(NSString*)channel {
    return @{@"code":[@(code) stringValue],@"msg":msg,@"paramsData":paramsData,@"channel":channel};
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
    [Sharetrace handleSchemeLinkURL:url];
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    [Sharetrace handleSchemeLinkURL:url];
    return NO;
}

- (BOOL)application:(UIApplication*)application continueUserActivity:(NSUserActivity*)userActivity restorationHandler:(void (^)(NSArray*))restorationHandler {
    [Sharetrace handleUniversalLink:userActivity];
    return NO;
}

+ (BOOL)handleSchemeLinkURL:(NSURL * _Nullable)url {
    return [Sharetrace handleSchemeLinkURL:url];
}

+ (BOOL)handleUniversalLink:(NSUserActivity * _Nullable)userActivity {
    return [Sharetrace handleUniversalLink:userActivity];
}


- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events{
    _eventSink = events;
    return nil;
}

- (FlutterError *)onCancelWithArguments:(id)arguments{
    _eventSink = nil;
    return nil;
}

@end
