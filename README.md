# Dart Intro

Old style demo. Just for the fun of testing Dart

![Screenshoit](screenshot.png)

Live demo: http://dartdemo.papakiatech.com/
click on the start button

V1.2014:
- Dartpad - Dart - Javascript - Protracker - Inline Gfx/Zik
- The initial challenge was to be able to launch a self-sufficient demo in Dartpad all contained in a Dart/Html/Css set

V2.2024:
- Upgrade Dart SDK v2 to V3 (null safety)
- Migrate dart:html -> package:web/web.dart
- Dartpad doesn't seem to accept anymore dart/html/css files. So now, **webdev build** will generate a static site
- Split the code
- Use files for data (no more embedded in the html)
- Bypass Chrome autoplay policy changes (the start button)

# Setup:

```
dart pub global activate webdev
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

- Launch / debug: (supports hot reload) 
```
webdev serve
```
Open a browser on the URL

Click on the **start** button

- Build static site: 
```
webdev build
```
