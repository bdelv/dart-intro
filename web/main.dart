library Demo;

import 'dart:html';
import 'dart:math';
import 'dart:js';
import 'dart:typed_data';
//import 'package:crypto/crypto.dart'; // not available under dartpad. base64StringToBytes imported

void main() {
  CanvasElement canvas = querySelector("#area");
  DemoEngine engine = new DemoEngine(canvas);
  engine
    ..addModule(new DemoClearBackground().setParams(
        x: 0, y: 0, w: engine.width, h: engine.height))
    ..addModule(new DemoStarfield().setParams(
        x: 0,
        y: 0,
        w: engine.width,
        h: engine.height,
        nb: 500,
        minV: 30,
        maxV: 60,
        direction: Direction.left.index))
    ..addModule(new DemoLogo().setParams(
        x: 0, y: 0, w: engine.width, h: engine.height, tag: "gears"))
    ..addModule(new DemoBalls().setParams(
        x: 0,
        y: 0,
        w: engine.width,
        h: engine.height,
        img: "imgBall",
        nb: 100,
        velo: 200,
        interv: 30))
    ..addModule(new DemoScrolling().setParams(
        x: 0,
        y: 0,
        w: engine.width,
        h: engine.height,
        font: "font1",
        letterW: 32,
        letterH: 30,
        lettersOrder: " !   % '() +,-./0123456789:<>= ? ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        speed: 100,
        bounceBottom: engine.height - 32,
        bounceSpeed: 60,
        bounceRange: engine.height ~/ 4,
        text: "HELLO WORLD!!! THIS IS A DART DEMO. Lorem ipsum dolor sit amet, consectetur adipiscing elit. LET'S WRAP........    "))
    ..addModule(new DemoFps().setParams(tag: "fps"))
    ..addModule(new DemoMusic().setParams(mod: "mod"));
  engine.load();
  engine.start();
}

// -------------------------------
// Demo module base class
// -------------------------------
class DemoModule {
  int x = 0;
  int y = 0;
  int width, height;
  DemoEngine parent;
  List<DemoModule> childs = new List<DemoModule>();
  bool isLoaded = false;
  bool isStarted = false;
  bool isAdded = false;

  // Constructor
  DemoModule();

  // adds a child demo module in the tree
  addModule(DemoModule _mod) {
    _mod.parent = this;
    childs.add(_mod);
    _mod.onParentAdded();
  }

  // Called after the module has been given a parent. parent variable is accessible
  onParentAdded() {
    width = parent.width;
    height = parent.height;
    isAdded = true;
  }

  // Called when it is resource loading time
  onLoad() {
    for (var module in childs) module.onLoad();
    isLoaded = true;
  }

  // Called when it's time to start the demo
  onStart() {
    for (var module in childs) module.onStart();
    isStarted = true;
  }

  // Drawing time. Default is calling the Draw method of the childs
  Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    for (var module in childs) module.Draw(context, ElapsedTime);
  }
}

// ------------------------
// Demo Engine
// ------------------------
// Parent of all demo modules
// Takes care of
// - requesting redraws
// - Calling the child modules
class DemoEngine extends DemoModule {
  int LastElapsedTime = new DateTime.now().millisecondsSinceEpoch;
  int TotalElapsedTime = 0;
  CanvasElement canvas;
  Random _rnd = new Random();

  // Engine Constructor. Gets the rect of the element
  DemoEngine(this.canvas) {
    // Measure the canvas element.
    Rectangle rect = canvas.client;
    width = rect.width;
    height = rect.height;
    canvas.width = width;
    canvas.height = height;
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
    window.requestAnimationFrame(drawCallback);
  }
  // callback for every frame
  void drawCallback([_]) {
    // Calculates the timestamp
    int renderTime = new DateTime.now().millisecondsSinceEpoch;
    TotalElapsedTime += renderTime - LastElapsedTime;
    LastElapsedTime = renderTime;
    // Calls the Draw methods of the childs
    var context = canvas.context2D;
    Draw(context, TotalElapsedTime);
    // Requests another draw frame
    requestRedraw();
  }
}

// ---------------------------------
// Demo Module: Clear the background
// ---------------------------------
// Just clears the background
class DemoClearBackground extends DemoModule {
  // Sets the parameters: rect
  // Should add the color, or a source image
  DemoClearBackground setParams({int x, int y, int w, int h}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) width = w;
    if (h != null) height = h;
    return this;
  }

  // Draw time: clear
  void Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    context.clearRect(0, 0, parent.width, parent.height);
    super.Draw(context, ElapsedTime);
  }
}

