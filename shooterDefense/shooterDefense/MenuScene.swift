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
        // set background color
        backgroundColor = SKColor.white
        
        // JHAT: create and add a test main menu label
        let titleLabel = SKLabelNode(fontNamed: "Pixeled")
        titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 400)
        titleLabel.fontSize = 108
        titleLabel.text = "Galaxia"
        titleLabel.name = "title"
        titleLabel.fontColor = SKColor.black
        addChild(titleLabel)
        
        // JHAT: Test menu option
        let storyOption = SKLabelNode(fontNamed: "Pixeled")
        storyOption.position = CGPoint(x: size.width/2, y: size.height/2 + 300)
        storyOption.fontSize = 72
        storyOption.text = "Briefing"
        storyOption.name = "story"
        storyOption.fontColor = SKColor.black
        addChild(storyOption)
    }
    
    func drawStoryMenu() {
        // set background color
        backgroundColor = SKColor.white
        
        let storyLabel = SKLabelNode(fontNamed: "Pixeled")
        storyLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 400)
        storyLabel.fontSize = 72
        storyLabel.text = "The Story So Far..."
        storyLabel.fontColor = SKColor.black
        addChild(storyLabel)
    }
}
