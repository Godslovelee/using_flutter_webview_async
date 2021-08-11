# Usage
A flutter app for making an entire complete webview using webview controllers
and passing tokens
```dart
const S3CR3T_T0K3N =

//add your webtokens here
    "ndkjansdkjsandadsadsadgefrerfesadsadsadsadvsadsadsa";

```

# UI

```dart
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
```dart


```


A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