// ------------------------
// Demo Module: FPS
// ------------------------
// Displays the average fps in an html element
class DemoFps extends DemoModule {
  num _fpsAverage;
  num _lasttime;
  String txtTag;

  // Defines the parameters (mainly the name of the html element)
  DemoModule setParams({String tag}) {
    if (tag != null) txtTag = tag;
    return this;
  }

  // Display the animation's FPS
  Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    if (_lasttime != null) {
      // actual frames per second calculated on the current frame
      num fps;
      if (ElapsedTime - _lasttime > 0) fps = 1000 / (ElapsedTime - _lasttime);
      else fps = 60;
      // mitigates the variations of fps
      if (_fpsAverage == null) _fpsAverage = fps;
      _fpsAverage = fps * 0.05 + _fpsAverage * 0.95;
      // assigns the value to the element
      Element _notes = querySelector("#" + txtTag);
      if (_notes != null) _notes.text = "${_fpsAverage.round()} fps";
    }
    _lasttime = ElapsedTime;
    super.Draw(context, ElapsedTime);
  }
}

// ------------------------
// a Star of a Starfield
// ------------------------
class Star {
  int dx;
  int dy;
  int x;
  int y;
  int velocityX;
  int velocityY;
  int size;
  Star(this.dx, this.dy, this.size, this.velocityX, this.velocityY) {
    x = dx;
    y = dy;
  }
}
enum Direction { left, down, right, up }
// -------------------------------
// Demo module: Starfieeeeeeeeelds
// -------------------------------
// Very basic starfied.
// 4 directions.
// variances in star size (3 levels), min and max velocity
class DemoStarfield extends DemoModule {
  Random _rnd = new Random();
  int nbStars = 100;
  int minVelocity = 15;
  int maxVelocity = 30;
  int direction = Direction.left.index;
  List<Star> stars = new List<Star>();

