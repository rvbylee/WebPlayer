//
//  ContentView.swift
//  WebKitDemo
//
//  Created by jht2 on 3/28/23.
//

import SwiftUI
import WebKit

let goldColor = Color(red: 1.0, green: 0.84, blue: 0.0) // Custom gold color
let greenColor = Color(red: 0.12, green: 0.88, blue: 0.6);
let redColor = Color(red: 1.0, green: 182.0/255.0, blue: 193.0/255.0);
// 255, 182, 193) -- light pink
let freedomColors = [redColor, goldColor, greenColor]

struct ContentView: View {
  @State var webRefModel = WebRefModel()
  var body: some View {
    NavigationView {
      List {
        ForEach(items, id: \.ref) { item in
          NavigationLink( destination: ItemDetail(item: item, webRefModel: webRefModel)) {
            ItemRow(item: item)
              .background(freedomColors.randomElement() ?? Color.white)
              .font(.headline)
          }
        }
      }
      .navigationTitle("WebPlayer")
      .navigationBarTitleDisplayMode(.inline)
    }
  }
}

struct ItemDetail: View {
  var item:Item
  let webRefModel: WebRefModel
  var body: some View {
    VStack {
      Text(item.label)
        .font(.caption)
      WebRefView(ref: item.ref, webRefModel: webRefModel)
    }
  }
}

struct ItemRow: View {
  var item:Item
  var body: some View {
    HStack {
      Text(item.label)
      Spacer()
    }
    .padding(5)
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
