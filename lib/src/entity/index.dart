
class AppData {
  int code;
  String msg;
  String paramsData;
  String channel;
  AppData({
    this.code,
    this.msg,
    this.paramsData,
    this.channel
  });
  
  Map<String, dynamic> toJson() {
    return {
      'code':this.code,
      'msg':this.msg,
      'paramsData':this.paramsData,
      'channel':this.channel
    };
  }
}