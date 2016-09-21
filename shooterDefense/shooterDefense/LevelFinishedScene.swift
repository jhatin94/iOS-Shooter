//
//  LevelFinishedScene.swift
//  SpriteKitSimpleGame
//
//  Created by Justin Hatin (RIT Student) on 8/30/16.
//  Copyright © 2016 student. All rights reserved.
//

import Foundation
import SpriteKit

class LevelFinishedScene: SKScene {
    let sceneManager: GameViewController
    var levelFinished: Int
    init(size: CGSize, won:Bool, level: Int, sceneManager: GameViewController) {
        self.sceneManager = sceneManager
        self.levelFinished = level
        super.init(size: size)
        
        // set background color & background iamge
        backgroundColor = SKColor.black
        let backgroundMenu = SKSpriteNode(imageNamed: "background")
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -1
        addChild(backgroundMenu)
        
        
        // Set message based on flag
        var message = won ? "You completed " : "You failed "
        message += "Level \(levelFinished)"
        
        // create message label
        let outcomeLabel = SKLabelNode(fontNamed: "Pixeled")
        outcomeLabel.text = message
        outcomeLabel.fontSize = 60
        outcomeLabel.fontColor = SKColor.white
        outcomeLabel.name = "levelResult"
        outcomeLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 500)
        addChild(outcomeLabel)
        
        // create try again or continue label
        if (won) {
            let continueLabel = SKLabelNode(fontNamed: "Pixeled")
            continueLabel.text = "Next Level"
            continueLabel.fontSize = 40
            continueLabel.fontColor = SKColor.white
            continueLabel.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
            continueLabel.name = "nextLevel"
            addChild(continueLabel)
        }
        else {
            let tryAgain = SKLabelNode(fontNamed: "Pixeled")
            tryAgain.text = "Try Again"
            tryAgain.fontSize = 40
            tryAgain.fontColor = SKColor.white
            tryAgain.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
            tryAgain.name = "replayLevel"
            addChild(tryAgain)
        }
        
        
        // return to main menu text
        let toMainFromLevelEnd = SKLabelNode(fontNamed: "Pixeled")
        toMainFromLevelEnd.text = "Return to Main Menu"
        toMainFromLevelEnd.fontSize = 40
        toMainFromLevelEnd.fontColor = SKColor.white
        toMainFromLevelEnd.position = CGPoint(x: size.width/2, y: size.height/2 - 300)
        toMainFromLevelEnd.name = "endLevelToMain"
        addChild(toMainFromLevelEnd)
    }
    
    // override touches began for options
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Choose a touch to work with
        guard let touch = touches.first else { return };
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        switch (node.name) {
        case "replayLevel"?:
            sceneManager.loadGameScene(lvl: levelFinished)
            break
        case "nextLevel"?:
            sceneManager.loadGameScene(lvl: levelFinished+1)
            break
        case "endLevelToMain"?:
            sceneManager.loadMenu(menuToLoad: MenuScene.MenuType.main)
            break
        default:
            break
        }
    }
    
    // override init for scene
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