  // Creates the array of stars with random position, speed and size
  _CreateStars() {
    stars.clear();
    switch (direction) {
      // direction: right
      case 0:
        for (int i = 0; i < nbStars; i++) {
          stars.add(new Star(_rnd.nextInt(width), _rnd.nextInt(height),
              _rnd.nextInt(3) + 1,
              _rnd.nextInt(maxVelocity - minVelocity) + minVelocity, 0));
        }
        break;
      // direction: down
      case 1:
        for (int i = 0; i < nbStars; i++) {
          stars.add(new Star(_rnd.nextInt(width), _rnd.nextInt(height),
              _rnd.nextInt(3) + 1, 0,
              _rnd.nextInt(maxVelocity - minVelocity) + minVelocity));
        }
        break;
      // direction: left
      case 2:
        for (int i = 0; i < nbStars; i++) {
          stars.add(new Star(_rnd.nextInt(width), _rnd.nextInt(height),
              _rnd.nextInt(3) + 1,
              -(_rnd.nextInt(maxVelocity - minVelocity) + minVelocity), 0));
        }
        break;
      // direction: up
      case 3:
        for (int i = 0; i < nbStars; i++) {
          stars.add(new Star(_rnd.nextInt(width), _rnd.nextInt(height),
              _rnd.nextInt(3) + 1, 0,
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
  DemoModule setParams({int x, int y, int w, int h, int nb: 100, int minV: 15,
      int maxV: 30, int direction: 0}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) width = w;
    if (h != null) height = h;
    if (nb != null) {
      nbStars = nb;
      _updateSliders();
    }
    if (minV != null) minVelocity = minV;
    if (maxV != null) maxVelocity = maxV;
    if (direction != null) {
      this.direction = direction;
      _updateSliders();
    }
    if (isAdded) _CreateStars();
    return this;
  }

  // Starfields: onLoad
  // Create the array of stars and updates the sliders
  onLoad() {
    _CreateStars();
    InputElement sliderNb = querySelector("#sliderNbStars");
    sliderNb.onChange.listen((Event e) {
      nbStars = int.parse(sliderNb.value);
      querySelector("#TxtNbStars").text = nbStars.toString();
      _CreateStars();
    });
    InputElement sliderDirection = querySelector("#sliderStarsDir");
    sliderDirection.onChange.listen((Event e) {
      direction = int.parse(sliderDirection.value);
      querySelector("#TxtStarsDir").text = direction.toString();
      _CreateStars();
    });
    super.onLoad();
  }

  // Updates the sliders of the starfiled
  _updateSliders() {
    (querySelector("#sliderNbStars") as InputElement).value =
        nbStars.toString();
    (querySelector("#TxtNbStars") as LabelElement).text = nbStars.toString();
    (querySelector("#sliderStarsDir") as InputElement).value =
        direction.toString();
    (querySelector("#TxtStarsDir") as LabelElement).text = direction.toString();
  }

  // Draw time: Just calculate the position of each star depending on the Elapsed,
  // initial X,Y, velocityX,velocityY, and fillRect depending on size
  Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    // update the stars coordinates
    context.fillStyle = '#ffffff';
    for (int i = 0; i < stars.length; i++) {
      Star star = stars[i];
      if (star.velocityY != 0) {
        star.y = y +
            ((star.dy + (ElapsedTime / 1000) * star.velocityY).round() %
                height);
      }
      if (star.velocityX != 0) {
        star.x = x +
            ((star.dx + (ElapsedTime / 1000) * star.velocityX).round() % width);
      }
      context.fillRect(star.x, star.y, star.size, star.size);
    }
    super.Draw(context, ElapsedTime);
  }
}

// -------------------------------
// demo module: demo balls
// -------------------------------
// the path of the balls is a "circle of circles" (a kind of flower)
// the first ball is displayed depending on ElapsedTime and Velocity
// the next balls are taken from the path array adding the interval variable
// Depending on the interval value, it can give a funny dance
class DemoBalls extends DemoModule {
  int nbBalls = 100;
  List<Point> tabCoord = new List<Point>();
  int velocity = 200;
  int interval = 30;
  String imgTag;

  // Sets the parameters of the demo balls
  // rect, sprite element name, number, velocity, interval
  DemoModule setParams({int x, int y, int w, int h, String img, int nb: 100,
      int velo: 200, int interv: 30}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) width = w;
    if (h != null) height = h;
    if (img != null) imgTag = img;
    if (nb != null) nbBalls = nb;
    if (velo != null) velocity = velo;
    if (interv != null) interval = interv;
    _updateSliders();
    if (isAdded) _CreateCoords();
    return this;
  }

  // Updates the sliders
  _updateSliders() {
    (querySelector("#sliderNbBalls") as InputElement).value =
        nbBalls.toString();
    (querySelector("#TxtNbBalls") as LabelElement).text = nbBalls.toString();
    (querySelector("#sliderInterval") as InputElement).value =
        interval.toString();
    (querySelector("#TxtInterval") as LabelElement).text = interval.toString();
  }

  // Load time: Create the path array and updates the sliders
  onLoad() {
    _CreateCoords();
    InputElement sliderNb = querySelector("#sliderNbBalls");
    sliderNb.onChange.listen((Event e) {
      nbBalls = int.parse(sliderNb.value);
      querySelector("#TxtNbBalls").text = nbBalls.toString();
    });
    InputElement sliderInterval = querySelector("#sliderInterval");
    sliderInterval.onChange.listen((Event e) {
      interval = int.parse(sliderInterval.value);
      querySelector("#TxtInterval").text = interval.toString();
    });
    super.onLoad();
  }

  // Creates precalculated path array (the flower)
  _CreateCoords() {
    ImageElement ImgE = querySelector("#" + imgTag);
    for (int i = 0; i < 10000; i++) {
      tabCoord.add(new Point(x +
          (width - ImgE.width) ~/ 2 +
          ((cos(i * 2 * PI / 1000) + cos(i * 2 * PI / 10000)) *
              (width - ImgE.width) /
              4).round(), y +
          (height - ImgE.height) ~/ 2 +
          ((sin(i * 2 * PI / 1000) + sin(i * 2 * PI / 10000)) *
              (height - ImgE.height) /
              4).round()));
    }
  }

  // Draw time: 1st ball depend on velocity and time, next balls depend on interval
  Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    ImageElement ImgE = querySelector("#" + imgTag);
    int tmpIdx = (ElapsedTime / 1000 * velocity).round() % tabCoord.length;
    for (int i = 0; i < nbBalls; i++) {
      context.drawImage(ImgE, tabCoord[tmpIdx].x, tabCoord[tmpIdx].y);
      tmpIdx = (tmpIdx + interval) % tabCoord.length;
    }
  }
}

// ------------------------
// Demo module: moving logo
// ------------------------
class DemoLogo extends DemoModule {
  String tagImg;

