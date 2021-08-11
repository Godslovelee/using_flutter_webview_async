
import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
double progress;
bool pageError = false;

ContextMenu contextMenu;
InAppWebViewController webViewController;
InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      // disableContextMenu: true
    ),
    android: AndroidInAppWebViewOptions(useHybridComposition: true));


PullToRefreshController pullToRefreshController;
