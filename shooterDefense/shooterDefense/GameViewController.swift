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
    var menuScene: MenuScene?
    var levelFinishedScene: LevelFinishedScene?
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
        clearGameSceneFromMemory()
        clearLevelFinishedSceneFromMemory()
        menuScene = MenuScene(size: screenSize, menuToDisplay: menuToLoad, sceneManager: self)
        let reveal = SKTransition.fade(withDuration: 2)
        skView.presentScene(menuScene!, transition: reveal)
    }
    
    func loadGameScene(lvl:Int) { // JHAT: displays game state
        clearMenuSceneFromMemory()
        clearLevelFinishedSceneFromMemory()
        gameScene = GameScene(size: screenSize, level: lvl, sceneManager: self)
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        skView.presentScene(gameScene!, transition: transition)
    }
    
    func loadLevelFinishedScene(lvl:Int, success:Bool) { // JHAT: displays success or fail
        clearGameSceneFromMemory()
        clearMenuSceneFromMemory()
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        levelFinishedScene = LevelFinishedScene(size: screenSize, won: success, level: lvl, sceneManager: self)
        skView.presentScene(levelFinishedScene!, transition: reveal)
    }
    
    func loadGameOverScene() { // JHAT: display story mode finished or Endless mode fail
        clearGameSceneFromMemory()
        clearMenuSceneFromMemory()
        clearLevelFinishedSceneFromMemory()
    }
    
    private func clearGameSceneFromMemory() {
        if (gameScene != nil) { // clear out gameScene if it's in memory
            gameScene = nil
        }
    }
    private func clearMenuSceneFromMemory() {
        if (menuScene != nil) {
            menuScene = nil
        }
    }
    private func clearLevelFinishedSceneFromMemory() {
        if (levelFinishedScene != nil) {
            levelFinishedScene = nil
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
