//
//  GameViewController.swift
//  SpriteKitSimpleGame
//
//  Created by student on 8/30/16.
//  Copyright (c) 2016 student. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = GameScene(size: view.bounds.size)
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .resizeFill
        
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
