//
//  ChromatonSim.swift
//  Chromoton Watch App
//
//  Created by Alex Cruikshank on 12/29/22.
//
let NUMBER_OF_GENES = 12;
let MUTATION_RATE = 50;         // likelyhood that a mutation will occur (out of 10000)
let NEIGHBOR_SEQUENCE_X = [-1, 1, 1, -1, 0, 0, 1, -1];
let NEIGHBOR_SEQUENCE_Y = [-1, 1, -1, 1, -1, 1, 0, 0];
let MAX_MATES = 3;              // maximum number of times a chromoton can breed
let PRIME_INC = 457;
let TARGET_CHANGE_PERIOD = 80;  // target will change 1/TARGET_CHANGE_PERIOD updates on average

struct Color {
  var red: UInt16
  var green: UInt16
  var blue: UInt16

  init(red: UInt16, green: UInt16, blue: UInt16) {
    self.red = red
    self.green = green
    self.blue = blue
  }
  
  mutating func clamp() {
    red = min(red, 255)
    green = min(green, 255)
    blue = min(blue, 255)
  }
  
  func deviance(other: Color) -> UInt16 {
    return UInt16(abs(Int(red) - Int(other.red))
    + abs(Int(green) - Int(other.green))
    + abs(Int(blue) - Int(other.blue)))
  }
}

func rndColor() -> Color {
  return Color(
    red: UInt16.random(in: 0..<256),
    green: UInt16.random(in: 0..<256),
    blue: UInt16.random(in: 0..<256))
}

struct Chromoton {
  var color: Color
  var deviance: UInt16
  var parentX: Int16
  var parentY: Int16
  var breedTimes: UInt8
  var chromosome: [UInt8]
  
  init(chromosome: [UInt8], target: Color) {
    // initialize parents
    parentX = -1
    parentY = -1
    color = Color(red: 0, green: 0, blue: 0)
    deviance = 0
    breedTimes = 0
    self.chromosome = [UInt8]()
    
    self.reset(chromosome: chromosome, target: target)
  }
  
  mutating func reset(chromosome: [UInt8], target: Color) {
    self.chromosome = chromosome

    // initialize red, green and blue
    color = Color(red: 0, green: 0, blue: 0)

    // set chromosome and determine color of chromoton
    for i in 0 ..< NUMBER_OF_GENES {
      // calculate ith low chromosome gene
      let gene: UInt8 = (chromosome[i] & 0x1F)
      let colorVal: UInt8 = gene >> 3
      let multiplier: UInt8 = gene & 0x7
      switch ( colorVal ) {
      case 1:     // red
        color.red += (1 << multiplier)
        break;
      case 2:     // green
        color.green += (1 << multiplier)
        break;
      case 3:     // blue
        color.blue += (1 << multiplier)
        break;
      default:
        break;
      }
    }
    color.clamp()
    
    // compute deviance from target
    deviance = color.deviance(other: target)
    
    // reset times chromoton has bred
    breedTimes = 0
  }
  
  mutating func breed(other: Chromoton, target: Color) {
    var chromosome = [UInt8](repeating: 0, count: NUMBER_OF_GENES) // new genes
    
    // create new chromosome
    for i in 0..<NUMBER_OF_GENES {
      let mask = UInt8.random(in: 0...255)
      chromosome[i] = ( self.chromosome[i] & mask ) | ( other.chromosome[i] & ~mask )
    }
        
    // determine if a mutation should occur
    if Int.random(in: 0..<10000) < MUTATION_RATE {
      let mutationBit = Int.random(in: 0..<NUMBER_OF_GENES)
      
      // mutate a single bit
      let mask = UInt8(1 << Int.random(in: 0..<8))
      chromosome[mutationBit] ^= mask
    }

    reset(chromosome: chromosome, target: target)
  }
}

struct ChromatonSim {
  var chromotons: [Chromoton] = []
  var numChromotons: Int
  var xChromotons: Int
  var yChromotons: Int
  var target: Color
  
  init(xChromotons: Int, yChromotons: Int) {
    self.xChromotons = xChromotons
    self.yChromotons = yChromotons
    self.numChromotons = xChromotons * yChromotons
    self.target = rndColor()

    let defaultChromosome = [UInt8](repeating: 0, count: NUMBER_OF_GENES)
    for _ in 0 ..< self.numChromotons {
      chromotons.append(Chromoton(chromosome: defaultChromosome, target: target))
    }
  }
  
  mutating func step() {
    var subIndex = 0              // index moded into range of array
    var deviance = 1<<30          // deviance of current mate
    var x: Int = 0                // x position of current chromoton
    var y: Int = 0                // y position of current chromoton
    var lowX: Int = 0             // x position of best mate for chromoton
    var lowY: Int = 0             // y position of best mate for chromoton
    var testX: Int = 0            // index of potential mate
    var testY: Int = 0            // index of potential mate
    var current: Chromoton        // current chrmoton
    var mate: Chromoton           // mate chromoton
    var sequenceIndex: Int = 0    // which direction to begin mate search
    var minDeviance: Int = 1<<30
    
    if Int.random(in: 0 ..< TARGET_CHANGE_PERIOD) == 0 {
      newTarget()
    }

    // perform a semi-random traversal of population
    subIndex = Int.random(in: 0 ..< numChromotons)
    for _ in 0 ..< numChromotons {
      subIndex = (subIndex+PRIME_INC) % numChromotons
      y = subIndex / xChromotons
      x = subIndex % xChromotons
      
      current = chromotons[subIndex]
      deviance = 1<<30
      lowX = -1
      lowY = -1
      
      // loop through potential mates
      for k in 0 ..< 8 {
        testX = x + NEIGHBOR_SEQUENCE_X[ ( k + sequenceIndex ) & 0x7 ]
        testY = y + NEIGHBOR_SEQUENCE_Y[ ( k + sequenceIndex ) & 0x7 ]
        
        if ( testY >= 0 ) && ( testY < yChromotons ) && ( testX >= 0 ) && ( testX < xChromotons ) {
          mate = chromotons[testY * xChromotons + testX]
          
          // if mate's deviance is too high, don't bother
          if ( mate.deviance < deviance ) && ( mate.breedTimes <= MAX_MATES ) {
            // make sure chromotons aren't siblings
            if (( current.parentX != testX ) || ( current.parentY != testY )
                && (( current.parentX != mate.parentX ) || ( current.parentY != mate.parentY ))) {
              // this one is an ok mate
              lowX = testX
              lowY = testY
              deviance = Int(mate.deviance)
            }
          }
        }
      }

      // if mate found, breed into next generation, else clone
      if ( lowX != -1 ) && ( lowY != -1 ) {
        let mateLocation = lowY * xChromotons + lowX
        mate = chromotons[mateLocation]
        current.breed(other: mate, target: target)
        current.parentX = Int16(lowX)
        current.parentY = Int16(lowY)

        mate.breedTimes += 1
        chromotons[mateLocation] = mate
      } else {
        current.reset(chromosome: current.chromosome, target: target);
        current.parentX = Int16(x);
        current.parentY = Int16(y);
      }
      
      if deviance < minDeviance {
        minDeviance = deviance;
      }
      
      // increment sequenceIndex
      sequenceIndex += 1
      
      chromotons[subIndex] = current
    }
  }
  
  mutating func newTarget() {
    target = rndColor()
  }
}
