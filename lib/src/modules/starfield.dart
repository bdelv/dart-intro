// -------------------------------
// Demo module: Starfieeeeeeeeelds
// -------------------------------
// Very basic starfied.
// 4 directions.
// variances in star size (3 levels), min and max velocity

import 'package:web/web.dart' as web;
import 'dart:js_interop';
import 'dart:math' as math;
import '../demo_module.dart';

// ------------------------
// a Star of a Starfield
// ------------------------
class Star {
  int dx;
  int dy;
  late int x;
  late int y;
  int velocityX;
  int velocityY;
  int size;
  Star(this.dx, this.dy, this.size, this.velocityX, this.velocityY) {
    x = dx;
    y = dy;
  }
}

enum Direction { left, down, right, up }

class DemoStarfield extends DemoModule {
  final math.Random _rnd = math.Random();
  int nbStars = 100;
  int minVelocity = 15;
  int maxVelocity = 30;
  int direction = Direction.left.index;
  String color = '#ffffff';
  List<Star> stars = [];

  DemoStarfield();

  // Creates the array of stars with random position, speed and size
  void createStars() {
    stars.clear();
    switch (direction) {
      // direction: right
      case 0:
        for (int i = 0; i < nbStars; i++) {
          stars.add(Star(
              _rnd.nextInt(width),
              _rnd.nextInt(height),
              _rnd.nextInt(3) + 1,
              _rnd.nextInt(maxVelocity - minVelocity) + minVelocity,
              0));
        }
        break;
      // direction: down
      case 1:
        for (int i = 0; i < nbStars; i++) {
          stars.add(Star(
              _rnd.nextInt(width),
              _rnd.nextInt(height),
              _rnd.nextInt(3) + 1,
              0,
              _rnd.nextInt(maxVelocity - minVelocity) + minVelocity));
        }
        break;
      // direction: left
      case 2:
        for (int i = 0; i < nbStars; i++) {
          stars.add(Star(
              _rnd.nextInt(width),
              _rnd.nextInt(height),
              _rnd.nextInt(3) + 1,
              -(_rnd.nextInt(maxVelocity - minVelocity) + minVelocity),
              0));
        }
        break;
      // direction: up
      case 3:
        for (int i = 0; i < nbStars; i++) {
          stars.add(Star(
              _rnd.nextInt(width),
              _rnd.nextInt(height),
              _rnd.nextInt(3) + 1,
              0,
              -(_rnd.nextInt(maxVelocity - minVelocity) + minVelocity)));
        }
        break;
    }
  }

  // Set the parameters of the starfield
  // - rect of the strrarfield
  // - number of stars
  // - min and max velocity
  // - direction (0 to 3: right, down, left, up)
  DemoModule setParams(
      {int? x,
      int? y,
      int? w,
      int? h,
      int? nb = 100,
      int? minV = 15,
      int? maxV = 30,
      int? direction = 0,
      String? color = '#ffffff'}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) width = w;
    if (h != null) height = h;
    if (nb != null) nbStars = nb;
    if (minV != null) minVelocity = minV;
    if (maxV != null) maxVelocity = maxV;
    if (direction != null) this.direction = direction;
    if (isAdded) createStars();
    return this;
  }

  // Starfields: onLoad
  // Create the array of stars and updates the sliders
  @override
  void onLoad() {
    web.HTMLDivElement settings =
        web.document.querySelector("#settings") as web.HTMLDivElement;
    web.HTMLDivElement div =
        web.document.createElement('div') as web.HTMLDivElement;
    div.innerHTML = '''
      ---------------------- Starfield ---------------------<br>
      Count: 0 <input id="sliderNbStars" type="range" max="1000" value="100" /> 1000 --> <label
        id="TxtNbStars">0</label><br>
      Direction: 0 <input id="sliderStarsDir" type="range" max="3" value="0" /> 3 --> <label
        id="TxtStarsDir">0</label><br>
      ''';
    settings.appendChild(div);
    // callbacks for the sliders
    web.HTMLInputElement sliderNb =
        web.document.querySelector("#sliderNbStars") as web.HTMLInputElement;
    sliderNb.onChange.listen((web.Event e) {
      nbStars = int.parse(sliderNb.value);
      web.document.querySelector("#TxtNbStars")!.text = nbStars.toString();
      createStars();
    });
    web.HTMLInputElement sliderDirection =
        web.document.querySelector("#sliderStarsDir") as web.HTMLInputElement;
    sliderDirection.onChange.listen((web.Event e) {
      direction = int.parse(sliderDirection.value);
      web.document.querySelector("#TxtStarsDir")!.text = direction.toString();
      createStars();
    });
    _updateSliders();
    createStars();

    super.onLoad();
  }

  // Updates the sliders of the starfiled
  _updateSliders() {
    (web.document.querySelector("#sliderNbStars") as web.HTMLInputElement)
        .value = nbStars.toString();
    (web.document.querySelector("#TxtNbStars") as web.HTMLLabelElement).text =
        nbStars.toString();
    (web.document.querySelector("#sliderStarsDir") as web.HTMLInputElement)
        .value = direction.toString();
    (web.document.querySelector("#TxtStarsDir") as web.HTMLLabelElement).text =
        direction.toString();
  }

  // Draw time: Just calculate the position of each star depending on the Elapsed,
  // initial X,Y, velocityX,velocityY, and fillRect depending on size
  @override
  draw(web.CanvasRenderingContext2D context, num elapsedTime) {
    // update the stars coordinates
    context.fillStyle = color as JSAny;
    for (int i = 0; i < stars.length; i++) {
      Star star = stars[i];
      if (star.velocityY != 0) {
        star.y = y +
            ((star.dy + (elapsedTime / 1000) * star.velocityY).round() %
                height);
      }
      if (star.velocityX != 0) {
        star.x = x +
            ((star.dx + (elapsedTime / 1000) * star.velocityX).round() % width);
      }
      context.fillRect(star.x, star.y, star.size, star.size);
    }
    super.draw(context, elapsedTime);
  }
}
