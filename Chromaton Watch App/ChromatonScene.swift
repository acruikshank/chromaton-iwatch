//
//  ChromatonScene.swift
//  Chromoton Watch App
//
//  Created by Alex Cruikshank on 12/28/22.
//

import WatchKit
import SpriteKit
import UIKit

let boxWidth = 14
let boxHeight = 14
let boxGap = 2
let updateInterval = 0.1

extension Color {
  var uiColor: UIColor { return UIColor(
    red: CGFloat(self.red)/255.0,
    green: CGFloat(self.green)/255.0,
    blue: CGFloat(self.blue)/255.0,
    alpha: 1.0)
  }
}

class ChromatonScene: SKScene {
  var rects: [SKSpriteNode] = []
  var sim: ChromatonSim
  var lastUpate: TimeInterval = 0
  
  override init(size aSize: CGSize) {
    let size = CGSize(width: boxWidth, height: boxHeight)
    let columns = Int(ceil((aSize.width-CGFloat(boxGap))/CGFloat(boxWidth + boxGap)))
    let rows = Int(ceil((aSize.height-CGFloat(boxGap))/CGFloat(boxHeight + boxGap)))
    
    sim = ChromatonSim(xChromotons: columns, yChromotons: rows)
    
    super.init(size: aSize)
    
    for j in 0 ..< rows {
      for i in 0 ..< columns {
        let position = CGPoint(
          x: i*(boxWidth + boxGap),
          y: j*(boxHeight + boxGap))
        
        let chromaton = sim.chromotons[j*columns + i]
        rects.append(box(size: size, position: position, color: chromaton.color.uiColor))
      }
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    sim = ChromatonSim(xChromotons: 0, yChromotons: 0)
    super.init(coder: aDecoder)
  }
  
  override func update(_ currentTime: TimeInterval) {
    if currentTime - lastUpate >= updateInterval {
      sim.step()
      
      for i in 0 ..< rects.count {
        rects[i].color = sim.chromotons[i].color.uiColor
      }
      
      lastUpate = currentTime
    }
  }
  
  func box(size s: CGSize, position p: CGPoint, color: UIColor) -> SKSpriteNode {
    let box = SKSpriteNode(color: color, size: s)
    box.position = p
    addChild(box)
    return box
  }
  
  func newTarget() {
    sim.newTarget()
  }
}
