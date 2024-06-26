// ----------------------------
// Demo module: Text scrolling
// ----------------------------

import 'package:web/web.dart' as web;
import 'dart:math' as math;
import '../demo_module.dart';

class DemoScrolling extends DemoModule {
  String lettersOrder =
      " !   % '() +,-./0123456789:<>= ? ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  String text = "HELLO WORLD!!!    ";
  int letterW = 32;
  int letterH = 30;
  int speed = 40;
  int bounceBottom = 0;
  int bounceSpeed = 1000;
  int bounceRange = 0;
  String file = "";
  web.HTMLImageElement? imgSrc;

  // Set the parameters:
  // - rect
  // - name of the html element that contains the bitmap font
  // - width and height of the letters
  // - String containing the order the characters drawn in the font
  // - speed
  // - bounce bottom coordinate, bounce speed, bounce amplitude
  // - text of the scrolling
  DemoScrolling setParams(
      {int? x,
      int? y,
      int? w,
      int? h,
      String? file,
      int? letterW,
      int? letterH,
      String? lettersOrder,
      int? speed = 40,
      int? bounceBottom = 100,
      int? bounceSpeed = 200,
      int? bounceRange,
      String? text = "Hello world!!!!   "}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) width = w;
    if (h != null) height = h;
    if (letterW != null) this.letterW = letterW;
    if (letterH != null) this.letterH = letterH;
    if (file != null) this.file = file;
    if (speed != null) this.speed = speed;
    if (bounceBottom != null) this.bounceBottom = bounceBottom;
    if (bounceSpeed != null) this.bounceSpeed = bounceSpeed;
    if (bounceRange != null) this.bounceRange = bounceRange;
    if (lettersOrder != null) this.lettersOrder = lettersOrder;
    if (text != null) this.text = text;
    return this;
  }

  // Load time: Create the path array and updates the sliders
  @override
  void onLoad() {
    imgSrc = web.HTMLImageElement()..src = file;
    super.onLoad();
  }

  // Draw time: do some magic and display a bouncy scrolling
  @override
  void draw(web.CanvasRenderingContext2D context, num elapsedTime) {
    int currY = bounceBottom -
        (math.sin(((elapsedTime / 1000) * math.pi * bounceSpeed / 100) %
                    math.pi) *
                bounceRange)
            .round();

    int startX = x;

    // first letter (index in the Text, starting part of the letter to copy)
    int idxLetter = ((elapsedTime * speed) ~/ 1000) ~/ letterW;
    int tmpLetterX = ((elapsedTime * speed) ~/ 1000) % letterW;

    while (startX < x + width) {
      // if the index of the letter is past the last letter of the text, wrap
      idxLetter %= text.length;
      // get the letter
      int idx = lettersOrder.indexOf(text[idxLetter].toUpperCase());
      // finds the coordinate of the letter in the font
      if (idx < 0) idx = 0;
      int w = imgSrc!.width;
      int letterX = ((idx * letterW) % w);
      int letterY = ((idx * letterW) ~/ 320) * letterH;
      // width of the copied letter (less if on the right end, or the left end)
      int tmpWidth = letterW;
      if (startX == x) tmpWidth -= tmpLetterX;
      if (x + width < startX + letterW) tmpWidth = x + width - startX;
      // draws the letter
      context.drawImage(imgSrc!, letterX + tmpLetterX, letterY, tmpWidth,
          letterH, startX, currY, tmpWidth, letterH);
      // next
      tmpLetterX = 0;
      startX += tmpWidth;
      idxLetter++;
    }
    super.draw(context, elapsedTime);
  }
}
