//
//  ChromotonApp.swift
//  Chromoton Watch App
//
//  Created by Alex Cruikshank on 12/28/22.
//

import SwiftUI

@main
struct Chromaton_Watch_AppApp: App {
  @WKExtensionDelegateAdaptor var extensionDelegate: ChromatonExtensionDelegate
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
