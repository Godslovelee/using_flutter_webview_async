import 'dart:io';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:enclib/data/error_handle.dart';

void main() {
  runApp(MyApp());
}

String version = "1.1";
String header = "Enc Academy e-Library v$version";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: header,
      home: MyApp2(),
      theme: new ThemeData(scaffoldBackgroundColor: const Color(0xFF04226C)),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp2 extends StatefulWidget {
  @override
  _MyApp2State createState() => _MyApp2State();
}

const S3CR3T_T0K3N =

//add your webtokens here
    "AaufgyukFYFifTFtyfJDFgDFJdrDRdtyFKyfTdtSDtdfiTdtDTRdtrKDfdRDrDUJrdTRdtrDUTDItdITDitDFIdidfITRDrdittrfITdtDFIgfFtpq";

class _MyApp2State extends State<MyApp2> {
  String url = "https://www.encacademy.com/$S3CR3T_T0K3N/home.html";
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

  void secureScreen() async {
    await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  void initState() {
    super.initState();
    secureScreen();

    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
          color: Colors.blue,
        ),
        onRefresh: refresh);

    contextMenu = ContextMenu(
        menuItems: [],
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: true),
        onCreateContextMenu: (hitTestResult) async {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
              width: 250,
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cancel,
                    color: Colors.orangeAccent,
                  ),
                  new Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "This functionality has been disabled",
                        textAlign: TextAlign.center,
                      )),
                ],
              )));
        });
  }

  void refresh() async {
    if (Platform.isAndroid) {
      webViewController?.reload();
    } else if (Platform.isIOS) {
      webViewController?.loadUrl(
          urlRequest: URLRequest(url: await webViewController?.getUrl()));
    }
  }

  @override
  void dispose() => super.dispose();

  Future<Iterator<WebHistoryItem>> getHistory() async {
    WebHistory _webHistory = await webViewController.getCopyBackForwardList();

    var history = _webHistory.list.reversed
        .where((item) =>
    item.index <= _webHistory.currentIndex &&
        item.url.toString() != "data:text/html;charset=utf-8;base64,")
        .iterator;

    history.moveNext();
    return history;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          header,
          style: TextStyle(color: Colors.blue),
        ),
        bottom: PreferredSize(
          child: LinearProgressIndicator(
            backgroundColor: Colors.white70.withOpacity(0),
            value: progress == 1.0 ? 0 : progress,
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          preferredSize: Size.fromHeight(3.0),
        ),
        actions: <Widget>[
          Tooltip(
            message: "Go Home",
            child: TextButton(
                onPressed: () async {
                  var history =
                  await webViewController.getCopyBackForwardList();
                  setState(() {
                    progress = null;
                    pageError = false;
                  });
                  webViewController.goTo(historyItem: history.list[0]);
                },
                child: Icon(Icons.home)),
          )
        ],
        backgroundColor: Color(0xFF04226C),
        backwardsCompatibility: false,
        systemOverlayStyle:
        SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      body: WillPopScope(
          onWillPop: () => _goBack(context), child: getContentView()),
    );
  }

  Widget getContentView() {
    print("getContentView $pageError [${pageError ? 1 : 0}]");
    return Stack(children: [
      getWebView(),
      pageError ? makeErrorPage() : SizedBox(width: 0, height: 0)
    ]);
  }

  Widget makeErrorPage() {
    return Transform.scale(
        scale: 1.3,
        child: Container(
          color: Color(0xFF04226C),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "An error occurred",
                style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.yellow,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async {
                        webViewController.goTo(
                            historyItem: (await getHistory()).current);
                        setState(() => pageError = false);
                      },
                      child: Text("RELOAD")),
                ],
              )
            ],
          ),
        ));
  }

  Widget getWebView() {
    return InAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(url)),
      initialOptions: options,
      contextMenu: contextMenu,
      pullToRefreshController: pullToRefreshController,
      onWebViewCreated: (controller) => webViewController = controller,
      onLoadStop: (controller, url) => pullToRefreshController.endRefreshing(),
      onLoadError: handleError,
      onLoadHttpError: handleError,
      onProgressChanged: (controller, progress) {
        if (progress == 100) pullToRefreshController.endRefreshing();
        setState(() => this.progress = progress / 100);
      },
    );
  }

  handleError(controller, url, code, message) {
    pullToRefreshController.endRefreshing();
    webViewController.loadData(data: "");
    setState(() => pageError = true);
  }

  DateTime currentBackPressTime;

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      var history = await getHistory();
      history.moveNext();
      setState(() => pageError = false);
      webViewController.goTo(historyItem: history.current);
      return Future.value(false);
    } else {
      DateTime now = DateTime.now();
      if (currentBackPressTime == null ||
          now.difference(currentBackPressTime) > Duration(seconds: 2)) {
        currentBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 1),
              width: 185,
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info,
                    color: Colors.lightBlue,
                  ),
                  new Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Press back again to exit",
                        textAlign: TextAlign.center,
                      )),
                ],
              )),
        );
        return Future.value(false);
      }
      return Future.value(true);
    }
  }
}