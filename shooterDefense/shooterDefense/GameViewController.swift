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
    let defaults = UserDefaults.standard
    var playerProfile: PlayerProfile?
    var isPhone: Bool?
    var gameMode = MenuScene.GameMode.classic // valid types: classic || oneshot
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the view.
        skView = self.view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = true
        
        isPhone = isDevicePhone()
        
        // load data for player profile
        loadPlayerProfile()
        
        // register profile saving when application is no longer active
        NotificationCenter.default.addObserver(self, selector: #selector(saveProfile), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        loadMenu(menuToLoad: MenuScene.MenuType.main)
    }
    
    // JHAT: scene management methods
    func loadMenu(menuToLoad: MenuScene.MenuType) { // JHAT: displays all game menus
        clearGameSceneFromMemory()
        clearLevelFinishedSceneFromMemory()
        menuScene = MenuScene(size: screenSize, menuToDisplay: menuToLoad, sceneManager: self, playerProfile: playerProfile!)
        let reveal = SKTransition.fade(withDuration: 2)
        skView.presentScene(menuScene!, transition: reveal)
    }
    
    func loadGameScene(lvl:Int) { // JHAT: displays game state
        clearLevelFinishedSceneFromMemory()
        clearMenuSceneFromMemory()
        gameScene = GameScene(size: screenSize, level: lvl, sceneManager: self, playerProgress: playerProfile!, isDevicePhone: isPhone!, mode: gameMode)
        let transition:SKTransition = SKTransition.fade(withDuration: 1)
        if (lvl != 1) {
            MotionMonitor.sharedMotionMonitor.startUpdates()
        }
        skView.presentScene(gameScene!, transition: transition)
    }
    
    func loadLevelFinishedScene(lvl:Int, success:Bool, score: Int) { // JHAT: displays success or fail
        clearGameSceneFromMemory()
        clearMenuSceneFromMemory()
        MotionMonitor.sharedMotionMonitor.stopUpdates()
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        levelFinishedScene = LevelFinishedScene(size: screenSize, won: success, level: lvl, sceneManager: self, playerProfile: playerProfile!, score: score)
        skView.presentScene(levelFinishedScene!, transition: reveal)
    }
    
    // MARK: Model interaction functions
    private func loadPlayerProfile() {
        // JHAT: Determine player profile vars from userDefaults
        let level = defaults.object(forKey: "level")
        let xp = defaults.object(forKey: "xp")
        let lvlsCompleted = defaults.object(forKey: "highestLvlComplete")
        let endlessScore = defaults.object(forKey: "endlessHiScore")
        let multiplier = defaults.object(forKey: "xpMulti")
        let kills = defaults.object(forKey: "killTotal")
        let theme = defaults.string(forKey: "theme")
        let osLvlsCompd = defaults.object(forKey: "highestOSComp")
        
        // run appropriate calculations to get accurate data
        let playerLevel = level != nil ? (level! as AnyObject).intValue : 1
        let playerXP = xp != nil ? (xp! as AnyObject).intValue : 0
        let highestFinishedLvl = lvlsCompleted != nil ? (lvlsCompleted! as AnyObject).intValue : 0
        let endlessModeScore = endlessScore != nil ? (endlessScore! as AnyObject).intValue : 0
        let xpMultiplier = multiplier != nil ? (multiplier! as AnyObject).intValue : 1
        let totalKills = kills != nil ? (kills! as AnyObject).intValue : 0
        let remainder = playerXP! - xpToCurrentLevel(playerLevel!) // JHAT: Swift can't handle doing this on one line
        let xpToNext = xpToNextLevel(playerLevel!) - remainder // JHAT: accurately determine player progession
        let currentTheme = theme != nil ? theme : "Space"
        let highestOSFinished = osLvlsCompd != nil ? (osLvlsCompd! as AnyObject).intValue : 0
        
        playerProfile = PlayerProfile(playerLevel: playerLevel!, playerXP: playerXP!, xpToNextLvl: xpToNext, highestLevelCompleted: highestFinishedLvl!, endlessHiScore: endlessModeScore!, xpMulti: xpMultiplier!, kills: totalKills!, theme: currentTheme!, highestOneShotComplete: highestOSFinished!)
    }
    
    // save progress when profile is modified and when user quits or puts app in background
    func saveProgress(profileToSave: PlayerProfile) { // JHAT: save player progression to userdefaults
        defaults.set(profileToSave.playerLevel, forKey: "level")
        defaults.set(profileToSave.playerXP, forKey: "xp")
        defaults.set(profileToSave.highestLevelCompleted, forKey: "highestLvlComplete")
        defaults.set(profileToSave.endlessHiScore, forKey: "endlessHiScore")
        defaults.set(profileToSave.xpMultiplier, forKey: "xpMulti")
        defaults.set(profileToSave.totalKills, forKey: "killTotal")
        defaults.set(profileToSave.currentTheme, forKey: "theme")
    }
    
    func saveProfile() { // JHAT: parameterless save function for lifecycle saving
        saveProgress(profileToSave: playerProfile!)
    }
    
    // function to allow player to reset rank, but keep endless mode and score + earn an xp multiplier
    func resetProfile(profileToReset: PlayerProfile) {
        
        // determine new theme
        var nextTheme = "Space"
        switch (profileToReset.xpMultiplier) {
        case 1:
            nextTheme = "Plane"
            break
        case 2:
            nextTheme = "Water"
            break
        case 3:
            nextTheme = "Digitial"
            break
        default:
            nextTheme = profileToReset.currentTheme
        }
        
        // clear everything except endlessHiScore and increment multiplier
        let newProfile = PlayerProfile(playerLevel: 1, playerXP: 0, xpToNextLvl: xpToNextLevel(1), highestLevelCompleted: 0, endlessHiScore: profileToReset.endlessHiScore, xpMulti: profileToReset.xpMultiplier + 1, kills: profileToReset.totalKills, theme: nextTheme, highestOneShotComplete: 0)
        
        // save new profile over old one
        saveProgress(profileToSave: newProfile)
        
        // make current profile new one
        playerProfile = newProfile
    }
    
    func isDevicePhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone
    }
    
    // MARK: XP functions
    private func xpToNextLevel(_ currentLevel: Int) -> Int {
        return (25 * (currentLevel - 1) + 50) // JHAT: function to determine xp for each level
    }
    
    private func xpToCurrentLevel(_ currentLevel: Int) -> Int { // JHAT: function to determine the xp earned already to accurately get current level progress
        var level = currentLevel
        var totalXP = 0
        while (level > 1) {
            totalXP += xpToNextLevel(level)
            level -= 1
        }
        return totalXP
    }
    
    func gainXP(xpGained:Int, playerProfile: PlayerProfile) {
        playerProfile.playerXP += xpGained // increment XP
        playerProfile.xpToNext -= xpGained
        
        // JHAT: check if player leveled up
        if (playerProfile.xpToNext <= 0) {
            playerProfile.playerLevel += 1
            let overflow = playerProfile.xpToNext * -1 // Make this number positive
            playerProfile.xpToNext = xpToNextLevel(playerProfile.playerLevel) - overflow
            
            // save profile on level up
            saveProgress(profileToSave: playerProfile)
        }
    }
    
    // gameMode accessors
    func getGameMode() -> MenuScene.GameMode {
        return gameMode
    }
    
    func setGameMode(newMode: MenuScene.GameMode) {
        if (gameMode != newMode) {
            gameMode = newMode
        }
    }
    
    // MARK - profile modifiers
    func enemyKilled(playerProfile: PlayerProfile) {
        playerProfile.totalKills += 1
    }
    
    func setHighestLevelComplete(lvlComplete:Int, playerProfile: PlayerProfile, mode: MenuScene.GameMode) {
        if (mode == MenuScene.GameMode.classic) {
            playerProfile.highestLevelCompleted = lvlComplete
        }
        else { // one shot
            playerProfile.highestOneShotComplete = lvlComplete
        }
        
        // save profile
        saveProgress(profileToSave: playerProfile)
    }
    
    func setEndlessHiScore(endlessScore:Int, playerProfile: PlayerProfile) {
        if (endlessScore > playerProfile.endlessHiScore) { // JHAT: if endless score beats high score, replace
            playerProfile.endlessHiScore = endlessScore
        }
        
        // save profile
        saveProgress(profileToSave: playerProfile)
    }
    
    func setCurrentTheme(newTheme: String, playerProfile: PlayerProfile) {
        if (newTheme != playerProfile.currentTheme) {
            playerProfile.currentTheme = newTheme
            saveProgress(profileToSave: playerProfile)
        }
    }
    
    // MARK: memory functions
    private func clearGameSceneFromMemory() {
        if (gameScene != nil) {
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
