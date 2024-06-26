// -------------------------------
// demo module: demo balls
// -------------------------------
// the path of the balls is a "circle of circles" (a kind of flower)
// the first ball is displayed depending on ElapsedTime and Velocity
// the next balls are taken from the path array adding the interval variable
// Depending on the interval value, it can give a funny dance

import 'package:web/web.dart' as web;
import 'dart:math' as math;
import '../demo_module.dart';

class DemoBalls extends DemoModule {
  int nbBalls = 100;
  List<math.Point> tabCoord = [];
  int velocity = 200;
  int interval = 30;
  String file = '';
  web.HTMLImageElement? imgSrc;

  DemoBalls();

  // Sets the parameters of the demo balls
  // rect, sprite element name, number, velocity, interval
  DemoModule setParams(
      {int? x,
      int? y,
      int? w,
      int? h,
      String? file,
      int? nb = 100,
      int? velo = 200,
      int? interv = 30}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) width = w;
    if (h != null) height = h;
    if (file != null) this.file = file;
    if (nb != null) nbBalls = nb;
    if (velo != null) velocity = velo;
    if (interv != null) interval = interv;
    imgSrc = web.HTMLImageElement()..src = this.file;
    return this;
  }

  // Updates the sliders
  _updateSliders() {
    (web.document.querySelector("#sliderNbBalls") as web.HTMLInputElement)
        .value = nbBalls.toString();
    (web.document.querySelector("#TxtNbBalls") as web.HTMLLabelElement).text =
        nbBalls.toString();
    (web.document.querySelector("#sliderInterval") as web.HTMLInputElement)
        .value = interval.toString();
    (web.document.querySelector("#TxtInterval") as web.HTMLLabelElement).text =
        interval.toString();
  }

  // Load time: Create the path array and updates the sliders
  @override
  void onLoad() {
    web.HTMLDivElement settings =
        web.document.querySelector("#settings") as web.HTMLDivElement;
    web.HTMLDivElement div =
        web.document.createElement('div') as web.HTMLDivElement;
    div.innerHTML = '''
    ------------------------Balls -----------------------<br>
    Count: 0 <input id="sliderNbBalls" type="range" max="300" value="100" /> 300 --> <label
      id="TxtNbBalls">0</label><br>
    Interval: 0 <input id="sliderInterval" type="range" max="10000" value="500" /> 10000 --> <label
      id="TxtInterval">0</label><br>
      ''';
    settings.appendChild(div);

    _updateSliders();
    createCoords();

    web.HTMLInputElement sliderNb =
        web.document.querySelector("#sliderNbBalls") as web.HTMLInputElement;
    sliderNb.onChange.listen((web.Event e) {
      nbBalls = int.parse(sliderNb.value);
      web.document.querySelector("#TxtNbBalls")!.text = nbBalls.toString();
    });
    web.HTMLInputElement sliderInterval =
        web.document.querySelector("#sliderInterval") as web.HTMLInputElement;
    sliderInterval.onChange.listen((web.Event e) {
      interval = int.parse(sliderInterval.value);
      web.document.querySelector("#TxtInterval")!.text = interval.toString();
    });
    super.onLoad();
  }

  // Creates precalculated path array (the flower)
  createCoords() {
    const nbValues = 10000;
    for (int i = 0; i < nbValues; i++) {
      tabCoord.add(math.Point(
          x +
              (width ~/ 2) +
              ((math.cos(i * 2 * math.pi / 1000) +
                          math.cos(i * 2 * math.pi / nbValues)) *
                      (width - imgSrc!.width) /
                      4)
                  .round(),
          y +
              (height ~/ 2) +
              ((math.sin(i * 2 * math.pi / 1000) +
                          math.sin(i * 2 * math.pi / nbValues)) *
                      (height - imgSrc!.height) /
                      4)
                  .round()));
    }
  }

  // Draw time: 1st ball depend on velocity and time, next balls depend on interval
  @override
  void draw(web.CanvasRenderingContext2D context, num elapsedTime) {
    int tmpIdx = (elapsedTime / 1000 * velocity).round() % tabCoord.length;
    for (int i = 0; i < nbBalls; i++) {
      context.drawImage(imgSrc!, tabCoord[tmpIdx].x - (imgSrc!.width ~/ 2),
          tabCoord[tmpIdx].y - (imgSrc!.height ~/ 2));
      tmpIdx = (tmpIdx + interval) % tabCoord.length;
    }
    super.draw(context, elapsedTime);
  }
}
