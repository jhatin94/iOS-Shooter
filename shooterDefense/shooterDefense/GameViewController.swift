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
    let screenSize = CGSize(width: 1080, height: 1920)
    let scaleMode = SKSceneScaleMode.aspectFill
    var gameScene: GameScene?
    var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        loadMenu(menuToLoad: MenuScene.MenuType.main)
    }
    
    // JHAT: scene management methods
    func loadMenu(menuToLoad: MenuScene.MenuType) { // JHAT: displays all game menus
        clearGameStateFromMemory()
        let scene = MenuScene(size: screenSize, menuToDisplay: menuToLoad, sceneManager: self)
        let reveal = SKTransition.fade(withDuration: 2)
        skView.presentScene(scene, transition: reveal)
    }
    
    func loadGameScene(lvl:Int) { // JHAT: displays game state
        gameScene = GameScene(size: screenSize, level: lvl)
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        skView.presentScene(gameScene!, transition: transition)
    }
    
    func loadLevelFinishedScene() { // JHAT: displays success or fail
        clearGameStateFromMemory()
    }
    
    func loadGameOverScene() { // JHAT: display story mode finished or Endless mode fail
        clearGameStateFromMemory()
    }
    
    private func clearGameStateFromMemory() {
        if (gameScene != nil) { // clear out gameScene if it's in memory
            gameScene = nil
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
