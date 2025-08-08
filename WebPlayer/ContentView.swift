//
//  ContentView.swift
//  WebKitDemo
//
//  Created by jht2 on 3/28/23.
//

import SwiftUI
import WebKit

let gold = Color(red: 1.0, green: 0.84, blue: 0.0) // Custom gold color
let freedomColors = [Color.red, gold, Color.green]


let refs = [
  "sketches/dist/index.html",
  "https://jht1493.net/p5videoKit/demo/",
  "sketches/shapes_random_pause_v22/index.html",
  "https://molab-itp.github.io/moSalon/src/faceMesh/index.html?&v=50&group=s1",
  "https://molab-itp.github.io/moSalon/src/faceMesh/qrcode/?v=50",
  "https://jht1493.net/p5videoKit/demo/",
  "sketches/shapes_random_pause_v22/index.html",
  "sketches/ims04-jht-scroll-color-v2/index.html",
  "https://jht9629-nyu.github.io/p5mirror-jht9629-nyu/p5projects/ims04-jht%20scroll%20color%20rate-2pxhnehBV/",
  "https://jht9629-nyu.github.io/p5mirror-jht9629-nyu/p5projects/shapes%20random%20pause%20v22-n0LYuXRmX/?v=1",
  "https://editor.p5js.org/jht9629-nyu/sketches/n0LYuXRmX",
  "https://editor.p5js.org/jht9629-nyu/sketches/2pxhnehBV",
  "https://itp.nyu.edu",
  "https://upload.wikimedia.org/wikipedia/commons/0/0a/Flag_of_Jamaica.svg",
  "https://upload.wikimedia.org/wikipedia/commons/9/99/Flag_of_Guyana.svg",
  "https://upload.wikimedia.org/wikipedia/en/a/a4/Flag_of_the_United_States.svg",
  "https://upload.wikimedia.org/wikipedia/commons/5/52/Flag_of_%C3%85land.svg",
  "https://upload.wikimedia.org/wikipedia/commons/6/6a/Flag_of_Zimbabwe.svg",
  "https://upload.wikimedia.org/wikipedia/commons/5/5c/Flag_of_the_Taliban.svg",
  "https://www.apple.com",
]
let ref = refs[0];

struct ContentView: View {
//  @State var webPage: WKWebView?
  @State var webRefModel = WebRefModel()
  var body: some View {
    ZStack {
      WebRefView(ref: ref, webRefModel: webRefModel)
      //      WebRefView(ref: ref, webPage: $webPage)
      VStack {
        Spacer()
        HStack {
          Text("Hello p5js")
          Button(action: plusAction) {
            Text("[+]")
          }
          Button(action: minusAction) {
            Text("[-]")
          }
        }
        .font(.title)
        .bold()
        .padding(10)
        //          .background(Color.yellow)
        .background(freedomColors.randomElement() ?? Color.red)
      }
    }
  }
  func plusAction () {
    print("plusAction ")
    print("webRefModel.webView", webRefModel.webView as Any)
    webRefModel.webView?.evaluateJavaScript("plusAction()")
    //    print("webPage", webPage as Any)
    //    gWebView?.evaluateJavaScript("plusAction()")
    //    webPage?.evaluateJavaScript("plusAction()")
  }
  func minusAction () {
    print("webRefModel.webView", webRefModel.webView as Any)
    webRefModel.webView?.evaluateJavaScript("minusAction()")
//    gWebView?.evaluateJavaScript("minusAction()")
  }
}



#Preview {
  ContentView()
}

// https://developer.apple.com/forums/thread/117348

// https://medium.com/devtechie/webview-in-swiftui-a9c283f29327

// flag svg link source:
// https://github.com/linssen/country-flag-icons/blob/master/countries.json

//    .ignoresSafeArea(edges: .all)
//    .onAppear() {
//      print("onAppear");
//      if let folderURL = Bundle.main.url(forResource: "sketches/shapes_random_pause_v22", withExtension: nil) {
//        print("Folder URL: \(folderURL)")
//      }
//    }
