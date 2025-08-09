//
//  WebView.swift
//  MoGallery
//
//  Created by jht2 on 4/16/23.
//

import SwiftUI
@preconcurrency import WebKit

struct WebRefView : UIViewRepresentable {
  
  let ref: String
  let webRefModel: WebRefModel
  
  func update(key: String, value: Double) {
    xprint("WebViewRef update key", key, "value", value)
  }
  
  func updateUIView(_ uiView: WKWebView, context: Context) {
      
    if ref.hasPrefix("https://") {
      loadURL(uiView)
    }
    else {
      loadFile(uiView)
    }
  }
  
  func loadURL(_ uiView: WKWebView) {
    // https reference
    let url = URL(string: ref);
    print("WebViewRef update url", url ?? "")
    guard let nurl = url else {
      print("URL failed", ref)
      return;
    }
    print("WebViewRef nurl", nurl)
    
    uiView.load(URLRequest(url: nurl))
  }
  
  func loadFile(_ uiView: WKWebView) {
    // local reference path
    let url = Bundle.main.url(forResource:ref, withExtension: nil);
    print("WebViewRef local url", url ?? "")
    guard let nurl = url else {
      print("WebViewRef local failed", ref)
      return;
    }
    print("WebViewRef local nurl", nurl)
    let req = URLRequest(url: nurl)
    let dir = nurl.deletingLastPathComponent()
    
    uiView.loadFileRequest(req, allowingReadAccessTo: dir)
  }

  func makeUIView(context: Context) -> WKWebView  {
    return webRefModel.makeWebView()
  }
}

// https://www.hackingwithswift.com/books/ios-swiftui/using-coordinators-to-manage-swiftui-view-controllers

func xprint(_ args:Any...) {
  print( args )
  // debugPrint( args )
}
