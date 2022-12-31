//
//  ContentView.swift
//  Chromoton Watch App
//
//  Created by Alex Cruikshank on 12/28/22.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
  @EnvironmentObject var extensionDelegate: ChromatonExtensionDelegate

  var scene: ChromatonScene {
    let device = WKInterfaceDevice.current()
    let devicePixels = device.screenBounds.size
    // CGSize(width: 410, height: 502)
    let size = CGSize(width: devicePixels.width * device.screenScale, height: devicePixels.height * device.screenScale)
    print(WKInterfaceDevice.current())
    let scene = ChromatonScene(size: size)
    scene.size = size
    scene.scaleMode = .fill
    
    extensionDelegate.contentView = self
    extensionDelegate.scene = scene
    
    return scene
  }

  var body: some View {
    let cScene = scene
    SpriteView(scene: cScene)
      .edgesIgnoringSafeArea(.all)
      .gesture(TapGesture().onEnded{ _ in cScene.newTarget() })
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
