//
//  MenuScene.swift
//  shooterDefense
//
//  Created by Justin on 9/20/16.
//  Copyright © 2016 Justin & Conner. All rights reserved.
//

import Foundation
import SpriteKit

class MenuScene: SKScene {
    let sceneManager: GameViewController
    
    enum MenuType {
        case main
        case story
        case settings
        case instructions
        case stats
        case levelSelect
    }
    
    init(size: CGSize, menuToDisplay: MenuType, sceneManager:GameViewController) {
        self.sceneManager = sceneManager
        super.init(size: size)
        
        // JHAT: populate menu scene based on MenuType
        switch (menuToDisplay) {
        case MenuType.main:
            drawMainMenu()
               break
        case MenuType.stats:
            break
        case MenuType.story:
            drawStoryMenu()
            break
        case MenuType.settings:
            break
        case MenuType.instructions:
            break
        case MenuType.levelSelect:
            drawLevelSelect()
            break
        }
        
    }
    
    // override init for scene
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // JHAT: override touchesBegan to detect if options were selected
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Choose a touch to work with
        guard let touch = touches.first else { return };
        let touchLocation = touch.location(in: self)
        let node = self.atPoint(touchLocation)
        
        switch (node.name) {
        case "story"?:
            sceneManager.loadMenu(menuToLoad: MenuType.story)
            break
        case "levelSelect"?:
            sceneManager.loadMenu(menuToLoad: MenuType.levelSelect)
            break
        case "stats"?:
            break
        case "settings"?:
            break
        case "level1"?:
            sceneManager.loadGameScene(lvl: 1)
            break
        default:
            break
        }
    }
    
    // JHAT: methods to draw each MenuType
    func drawMainMenu() {
        
        // set background color and image
        backgroundColor = SKColor.black
        let backgroundMenu = SKSpriteNode(imageNamed: "background")
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -1
        addChild(backgroundMenu)
        
        // JHAT: create and add a test main menu label
        let titleLabel = SKLabelNode(fontNamed: "Pixeled")
        titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 400)
        titleLabel.fontSize = 108
        titleLabel.text = "Galaxia"
        titleLabel.name = "title"
        titleLabel.fontColor = SKColor.white
        addChild(titleLabel)
        
        // JHAT: Transition to game
         let gameOption = SKLabelNode(fontNamed: "Pixeled")
         gameOption.position = CGPoint(x: size.width/2, y: size.height/2-300)
         gameOption.fontSize = 65
         gameOption.text = "Play"
         gameOption.name = "levelSelect"
         gameOption.fontColor = SKColor.white
         addChild(gameOption)
        
        // JHAT: Test menu option
        let storyOption = SKLabelNode(fontNamed: "Pixeled")
        storyOption.position = CGPoint(x: size.width/2, y: size.height/2)
        storyOption.fontSize = 65
        storyOption.text = "Briefing"
        storyOption.name = "story"
        storyOption.fontColor = SKColor.white
        addChild(storyOption)
        
        
    }
    
    func drawStoryMenu() {
        // set background color
        backgroundColor = SKColor.black
        
        let storyLabel = SKLabelNode(fontNamed: "Pixeled")
        storyLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 400)
        storyLabel.fontSize = 72
        storyLabel.text = "The Story So Far..."
        storyLabel.fontColor = SKColor.white
        addChild(storyLabel)
    }
    
    func drawLevelSelect() {
        // get player progress from Model
        
        // set background color
        backgroundColor = SKColor.black
        
        // first level always unlocked
        let level01 = SKLabelNode(fontNamed: "Pixeled")
        level01.position = CGPoint(x: size.width/2, y: size.height/2 + 400)
        level01.fontSize = 72
        level01.text = "Level 1"
        level01.name = "level1"
        level01.fontColor = SKColor.white
        addChild(level01)
    }
}
