import 'package:web/web.dart' as web;
import 'package:dartintro/demo.dart';

void main() {
  DemoEngine engine = DemoEngine('demoArea');
  engine
    ..addModule(DemoFps().setParams(tag: "fps"))
    ..addModule(DemoClearBackground()
        .setParams(x: 0, y: 0, w: engine.width, h: engine.height))
    ..addModule(DemoStarfield().setParams(
        x: 0,
        y: 0,
        w: engine.width,
        h: engine.height,
        nb: 500,
        minV: 30,
        maxV: 60,
        direction: Direction.left.index))
    ..addModule(DemoBalls().setParams(
        x: 0,
        y: 0,
        w: engine.width,
        h: engine.height,
        file: "img/ball.png",
        nb: 100,
        velo: 200,
        interv: 829))
    // ..addModule(new DemoLogo()
    //     .setParams(x: 0, y: 0, w: engine.width, h: engine.height, tag: "gears"))
    ..addModule(DemoScrolling().setParams(
        x: 0,
        y: 0,
        w: engine.width,
        h: engine.height,
        file: "img/GEO_FONT_24.png",
        letterW: 32,
        letterH: 30,
        lettersOrder:
            " !   % '() +,-./0123456789:<>= ? ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        speed: 100,
        bounceBottom: engine.height - 32,
        bounceSpeed: 60,
        bounceRange: engine.height ~/ 4,
        text:
            "HELLO WORLD!!! THIS IS A DART DEMO. Lorem ipsum dolor sit amet, consectetur adipiscing elit. LET'S WRAP........    "))
    ..addModule(DemoMusic().setParams(mod: "mod/spacedeb.mod"));

  // Asks to click a button to start, to avoid Chrome blocking the audio at start
  (web.document.querySelector("#buttonStart") as web.HTMLButtonElement)
      .onClick
      .listen((e) {
    engine.load();
    engine.start();
    // remove the start button
    web.document.body!.removeChild(
        web.document.querySelector("#buttonStart") as web.HTMLButtonElement);
  });
}
