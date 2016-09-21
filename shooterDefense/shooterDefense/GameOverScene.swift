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
        
        // set background color & background iamge
        backgroundColor = SKColor.black
        let backgroundMenu = SKSpriteNode(imageNamed: "background")
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -1
        addChild(backgroundMenu)
        
        
        // Set message based on flag
        let message = won ? "You Won!" : "You Lose :["
        
        // create message label
        let label = SKLabelNode(fontNamed: "Pixeled")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.white
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        
        // Set message based on flag
        let againMess = "Play Again?"
        // create message label
        let again = SKLabelNode(fontNamed: "Pixeled")
        again.text = againMess
        again.fontSize = 40
        again.fontColor = SKColor.white
        again.position = CGPoint(x: size.width/2, y: size.height/2-300)
        again.name = "game"
        addChild(again)
        
        // run transition and display -- JHAT: this code redisplayed the GameScene after 3 seconds
//        run(SKAction.sequence([
//            SKAction.wait(forDuration: 3.0),
//            SKAction.run() {
//                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
//                let scene = GameScene(size: size)
//                self.view?.presentScene(scene, transition:reveal)
//            }
//            ]))
    }
    
    // override init for scene
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