  // Sets the parameters: rect + name of the element that contains the logo
  DemoModule setParams({int x, int y, int w, int h, String tag}) {
    this.x = x;
    this.y = y;
    this.width = w;
    this.height = h;
    tagImg = tag;
    return this;
  }

  // Draw time: copy the logo
  Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    int tag=(ElapsedTime/100).round()%6 +1;
//    ImageElement ImgE = querySelector("#" + tagImg+"0"+tag.toString());
    ImageElement ImgE = querySelector("#" + tagImg+"0"+tag.toString());
    if (ImgE != null) {
      context.drawImage(ImgE, x +
          ((cos(ElapsedTime / 200) + 1.0) * (width - ImgE.width) / 2)
              .round(), 0);
    }
    super.Draw(context, ElapsedTime);
  }
}

// ----------------------------
// Demo module: Text scrolling
// ----------------------------
class DemoScrolling extends DemoModule {
  String LettersOrder =
      " !   % '() +,-./0123456789:<>= ? ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  String Text = "HELLO WORLD!!!    ";
  int LetterW = 32;
  int LetterH = 30;
  int speed = 40;
  int bounceBottom = 0;
  int bounceSpeed = 1000;
  int bounceRange = 0;
  String tagImg;

  // Set the parameters:
  // - rect
  // - name of the html element that contains the bitmap font
  // - width and height of the letters
  // - String containing the order the characters drawn in the font
  // - speed
  // - bounce bottom coordinate, bounce speed, bounce amplitude
  // - text of the scrolling
   DemoScrolling setParams({int x, int y, int w, int h, String font, int letterW,
      int letterH, String lettersOrder, int speed: 40, int bounceBottom: 100,
      int bounceSpeed: 200, int bounceRange,
      String text: "Hello world!!!!   "}) {
    if (x != null) this.x = x;
    if (y != null) this.y = y;
    if (w != null) this.width = w;
    if (h != null) this.height = h;
    if (letterW != null) this.LetterW = letterW;
    if (letterH != null) this.LetterH = letterH;
    if (font != null) this.tagImg = font;
    if (speed != null) this.speed = speed;
    if (bounceBottom != null) this.bounceBottom = bounceBottom;
    if (bounceSpeed != null) this.bounceSpeed = bounceSpeed;
    if (bounceRange != null) this.bounceRange = bounceRange;
    if (lettersOrder != null) LettersOrder = lettersOrder;
    if (text != null) Text = text;
    return this;
  }

  // Draw time: do some magic and display a bouncy scrolling
  Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    int currY = bounceBottom -
        (sin(((ElapsedTime / 1000) * PI * bounceSpeed / 100) % PI) *
            bounceRange).round();

    int startX = this.x;
    int idxLetter = 0;

    // first letter (index in the Text, starting part of the letter to copy)
    idxLetter = ((ElapsedTime * speed) ~/ 1000) ~/ LetterW;
    int tmpLetterX = ((ElapsedTime * speed) ~/ 1000) % LetterW;

    ImageElement fontElem = querySelector("#" + tagImg);
    while (startX < this.x + this.width) {
      // if the index of the letter is past the last letter of the text, wrap
      idxLetter %= Text.length;
      // get the letter
      int idx = LettersOrder.indexOf(Text[idxLetter].toUpperCase());
      // finds the coordinate of the letter in the font
      if (idx < 0) idx = 0;
      int letterX = ((idx * LetterW) % fontElem.width);
      int letterY = ((idx * LetterW) ~/ fontElem.width) * LetterH;
      // width of the copied letter (less if on the right end, or the left end)
      int tmpWidth = LetterW;
      if (startX == this.x) tmpWidth -= tmpLetterX;
      if (this.x + this.width < startX + LetterW) tmpWidth =
          this.x + this.width - startX;
      // draws the letter
      context.drawImageToRect(
          fontElem, new Rectangle(startX, currY, tmpWidth, LetterH),
          sourceRect: new Rectangle(
              letterX + tmpLetterX, letterY, tmpWidth, LetterH));
      // next
      tmpLetterX = 0;
      startX += tmpWidth;
      idxLetter++;
    }
    super.Draw(context, ElapsedTime);
  }
}

