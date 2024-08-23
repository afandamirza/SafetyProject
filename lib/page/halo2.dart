import 'dart:ui' as ui;
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:universal_html/html.dart';

void main() {
  // Register the view factory
  ui.platformViewRegistry.registerViewFactory(
    'iframeElement',
    (int viewId) => IFrameElement()
      ..src = 'https://maps.google.com/maps?q=-8.471357,113.343994&z=15&output=embed'
      ..width = '100%'
      ..height = '200'
      ..style.border = 'none',
  );

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Web with Iframe'),
        ),
        body: Center(
          child: Container(
            width: 640,
            height: 360,
            child: HtmlElementView(viewType: 'iframeElement'),
          ),
        ),
      ),
    );
  }
}

