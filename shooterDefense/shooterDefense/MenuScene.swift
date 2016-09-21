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
    var transition:SKTransition = SKTransition.fade(withDuration: 1)
    
    enum MenuType {
        case main
        case story
        case settings
        case instructions
        case stats
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
        case "game"?:
             var scene:SKScene = GameScene(size: self.size)
             self.view?.presentScene(scene, transition: transition)
            break
        case "stats"?:
            break
        case "settings"?:
            break
        default:
            break
        }
    }
    
    // JHAT: methods to draw each MenuType
    func drawMainMenu() {
        
        // set background color and image
        backgroundColor = SKColor.black
        var backgroundMenu = SKSpriteNode(imageNamed: "background")
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
         gameOption.name = "game"
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
}
