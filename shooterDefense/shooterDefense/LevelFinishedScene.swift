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
    let playerData: PlayerProfile
    let endlessScore: Int
    init(size: CGSize, won:Bool, level: Int, sceneManager: GameViewController, playerProfile: PlayerProfile, score: Int) {
        self.sceneManager = sceneManager
        self.levelFinished = level
        self.playerData = playerProfile
        self.endlessScore = score
        super.init(size: size)
        
        // set background color & background iamge
        backgroundColor = SKColor.black
        let backgroundMenu = SKSpriteNode(imageNamed: "background" + playerProfile.currentTheme)
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -1
        addChild(backgroundMenu)
        
        // normal level finished cases -- lvls 1 - 4 win/lose and lvl 5 lose
        if (levelFinished > 0 && (levelFinished < 5 || !won)) {
            // Set message based on flag
            let message = won ? "You completed " : "You failed "
            let lvlText = "Level \(levelFinished)"
            
            // create message labels
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 500), fontSize: 60, text: message, name: "levelResult"))
            
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 60, text: lvlText, name: "levelNum"))
            
            // create try again or continue label
            if (won) {
                addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 40, text: "Next Level", name: "nextLevel"))
                run(SKAction.playSoundFileNamed("winSound.mp3", waitForCompletion: false))
            }
            else {
                addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 40, text: "Try Again", name: "replayLevel"))
                run(SKAction.playSoundFileNamed("loseSound.mp3", waitForCompletion: false))
            }
        }
        // Handle Endless (0) and end of story (5) cases
        else if (levelFinished > 4 && won) { // successful end of level 5 (max)
            // create message labels
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 500), fontSize: 60, text: "Congratulations!", name: "congrats"))
            
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 350), fontSize: 50, text: "You finished all levels!", name: "storyComplete"))
            
            // create try endless label
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 40, text: "Try Endless Mode", name: "endlessLevel"))
            run(SKAction.playSoundFileNamed("winSound.mp3", waitForCompletion: false))
        }
        else if (levelFinished < 1) {
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 500), fontSize: 60, text: "Earth has fallen!", name: "endlessOver"))
            
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 350), fontSize: 60, text: "Final Score: \(endlessScore)", name: "endlessScore"))
            
            if (endlessScore == playerProfile.endlessHiScore && endlessScore > 0) { // if player breaks record, congratulate them
                addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 150), fontSize: 50, text: "New Record, Great Work!", name: "newHiscore"))
            }
            
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 60, text: "High Score: \(playerProfile.endlessHiScore)", name: "endlessHiScore"))
            
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 40, text: "Try Again", name: "replayEndless"))
            run(SKAction.playSoundFileNamed("loseSound.mp3", waitForCompletion: false))
        }        
        
        // return to main menu text -- always on screen
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 300), fontSize: 40, text: "Return to Main Menu", name: "endLevelToMain"))
    }
    
    // override touches began for options
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Choose a touch to work with
        guard let touch = touches.first else { return };
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        switch (node.name) {
        case "replayEndless"?:
            fallthrough
        case "replayLevel"?:
            sceneManager.loadGameScene(lvl: levelFinished)
            break
        case "nextLevel"?:
            sceneManager.loadGameScene(lvl: levelFinished + 1)
            break
        case "endLevelToMain"?:
            sceneManager.loadMenu(menuToLoad: MenuScene.MenuType.main)
            break
        case "endlessLevel"?:
            sceneManager.loadGameScene(lvl: 0)
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
