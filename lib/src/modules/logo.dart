// ------------------------
// Demo module: moving logo
// ------------------------

import 'package:web/web.dart' as web;
import 'dart:math' as math;
import '../demo_module.dart';

class DemoLogo extends DemoModule {
  String? tagImg;

  // Sets the parameters: rect + name of the element that contains the logo
  DemoModule setParams({int? x, int? y, int? w, int? h, String? tag}) {
    this.x = x!;
    this.y = y!;
    width = w!;
    height = h!;
    tagImg = tag;
    return this;
  }

  // Draw time: copy the logo
  @override
  void draw(web.CanvasRenderingContext2D context, num elapsedTime) {
//    int tag=(ElapsedTime/100).round()%6 +1;
    int tag = (elapsedTime / 100).round() % 2 + 5;
//    ImageElement ImgE = querySelector("#" + tagImg+"0"+tag.toString());
    web.HTMLImageElement imgE =
        web.document.querySelector("#${tagImg!}0$tag") as web.HTMLImageElement;
    // if (ImgE != null) {
    context.drawImage(imgE, 300, 300);
    context.drawImage(
        imgE,
        x +
            ((math.cos(elapsedTime / 2000) + 1.0) * (width - imgE.width) / 2)
                .round(),
        280);
    // save the current co-ordinate system
    // before we screw with it
    context.save();
    // move to the middle of where we want to draw our image
    context.translate(100, 100);
    // rotate around that point, converting our
    // angle from degrees to radians
    context.rotate(elapsedTime / 20000);
    // draw it up and to the left by half the width
    // and height of the image
    context.drawImage(imgE, -(imgE.width / 2), -(imgE.height / 2));
    // and restore the co-ords to how they were when we began
    context.restore();
    // }
    super.draw(context, elapsedTime);
  }
}