// ------------------------
// Demo module: mod player
// ------------------------
class DemoMusic extends DemoModule {
  var module = new JsObject(context['Protracker']);
  String mod;

  //  Set the parameters: name of the text element that contains the base64 encoded module
  DemoMusic setParams({String mod}) {
    if (mod != null) this.mod = mod;
    return this;
  }

  // Load time: decode the base64 encoded text element into a uint8array for javascript
  onLoad() {
    module.callMethod('setrepeat', [true]);
    String modBase64 = querySelector("#" + mod).text;
    final List<int> intList = /*CryptoUtils.*/ base64StringToBytes(modBase64);
    final Uint8List uint8list = new Uint8List.fromList(intList);
    module.callMethod('clearsong');
    module['buffer'] = new JsArray.from(uint8list);
    module.callMethod('parse');
    // Load the module from a URL
//    module.callMethod('load', [mod]);
    super.onLoad();
  }

  // Draw time: if the module is not playing yet, play
  Draw(CanvasRenderingContext2D context, num ElapsedTime) {
    // useful only when using load method
    if (module['delayload'] == 0 && module['playing'] == false) {
      module.callMethod('play');
    }
    super.Draw(context, ElapsedTime);
  }
}

// ---------------------------------------
// base64StringToBytes
// ---------------------------------------
// Used to decode base64 encoded text element (for the mod player)
// Copied from dart SDK

// Lookup table used for finding Base 64 alphabet index of a given byte.
// -2 : Outside Base 64 alphabet.
// -1 : '\r' or '\n'
//  0 : = (Padding character).
// >0 : Base 64 alphabet index of given byte.
/*static */ const List<int> _decodeTable = const [
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -1,
  -2,
  -2,
  -1,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  62,
  -2,
  62,
  -2,
  63,
  52,
  53,
  54,
  55,
  56,
  57,
  58,
  59,
  60,
  61,
  -2,
  -2,
  -2,
  0,
  -2,
  -2,
  -2,
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  11,
  12,
  13,
  14,
  15,
  16,
  17,
  18,
  19,
  20,
  21,
  22,
  23,
  24,
  25,
  -2,
  -2,
  -2,
  -2,
  63,
  -2,
  26,
  27,
  28,
  29,
  30,
  31,
  32,
  33,
  34,
  35,
  36,
  37,
  38,
  39,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  47,
  48,
  49,
  50,
  51,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2,
  -2
];
/*static */ const int PAD = 61; // '='

/*static */ List<int> base64StringToBytes(String input) {
  int len = input.length;
  if (len == 0) {
    return new List<int>(0);
  }
// Count '\r', '\n' and illegal characters, For illegal characters,
// throw an exception.
  int extrasLen = 0;
  for (int i = 0; i < len; i++) {
    int c = _decodeTable[input.codeUnitAt(i)];
    if (c < 0) {
      extrasLen++;
      if (c == -2) {
        throw new FormatException('Invalid character: ${input[i]}');
      }
    }
  }
  if ((len - extrasLen) % 4 != 0) {
    throw new FormatException('''Size of Base 64 characters in Input
          must be a multiple of 4. Input: $input''');
  }
// Count pad characters.
  int padLength = 0;
  for (int i = len - 1; i >= 0; i--) {
    int currentCodeUnit = input.codeUnitAt(i);
    if (_decodeTable[currentCodeUnit] > 0) break;
    if (currentCodeUnit == PAD) padLength++;
  }
  int outputLen = (((len - extrasLen) * 6) >> 3) - padLength;
  List<int> out = new List<int>(outputLen);

  for (int i = 0, o = 0; o < outputLen;) {
// Accumulate 4 valid 6 bit Base 64 characters into an int.
    int x = 0;
    for (int j = 4; j > 0;) {
      int c = _decodeTable[input.codeUnitAt(i++)];
      if (c >= 0) {
        x = ((x << 6) & 0xFFFFFF) | c;
        j--;
      }
    }
    out[o++] = x >> 16;
    if (o < outputLen) {
      out[o++] = (x >> 8) & 0xFF;
      if (o < outputLen) out[o++] = x & 0xFF;
    }
  }
  return out;
}
