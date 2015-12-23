//
//  ViewController.swift
//  Interval
//
//  Created by Anoop Naravaram on 1/11/15.
//  Copyright (c) 2015 Anoop Naravaram. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.userInteractionEnabled = true
        self.view.multipleTouchEnabled = true
        
        let skView = self.view as SKView
        let skScene = IntervalScene()
        skView.presentScene(skScene)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

