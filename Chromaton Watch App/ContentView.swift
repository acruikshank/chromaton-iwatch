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
  @State private var targetPeriod = 4.0

  var scene: ChromatonScene {
    let device = WKInterfaceDevice.current()
    let devicePixels = device.screenBounds.size
    let size = CGSize(width: devicePixels.width * device.screenScale, height: devicePixels.height * device.screenScale)
    print(WKInterfaceDevice.current())
    let scene = ChromatonScene(size: size, targetPeriod: $targetPeriod)
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
      .focusable()
      .digitalCrownRotation($targetPeriod,
                            from: 0.5,
                            through: 20.0,
                            by: 0.02,
                            sensitivity: .high,
                            isContinuous: false,
                            isHapticFeedbackEnabled: true)
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
