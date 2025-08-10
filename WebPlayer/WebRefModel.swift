//
//  WebRefModel.swift
//  WebPlayer
//
//  Created by jht2 on 8/8/25.
//

@preconcurrency import WebKit

class WebRefModel : NSObject, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler  {
  
  var webView: WKWebView?
  
  func makeWebView() -> WKWebView  {
    if let webView  {
      webView.loadHTMLString("<html><body><h1>Loading.../h1></body></html>", baseURL: nil)
      return webView
    }
    let webConfiguration = WKWebViewConfiguration()
    webConfiguration.allowsInlineMediaPlayback = true;
    // webConfiguration.allowsAirPlayForMediaPlayback = true;
    // webConfiguration.allowsPictureInPictureMediaPlayback = true;
    webConfiguration.mediaTypesRequiringUserActionForPlayback = [];
    
    let webController = WKUserContentController()
    webController.add(self, name: "dice")
    webConfiguration.userContentController = webController;
    
    let wkWebView = WKWebView(frame: .zero, configuration: webConfiguration)
    wkWebView.isInspectable = true;
    
    wkWebView.uiDelegate = self
    wkWebView.navigationDelegate = self
    
    print("makeUIView wkWebView", wkWebView as Any)
    webView = wkWebView;

    return wkWebView
  }

  func userContentController(
    _ userContentController: WKUserContentController,
    didReceive message: WKScriptMessage
  ) {
    xprint("userContentController didReceive message", message)
    xprint("userContentController didReceive message.name", message.name)
    xprint("userContentController didReceive message.body", message.body)
    guard message.name == "dice" else {
      return
    }
    guard let body = message.body as? NSDictionary else {
      return
    }
    xprint("userContentController body", body)
    guard let stats = body["stats"] as? NSDictionary else {
      return
    }
    xprint("userContentController stats", stats)
    if let init_lapse = stats["init_lapse"] as? Double {
      xprint("userContentController init_lapse", init_lapse)
//      parent.update( key: "init_lapse", value: init_lapse )
    }
    if let load_lapse = stats["load_lapse"] as? Double {
      xprint("userContentController load_lapse", load_lapse)
//      parent.update( key: "load_lapse", value: load_lapse )
    }
    // load_lapse
  }
  
  func webView(
    _ webView: WKWebView,
    requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin,
    initiatedByFrame frame: WKFrameInfo,
    decisionHandler: @escaping (WKPermissionDecision) -> Void
  ) {
    xprint("requestDeviceOrientationAndMotionPermissionFor origin", origin)
    decisionHandler(.grant);
  }
  
  func webView(
    _ webView: WKWebView,
    requestMediaCapturePermissionFor origin: WKSecurityOrigin,
    initiatedByFrame frame: WKFrameInfo,
    type: WKMediaCaptureType,
    decisionHandler: @escaping (WKPermissionDecision) -> Void
  ) {
    xprint("requestMediaCapturePermissionFor origin type", type.rawValue)
    // xprint("requestMediaCapturePermissionFor origin", origin, "type", type.rawValue)
    decisionHandler(.grant);
  }
  
  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    preferences: WKWebpagePreferences,
    decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
  ) {
    xprint("decidePolicyFor preferences navigationAction")
    // xprint("decidePolicyFor preferences navigationAction", navigationAction, "preferences", preferences)
    decisionHandler(.allow, preferences)
    
    // !!@ Links failing to load - force it here.
    //
    if (navigationAction.navigationType != .other) {
      webView.load(navigationAction.request);
    }
  }
  
  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
  ) {
    xprint("decidePolicyFor navigationAction")
    // xprint("decidePolicyFor navigationAction", navigationAction)
    decisionHandler(.allow)
  }
  
  func webView(
    _ webView: WKWebView,
    decidePolicyFor navigationResponse: WKNavigationResponse,
    decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void
  ) {
    xprint("decidePolicyFor navigationResponse")
    // xprint("decidePolicyFor navigationResponse", navigationResponse)
    decisionHandler(.allow)
  }
}
