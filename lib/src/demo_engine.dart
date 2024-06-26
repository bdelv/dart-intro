// ------------------------
// Demo Engine
// ------------------------
// Parent of all demo modules
// Takes care of
// - requesting redraws
// - Calling the child modules

import "dart:js_interop";
import "package:web/web.dart" as web;

import "demo_module.dart";

class DemoEngine extends DemoModule {
  int lastElapsedTime = DateTime.now().millisecondsSinceEpoch;
  int totalElapsedTime = 0;
  web.HTMLCanvasElement? canvas;

  // Engine Constructor. Gets the rect of the element
  DemoEngine(String htmlId) {
    canvas = web.document.querySelector("#$htmlId") as web.HTMLCanvasElement;
    // Measure the canvas element.
    width = canvas!.clientWidth;
    height = canvas!.clientHeight;
    canvas!.width = width;
    canvas!.height = height;
  }

  // starts the demo (requests the first animation frame)
  load() {
    onLoad();
  }

  // starts the demo (requests the first animation frame)
  start() {
    onStart();
    requestRedraw();
  }

  void requestRedraw() {
    web.window.requestAnimationFrame(drawCallback.toJS);
  }

  // callback for every frame
  void drawCallback(web.DOMHighResTimeStamp time) {
    // Calculates the timestamp
    int renderTime = DateTime.now().millisecondsSinceEpoch;
    totalElapsedTime += renderTime - lastElapsedTime;
    lastElapsedTime = renderTime;
    // Calls the Draw methods of the childs
    var context = canvas!.context2D;
    draw(context, totalElapsedTime);
    // Requests another draw frame
    requestRedraw();
  }
}
