// -------------------------------
// Demo module base class
// -------------------------------
import 'package:web/web.dart' as web;

class DemoModule {
  int x = 0;
  int y = 0;
  int width = 0;
  int height = 0;
  DemoModule? parent;
  List<DemoModule> childs = [];
  bool isLoaded = false;
  bool isStarted = false;
  bool isAdded = false;

  // Constructor
  DemoModule();

  // adds a child demo module in the tree
  addModule(DemoModule mod) {
    mod.parent = this;
    childs.add(mod);
    mod.onParentAdded();
  }

  // Called after the module has been given a parent. parent variable is accessible
  onParentAdded() {
    width = parent!.width;
    height = parent!.height;
    isAdded = true;
  }

  // Called when it is resource loading time
  onLoad() {
    for (var module in childs) {
      module.onLoad();
    }
    isLoaded = true;
  }

  // Called when it's time to start the demo
  onStart() {
    for (var module in childs) {
      module.onStart();
    }
    isStarted = true;
  }

  // Drawing time. Default is calling the Draw method of the childs
  draw(web.CanvasRenderingContext2D context, num elapsedTime) {
    for (var module in childs) {
      module.draw(context, elapsedTime);
    }
  }
}
