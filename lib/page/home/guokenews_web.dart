import 'dart:convert';
import 'dart:ui';

import 'package:pure_read/common/dao/httpdao.dart';
import 'package:pure_read/common/dao/note.dart';
import 'package:pure_read/common/util/navigator_util.dart';
import 'package:pure_read/page/aggregationnews/model/Guoke/guoke_newdetail.dart';
import 'package:pure_read/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:share/share.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GuokeNewsWeb extends StatefulWidget {
  const GuokeNewsWeb({Key key, this.title, this.id, this.url})
      : super(key: key);

  final String title;
  final String id;
  final String url;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return GuokeNewsWebState();
  }
}

class GuokeNewsWebState extends State<GuokeNewsWeb> {
  bool hasCollect = false;

  void _onPopSelected(String value) {
    String _title = widget.title ?? "新闻详情";
    switch (value) {
      case "browser":
        NavigatorUtil.launchInBrowser(widget.url, title: _title);
        break;
      case "collection":
        break;
      case "share":
        String _url = widget.url;
        Share.share('$_title : $_url');
        break;
      default:
        break;
    }
  }

  Note page;
  @override
  void initState() {
    checkPageHasCollect();
  }

  Future<void> checkPageHasCollect() async {
    page = await NoteProvider.getWebPageByTime(widget.url);
    if (page != null) {
      hasCollect = true;
      setState(() {});
    }
  }

  WebViewController _webViewController;
  GuokeNewDetail guokeNewDetail;

  Future<bool> getGuokeNewDetail() async {
    guokeNewDetail = await HttpDao.getGuokeNewsDetail(widget.url);
    return true;
  }

  _loadHtmlFromAssets() async {
    _webViewController.loadUrl(Uri.dataFromString(guokeNewDetail.result.content,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar:  AppBar(
        elevation: 3,
        brightness: Brightness.light,
        backgroundColor: AppTheme.nearlyWhite,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            }),
        title:  Text(
          widget.title ?? "新闻详情",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppTheme.darkText,
            fontFamily: "LanTing",
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            tooltip: "收藏",
            icon: Hero(
              tag: "collect",
              child: Icon(
                  hasCollect == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.redAccent[100]),
            ),
            onPressed: ()  {
              if(hasCollect){
                NoteProvider.deleteWebPage(page.id);
                hasCollect = false;
              }
              else{
                NoteProvider.insertWebPage(Note(time: DateTime.now().toIso8601String(),title: widget.title,content: widget.url,));
                checkPageHasCollect();
              }
              setState(() {});
            },
          ),
          new PopupMenuButton(
              icon: Icon(Icons.menu,color: AppTheme.darkText),
              padding: const EdgeInsets.all(0.0),
              onSelected: _onPopSelected,
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                    value: "browser",
                    child: ListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        dense: false,
                        title: new Container(
                          alignment: Alignment.center,
                          child: new Row(
                            children: <Widget>[
                              Icon(
                                Icons.language,
                                color: AppTheme.darkText,
                                size: 22.0,
                              ),
                              Text(
                                '浏览器打开',
                                style: TextStyle(
                                  color: AppTheme.darkText,
                                  fontFamily: "LanTing",
                                ),
                              )
                            ],
                          ),
                        ))),
                PopupMenuItem<String>(
                    value: "share",
                    child: ListTile(
                        contentPadding: EdgeInsets.all(0.0),
                        dense: false,
                        title: new Container(
                          alignment: Alignment.center,
                          child: new Row(
                            children: <Widget>[
                              Icon(
                                Icons.share,
                                color: Colors.black,
                                size: 22.0,
                              ),
                              Text(
                                '分享',
                                style: TextStyle(
                                  color: AppTheme.darkText,
                                  fontFamily: "LanTing",
                                ),
                              )
                            ],
                          ),
                        ))),
              ])
        ],
      ),
      body:  WebView(
        onWebViewCreated: (WebViewController webViewController) {
        },
        initialUrl: widget.url,
        javascriptMode: JavascriptMode.unrestricted,
          userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
      ),
    );
  }

/*  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return FutureBuilder(
      future: getGuokeNewDetail(),
      builder: (context, data) {
      if (data.data == false) {
        return SpinKitFoldingCube(color: Colors.blue);
      } else {
        _loadHtmlFromAssets();
        return Scaffold(
          appBar: AppBar(
            elevation: 3,
            brightness: Brightness.light,
            backgroundColor: AppTheme.nearlyWhite,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text(
              widget.title ?? "新闻详情",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.darkText,
                fontFamily: "LanTing",
              ),
            ),
            centerTitle: true,
            actions: <Widget>[
              IconButton(
                tooltip: "收藏",
                icon: Hero(
                  tag: "collect",
                  child: Icon(
                      hasCollect == true
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent[100]),
                ),
                onPressed: () {
                  if (hasCollect) {
                    NoteProvider.deleteWebPage(page.id);
                    hasCollect = false;
                  } else {
                    NoteProvider.insertWebPage(Note(
                      time: DateTime.now().toIso8601String(),
                      title: widget.title,
                      content: widget.url,
                    ));
                    checkPageHasCollect();
                  }
                  setState(() {});
                },
              ),
              PopupMenuButton(
                  icon: Icon(Icons.menu, color: AppTheme.darkText),
                  padding: const EdgeInsets.all(0.0),
                  onSelected: _onPopSelected,
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                        PopupMenuItem<String>(
                            value: "browser",
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0.0),
                                dense: false,
                                title: new Container(
                                  alignment: Alignment.center,
                                  child: new Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.language,
                                        color: AppTheme.darkText,
                                        size: 22.0,
                                      ),
                                      Text(
                                        '浏览器打开',
                                        style: TextStyle(
                                          color: AppTheme.darkText,
                                          fontFamily: "LanTing",
                                        ),
                                      )
                                    ],
                                  ),
                                ))),
                        PopupMenuItem<String>(
                            value: "share",
                            child: ListTile(
                                contentPadding: EdgeInsets.all(0.0),
                                dense: false,
                                title: new Container(
                                  alignment: Alignment.center,
                                  child: new Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.share,
                                        color: Colors.black,
                                        size: 22.0,
                                      ),
                                      Text(
                                        '分享',
                                        style: TextStyle(
                                          color: AppTheme.darkText,
                                          fontFamily: "LanTing",
                                        ),
                                      )
                                    ],
                                  ),
                                ))),
                      ])
            ],
          ),
          body: WebView(
            onWebViewCreated: (WebViewController webViewController) {
              _webViewController = webViewController;
            },
            initialUrl: "about:blank",
            javascriptMode: JavascriptMode.unrestricted,
              userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.108 Safari/537.36"
          ),
        );
      }
    });
  }*/
}
