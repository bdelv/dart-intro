// ------------------------
// Demo Module: FPS
// ------------------------

import 'package:web/web.dart' as web;
import '../demo_module.dart';

// Displays the average fps in an html element
class DemoFps extends DemoModule {
  num? _fpsAverage;
  num? _lasttime;
  String txtTag = '';
  web.HTMLTextAreaElement? textArea;

  DemoFps();

  // Defines the parameters (mainly the name of the html element)
  DemoModule setParams({String? tag}) {
    if (tag != null) txtTag = tag;
    return this;
  }

  @override
  void onLoad() {
    web.document
        .querySelector("#settings")!
        .appendChild(web.HTMLTextAreaElement()
          ..text = 'fps'
          ..id = 'fps');
    textArea = web.document.querySelector("#fps") as web.HTMLTextAreaElement;
    super.onLoad();
  }

  // Display the animation's FPS
  @override
  void draw(web.CanvasRenderingContext2D context, num elapsedTime) {
    if (_lasttime != null) {
      // actual frames per second calculated on the current frame
      num fps;
      if (elapsedTime - _lasttime! > 0) {
        fps = 1000 / (elapsedTime - _lasttime!);
      } else {
        fps = 60;
      }
      // mitigates the variations of fps
      _fpsAverage ??= fps;
      _fpsAverage = fps * 0.05 + _fpsAverage! * 0.95;
      // assigns the value to the element
      textArea!.text = "${_fpsAverage!.round()} fps";
    }
    _lasttime = elapsedTime;
    super.draw(context, elapsedTime);
  }
}
