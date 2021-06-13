
import 'package:flutter/services.dart';

import 'plugin_controller.dart';

class PluginControllerFactory {
  const PluginControllerFactory();
  PluginController create() {
    const MethodChannel _channelMethod =
        const MethodChannel('sharetrace/flutter.app.method');
    const EventChannel _eventChannel =
        const EventChannel('sharetrace/flutter.app.event');
    PluginController _controller = PluginController(
        traceChannel: _channelMethod, eventChannel: _eventChannel);
    return _controller;
  }
}
