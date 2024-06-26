// ---------------------------------
// Demo Module: Clear the background
// ---------------------------------

import 'package:web/web.dart' as web;
import '../demo_module.dart';

// Just clears the background
class DemoClearBackground extends DemoModule {
  // Sets the parameters: rect
  // Should add the color, or a source image
  DemoClearBackground setParams({int? x, int? y, int? w, int? h}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) width = w;
    if (h != null) height = h;
    return this;
  }

  // Draw time: clear
  @override
  void draw(web.CanvasRenderingContext2D context, num elapsedTime) {
    context.clearRect(0, 0, parent!.width, parent!.height);
    super.draw(context, elapsedTime);
  }
}
