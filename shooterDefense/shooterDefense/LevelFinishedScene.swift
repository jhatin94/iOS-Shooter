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
        
        //TODO: Handle Endless (0) and end of story (5) cases
        
        // Set message based on flag
        var message = won ? "You completed " : "You failed "
        message += "Level \(levelFinished)"
        
        // create message label
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 500), fontSize: 60, text: message, name: "levelResult"))
        
        // create try again or continue label
        if (won) {
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 40, text: "Next Level", name: "nextLevel"))
        }
        else {
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 40, text: "Try Again", name: "replayLevel"))
        }
        
        // return to main menu text
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 300), fontSize: 40, text: "Return to Main Menu", name: "endLevelToMain"))
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
            sceneManager.loadGameScene(lvl: levelFinished + 1)
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
