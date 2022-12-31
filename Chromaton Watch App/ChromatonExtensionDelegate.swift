//
//  ChromatonExtensionDelegate.swift
//  Chromoton Watch App
//
//  Created by Alex Cruikshank on 12/30/22.
//
import UIKit
import SwiftUI
import WatchKit

class ChromatonExtensionDelegate: NSObject, WKExtensionDelegate, ObservableObject {
  var scene: ChromatonScene?
  var contentView: (any View)?
  
  func applicationDidBecomeActive() {
    if let nnScene = scene {
      nnScene.newTarget()
    }
  }  
}
