//
//  IntervalScene.swift
//  Interval
//
//  Created by Anoop Naravaram on 1/12/15.
//  Copyright (c) 2015 Anoop Naravaram. All rights reserved.
//

import UIKit
import SpriteKit
import CoreMotion

class IntervalScene: SKScene {
    
    var noteForTouch:[UITouch : Note] = [UITouch : Note]();
    let synth = Synthesizer()
    let motionManager = CMMotionManager()
    
    var tiltScrolling = false
    
    override func didMoveToView(view: SKView) {
        
        // prepare the synthesizer to start making sounds
        synth.start()
        
        // prepare the accelerometer
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.020 // 20 ms, 50 Hz
        
        // customize the scene
        self.scaleMode = .ResizeFill
        self.backgroundColor = UIColor.brownColor()
        
        // add the keyboard node to the scene
        let keyboardNode = SKNode()
        keyboardNode.name = "keyboard"
        self.addChild(keyboardNode)
        
        // add the keyboard scroll node to the keyboard node
        // this node is moved to scroll the keyboard
        let keyboardScrollNode = SKNode()
        keyboardScrollNode.name = "keyboardScroll"
        keyboardScrollNode.position = CGPointZero
        keyboardNode.addChild(keyboardScrollNode)
        
        // add each of the keys
        for i in 0..<8 { // rows, from bottom to top
            for j in 0..<7 { // columns, from left to right
                
                // figure out what type of key this is (if any), from the row/col number
                var imageNameOpt:String? // if nil, there is no key at this row/col number
                if ((i + j) % 2 == 1) {
                    imageNameOpt = "WhiteKey"
                } else if (j != 0 && j != 6) {
                    imageNameOpt = "BlackKey"
                }
                
                if let imageName = imageNameOpt {
                    
                    let keyNode = SKSpriteNode(imageNamed: imageName)
                    let note:Note = 47 + 6*i + j // the note to be played when this key is pressed
                    
                    if (imageName == "WhiteKey") {
                        // label the key if it is white
                        let labelNode = SKLabelNode()
                        // find the label text from the note number
                        labelNode.text = ["C", "", "D", "", "E", "F", "", "G", "", "A", "", "B"][Int(note) % 12]
                        
                        labelNode.fontColor = UIColor.blackColor()
                        labelNode.fontSize = 150
                        labelNode.fontName = "HelveticaBold"
                        labelNode.verticalAlignmentMode = .Center
                        
                        labelNode.position = CGPointZero
                        keyNode.addChild(labelNode)
                        
                        // color the key according to its note number
                        if let c =
                            [1:UIColor.redColor(),
                                2:UIColor.yellowColor(),
                                3:UIColor.greenColor(),
                                4:UIColor.blueColor()][
                                    [1, 0, 2, 0, 3, 1, 0, 2, 0, 3, 0, 4, 0][Int(note) % 12]] {
                            keyNode.color = c
                            keyNode.colorBlendFactor = 0.5
                        }
                    }
                    
                    // name the key node to associate it with the note it produces
                    keyNode.name = "\(note)"
                    
                    keyNode.position = CGPoint(x: 200.0 * CGFloat(j) - 600.0, y: 200.0 * CGFloat(i) - 700.0)
                    keyboardScrollNode.addChild(keyNode)
                }
            }
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        if let keyboardNode = self.childNodeWithName("keyboard") {
            let keyboardWidth:CGFloat = 1400.0
            let keyboardHeight:CGFloat = 1600.0
            
            /*
            if (keyboardHeight / keyboardWidth < self.size.height / self.size.width) {
                // extra space on top and bottom
                keyboardNode.position = {r in CGPoint(x: r.midX, y: r.midY)}(CGRect(origin: CGPointZero, size: self.size))
                keyboardNode.setScale(self.size.width / keyboardWidth)
            } else {
                // extra space on left and right
                keyboardNode.position = {r in CGPoint(x: r.midX, y: r.midY)}(CGRect(origin: CGPointZero, size: self.size))
                keyboardNode.setScale(self.size.height / keyboardHeight)
            }
            */
            
            tiltScrolling = keyboardHeight / keyboardWidth > self.size.height / self.size.width;
            
            keyboardNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
            keyboardNode.setScale(self.size.width / keyboardWidth)
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for obj in touches {
            let touch = obj as UITouch
            if let keyboardScrollNode = self.childNodeWithName("keyboard/keyboardScroll") {
                
                for obj in keyboardScrollNode.children {
                    let keyNode = obj as SKNode
                    if keyNode.containsPoint(touch.locationInNode(keyboardScrollNode)) {
                        if let noteInt = keyNode.name?.toInt() {
                            let note = Note(noteInt)
                            noteForTouch[touch] = note
                            synth.noteOn(note)
                            keyNode.runAction(SKAction.scaleTo(0.7, duration: 0.1))
                        }
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        for obj in touches {
            let touch = obj as UITouch
            if let note:Note = noteForTouch[touch] {
                synth.noteOff(note)
                if let keyboardScrollNode = self.childNodeWithName("keyboard/keyboardScroll") {
                    if let keyNode = keyboardScrollNode.childNodeWithName("\(note)") {
                        keyNode.runAction(SKAction.scaleTo(1.0, duration: 0.1))
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        touchesEnded(touches, withEvent: event)
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        if let keyboardNode = self.childNodeWithName("keyboard") {
        }
        
        if let keyboardScrollNode = self.childNodeWithName("keyboard/keyboardScroll") {
            if (tiltScrolling) {
                if let accel = motionManager.accelerometerData?.acceleration {
                    let targetPt = CGPoint(x: 0, y: {
                        ()->CGFloat in
                        switch UIApplication.sharedApplication().statusBarOrientation {
                        case .LandscapeLeft:
                            return CGFloat(accel.x - 0.5) * (400.0 / 0.5)
                        case .LandscapeRight:
                            return CGFloat(-accel.x - 0.5) * (400.0 / 0.5)
                        default:
                            return 0.0
                        }
                    }())
                    
                    keyboardScrollNode.runAction(SKAction.moveTo(targetPt, duration: 0.2))
                }
            } else {
                keyboardScrollNode.position = CGPointZero
            }
        }
    }
}
