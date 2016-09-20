//
//  GameOverScene.swift
//  SpriteKitSimpleGame
//
//  Created by Justin Hatin (RIT Student) on 8/30/16.
//  Copyright © 2016 student. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    init(size: CGSize, won:Bool) {
        
        super.init(size: size)
        
        // set background color
        backgroundColor = SKColor.white
        
        // Set message based on flag
        let message = won ? "You Won!" : "You Lose :["
        
        // create message label
        let label = SKLabelNode(fontNamed: "Pixeled")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        // run transition and display
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        
    }
    
    // override init for scene
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
