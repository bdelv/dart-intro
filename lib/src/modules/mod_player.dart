// ------------------------
// Demo module: mod player
// ------------------------

import 'package:web/web.dart' as web;
import 'dart:js' as js;
import '../demo_module.dart';

class DemoMusic extends DemoModule {
  js.JsObject? jsPlayer;
  String? mod;

  DemoMusic() {
    web.document.body!.appendChild(web.HTMLScriptElement()..src = 'js/pt.js');
  }

  //  Set the parameters: name of the text element that contains the base64 encoded module
  DemoMusic setParams({String? mod}) {
    if (mod != null) this.mod = mod;
    return this;
  }

  // Load time: decode the base64 encoded text element into a uint8array for javascript
  @override
  void onLoad() {
    jsPlayer = js.JsObject(js.context['Protracker']);
    jsPlayer!.callMethod('setrepeat', [true]);
    jsPlayer!.callMethod('clearsong');
    jsPlayer!.callMethod('load', ["$mod"]);
    super.onLoad();
  }

  // Draw time: if the module is not playing yet, play
  @override
  void draw(web.CanvasRenderingContext2D context, num elapsedTime) {
    // useful only when using load method
    if (jsPlayer!['delayload'] == 0 &&
        jsPlayer!['playing'] == false &&
        jsPlayer!['ready'] == true) {
      jsPlayer!.callMethod('play');
    }
    super.draw(context, elapsedTime);
  }
}
