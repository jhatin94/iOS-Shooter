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
    let playerProfile: PlayerProfile
    
    enum MenuType {
        case main
        case story
        case settings
        case instructions
        case stats
        case levelSelect
    }
    
    init(size: CGSize, menuToDisplay: MenuType, sceneManager:GameViewController, playerProfile: PlayerProfile) {
        self.sceneManager = sceneManager
        self.playerProfile = playerProfile
        super.init(size: size)
        
        // JHAT: populate menu scene based on MenuType
        switch (menuToDisplay) {
        case MenuType.main:
            drawMainMenu()
               break
        case MenuType.stats:
            drawStatsMenu()
            break
        case MenuType.story:
            drawStoryMenu()
            break
        case MenuType.settings:
            drawSettingsMenu()
            break
        case MenuType.instructions:
            drawInstrMenu()
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
        case "story"?: // Main menu clickable nodes
            sceneManager.loadMenu(menuToLoad: MenuType.story)
            break
        case "levelSelect"?:
            sceneManager.loadMenu(menuToLoad: MenuType.levelSelect)
            break
        case "stats"?:
            sceneManager.loadMenu(menuToLoad: MenuType.stats)
            break
        case "settings"?:
            sceneManager.loadMenu(menuToLoad: MenuType.settings)
            break
        case "instructions"?:
            sceneManager.loadMenu(menuToLoad: MenuType.instructions)
            break
        case "storyToMain"?: // story clickable nodes
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "statsToMain"?: // stats clickable nodes
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "settingsToMain"?: // settings clickable nodes
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "resetBtn"?:
            sceneManager.resetProfile(profileToReset: playerProfile)
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "instToMain"?: // instructions clickable nodes
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "levelSelectToMain"?: // level select clickable nodes
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "level1"?: 
            sceneManager.loadGameScene(lvl: 1)
            break
        case "level2"?:
            sceneManager.loadGameScene(lvl: 2)
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
        
        // JHAT: create and add main menu title label
        let titleLabel = SKLabelNode(fontNamed: "Pixeled")
        titleLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 500)
        titleLabel.fontSize = 108
        titleLabel.text = "Galaxia"
        titleLabel.name = "title"
        titleLabel.fontColor = SKColor.white
        addChild(titleLabel)
        
        // JHAT: story menu option
        let storyOption = SKLabelNode(fontNamed: "Pixeled")
        storyOption.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
        storyOption.fontSize = 65
        storyOption.text = "Briefing"
        storyOption.name = "story"
        storyOption.fontColor = SKColor.white
        addChild(storyOption)
        
        // JHAT: instructions menu option
        let instructionsOption = SKLabelNode(fontNamed: "Pixeled")
        instructionsOption.position = CGPoint(x: size.width/2, y: size.height/2 - 200 )
        instructionsOption.fontSize = 65
        instructionsOption.text = "How To Play"
        instructionsOption.name = "instructions"
        instructionsOption.fontColor = SKColor.white
        addChild(instructionsOption)
        
        // JHAT: settings menu option
        let settingsOption = SKLabelNode(fontNamed: "Pixeled")
        settingsOption.position = CGPoint(x: size.width/2, y: size.height/2 - 600)
        settingsOption.fontSize = 65
        settingsOption.text = "Settings"
        settingsOption.name = "settings"
        settingsOption.fontColor = SKColor.white
        addChild(settingsOption)
        
        // JHAT: stats menu option
        let statsOption = SKLabelNode(fontNamed: "Pixeled")
        statsOption.position = CGPoint(x: size.width/2, y: size.height/2 - 400)
        statsOption.fontSize = 65
        statsOption.text = "Stats"
        statsOption.name = "stats"
        statsOption.fontColor = SKColor.white
        addChild(statsOption)
        
        // JHAT: Transition to level select
        let gameOption = SKLabelNode(fontNamed: "Pixeled")
        gameOption.position = CGPoint(x: size.width/2, y: size.height/2)
        gameOption.fontSize = 65
        gameOption.text = "Play"
        gameOption.name = "levelSelect"
        gameOption.fontColor = SKColor.white
        addChild(gameOption)
    }
    
    func drawStoryMenu() {
        // set background color
        backgroundColor = SKColor.black
        
        let storyLabel = SKLabelNode(fontNamed: "Pixeled")
        storyLabel.position = CGPoint(x: size.width/2, y: size.height/2 + 600)
        storyLabel.fontSize = 60
        storyLabel.text = "The Story So Far..."
        storyLabel.name = "storyTitle"
        storyLabel.fontColor = SKColor.white
        addChild(storyLabel)
        
        let storyLabel1 = SKLabelNode(fontNamed: "Pixeled")
        storyLabel1.position = CGPoint(x: size.width/2, y: size.height/2 + 300)
        storyLabel1.fontSize = 40
        storyLabel1.text = "The Year is 2400.."
        storyLabel1.name = "storyTitle"
        storyLabel1.fontColor = SKColor.white
        addChild(storyLabel1)
        
        let storyLabel2 = SKLabelNode(fontNamed: "Pixeled")
        storyLabel2.position = CGPoint(x: size.width/2, y: size.height/2 + 100)
        storyLabel2.fontSize = 40
        storyLabel2.text = "Humanity is being invaded by "
        storyLabel2.name = "storyTitle"
        storyLabel2.fontColor = SKColor.white
        addChild(storyLabel2)
        
        let storyLabel3 = SKLabelNode(fontNamed: "Pixeled")
        storyLabel3.position = CGPoint(x: size.width/2, y: size.height/2)
        storyLabel3.fontSize = 40
        storyLabel3.text = "an unidentified alien race. "
        storyLabel3.name = "storyTitle"
        storyLabel3.fontColor = SKColor.white
        addChild(storyLabel3)
        
        let storyLabel4 = SKLabelNode(fontNamed: "Pixeled")
        storyLabel4.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        storyLabel4.fontSize = 40
        storyLabel4.text = "   As humanitys best pilot, its"
        storyLabel4.name = "storyTitle"
        storyLabel4.fontColor = SKColor.white
        addChild(storyLabel4)
        
        let storyLabel5 = SKLabelNode(fontNamed: "Pixeled")
        storyLabel5.position = CGPoint(x: size.width/2, y: size.height/2 - 200)
        storyLabel5.fontSize = 40
        storyLabel5.text = "your duty to defend Earth."
        storyLabel5.name = "storyTitle"
        storyLabel5.fontColor = SKColor.white
        addChild(storyLabel5)
        
        let storyLabel6 = SKLabelNode(fontNamed: "Pixeled")
        storyLabel6.position = CGPoint(x: size.width/2, y: size.height/2 - 400)
        storyLabel6.fontSize = 40
        storyLabel6.text = "Give them hell Pilot"
        storyLabel6.name = "storyTitle"
        storyLabel6.fontColor = SKColor.white
        addChild(storyLabel6)
        
       
        // return to main menu
        let toMainFromStory = SKLabelNode(fontNamed: "Pixeled")
        toMainFromStory.position = CGPoint(x: size.width/2, y: size.height/2 - 900)
        toMainFromStory.fontColor = SKColor.white
        toMainFromStory.fontSize = 32
        toMainFromStory.text = "Return To Main Menu"
        toMainFromStory.name = "storyToMain"
        addChild(toMainFromStory)
    }
    
    func drawLevelSelect() {
        // get player progress from Model to determine which levels are unlocked
        let maxLevelToDisplay = playerProfile.highestLevelCompleted + 1
        let endlessUnlocked = playerProfile.xpMultiplier > 1 || playerProfile.highestLevelCompleted > 5 // TODO: Change if max level is not 5
        
        // set background color
        backgroundColor = SKColor.black
        
        // title label
        let levelSelectTitle = SKLabelNode(fontNamed: "Pixeled")
        levelSelectTitle.position = CGPoint(x: size.width/2, y: size.height/2 + 600)
        levelSelectTitle.fontSize = 72
        levelSelectTitle.text = "Level Select"
        levelSelectTitle.name = "levelSelectTitle"
        levelSelectTitle.fontColor = SKColor.white
        addChild(levelSelectTitle)
        
        // return to main menu
        let toMainFromLevelSelect = SKLabelNode(fontNamed: "Pixeled")
        toMainFromLevelSelect.position = CGPoint(x: size.width/2, y: size.height/2 - 900)
        toMainFromLevelSelect.fontColor = SKColor.white
        toMainFromLevelSelect.fontSize = 32
        toMainFromLevelSelect.text = "Return To Main Menu"
        toMainFromLevelSelect.name = "levelSelectToMain"
        addChild(toMainFromLevelSelect)
        
        // first level always unlocked
        let level01 = SKLabelNode(fontNamed: "Pixeled")
        level01.position = CGPoint(x: size.width/2, y: size.height/2 + 400)
        level01.fontSize = 60
        level01.text = "Level 1"
        level01.name = "level1"
        level01.fontColor = SKColor.white
        addChild(level01)
        
        if (maxLevelToDisplay > 1) {// show level 2 label if unlocked
            let level02 = SKLabelNode(fontNamed: "Pixeled")
            level02.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
            level02.fontSize = 60
            level02.text = "Level 2"
            level02.name = "level2"
            level02.fontColor = SKColor.white
            addChild(level01)
        }
        if (maxLevelToDisplay > 2) {
            // TODO: show level 3 and setup touch event to have scenemanager load GameScene(3)
        }
        
        if (endlessUnlocked) {
            // TODO: show endless and setup touch event to have scenemanager load GameScene(0)
        }
    }
    
    func drawSettingsMenu() {
        backgroundColor = SKColor.black
        
        let settingsTitle = SKLabelNode(fontNamed: "Pixeled")
        settingsTitle.position = CGPoint(x: size.width/2, y: size.height/2 + 600)
        settingsTitle.fontSize = 72
        settingsTitle.text = "Settings"
        settingsTitle.name = "settingsTitle"
        settingsTitle.fontColor = SKColor.white
        addChild(settingsTitle)
        
        // let player reset after level 21
        if (playerProfile.playerLevel > 20) {
            let resetProfile = SKLabelNode(fontNamed: "Pixeled")
            resetProfile.position = CGPoint(x: size.width/2, y: size.height/2)
            resetProfile.fontSize = 60
            resetProfile.text = "Reset Profile"
            resetProfile.name = "resetBtn"
            resetProfile.fontColor = SKColor.white
            addChild(resetProfile)
            
            let resetDescr = SKLabelNode(fontNamed: "Pixeled")
            resetDescr.position = CGPoint(x: resetProfile.position.x, y: resetProfile.position.y - 50)
            resetDescr.fontSize = 16
            resetDescr.text = "Keeps Endless Mode + Score and adds an XP Boost"
            resetDescr.name = "resetDescription"
            resetDescr.fontColor = SKColor.white
            addChild(resetDescr)
        }
        
        // return to main menu
        let toMainFromSettings = SKLabelNode(fontNamed: "Pixeled")
        toMainFromSettings.position = CGPoint(x: size.width/2, y: size.height/2 - 900)
        toMainFromSettings.fontColor = SKColor.white
        toMainFromSettings.fontSize = 32
        toMainFromSettings.text = "Return To Main Menu"
        toMainFromSettings.name = "settingsToMain"
        addChild(toMainFromSettings)
    }
    
    func drawStatsMenu() {
        backgroundColor = SKColor.black
        
        let statsTitle = SKLabelNode(fontNamed: "Pixeled")
        statsTitle.position = CGPoint(x: size.width/2, y: size.height/2 + 600)
        statsTitle.fontSize = 72
        statsTitle.text = "Statistics"
        statsTitle.name = "statsTitle"
        statsTitle.fontColor = SKColor.white
        addChild(statsTitle)
        
        // show playerXP, level, endless score, multiplier, kills
        let totalXP = SKLabelNode(fontNamed: "Pixeled")
        totalXP.position = CGPoint(x: size.width/2, y: size.height/2 + 400)
        totalXP.fontSize = 48
        totalXP.text = "XP Earned: \(playerProfile.playerXP)"
        totalXP.name = "xpEarned"
        totalXP.fontColor = SKColor.white
        addChild(totalXP)
        
        let currentLevel = SKLabelNode(fontNamed: "Pixeled")
        currentLevel.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
        currentLevel.fontSize = 48
        currentLevel.text = "Level: \(playerProfile.playerLevel)"
        currentLevel.name = "currentLvl"
        currentLevel.fontColor = SKColor.white
        addChild(currentLevel)
        
        let xpMult = SKLabelNode(fontNamed: "Pixeled")
        xpMult.position = CGPoint(x: size.width/2, y: size.height/2)
        xpMult.fontSize = 48
        xpMult.text = "XP Multiplier: x\(playerProfile.xpMultiplier)"
        xpMult.name = "multiplier"
        xpMult.fontColor = SKColor.white
        addChild(xpMult)
        
        let endlessScore = SKLabelNode(fontNamed: "Pixeled")
        endlessScore.position = CGPoint(x: size.width/2, y: size.height/2 - 200)
        endlessScore.fontSize = 36
        endlessScore.text = "Highest Endless Score: \(playerProfile.endlessHiScore)"
        endlessScore.name = "endlessScorert"
        endlessScore.fontColor = SKColor.white
        addChild(endlessScore)
        
        // return to main menu
        let toMainFromStats = SKLabelNode(fontNamed: "Pixeled")
        toMainFromStats.position = CGPoint(x: size.width/2, y: size.height/2 - 900)
        toMainFromStats.fontColor = SKColor.white
        toMainFromStats.fontSize = 32
        toMainFromStats.text = "Return To Main Menu"
        toMainFromStats.name = "statsToMain"
        addChild(toMainFromStats)
    }
    
    func drawInstrMenu() {
        backgroundColor = SKColor.black
        
        let instrTitle = SKLabelNode(fontNamed: "Pixeled")
        instrTitle.position = CGPoint(x: size.width/2, y: size.height/2 + 600)
        instrTitle.fontSize = 72
        instrTitle.text = "How To Play"
        instrTitle.name = "intructionsTitle"
        instrTitle.fontColor = SKColor.white
        addChild(instrTitle)
        
        let instrPar = SKLabelNode(fontNamed: "Pixeled")
        instrPar.position = CGPoint(x: size.width/2, y: size.height/2 + 300)
        instrPar.fontSize = 40
        instrPar.text = "Tap to Shoot"
        instrPar.name = "instructions1"
        instrPar.fontColor = SKColor.white
        addChild(instrPar)
        
        let instrPar2 = SKLabelNode(fontNamed: "Pixeled")
        instrPar2.position = CGPoint(x: size.width/2, y: size.height/2 + 200)
        instrPar2.fontSize = 40
        instrPar2.text = "Tilt Phone to Move Ship"
        instrPar2.name = "instructions2"
        instrPar2.fontColor = SKColor.white
        addChild(instrPar2)
        
        let instrPar3 = SKLabelNode(fontNamed: "Pixeled")
        instrPar3.position = CGPoint(x: size.width/2, y: size.height/2 )
        instrPar3.fontSize = 40
        instrPar3.text = "Destroy all Pesky Aliens "
        instrPar3.name = "instructions2"
        instrPar3.fontColor = SKColor.white
        addChild(instrPar3)
        
        let instrPar4 = SKLabelNode(fontNamed: "Pixeled")
        instrPar4.position = CGPoint(x: size.width/2, y: size.height/2 - 100)
        instrPar4.fontSize = 40
        instrPar4.text = "to advance to the Next Level"
        instrPar4.name = "instructions2"
        instrPar4.fontColor = SKColor.white
        addChild(instrPar4)
        
        
        let instrPar5 = SKLabelNode(fontNamed: "Pixeled")
        instrPar5.position = CGPoint(x: size.width/2, y: size.height/2 - 300)
        instrPar5.fontSize = 40
        instrPar5.text = " Dont Let the Aliens get"
        instrPar5.name = "instructions2"
        instrPar5.fontColor = SKColor.white
        addChild(instrPar5)
        
        let instrPar6 = SKLabelNode(fontNamed: "Pixeled")
        instrPar6.position = CGPoint(x: size.width/2, y: size.height/2 - 400)
        instrPar6.fontSize = 40
        instrPar6.text = "past you and Destroy Earth"
        instrPar6.name = "instructions2"
        instrPar6.fontColor = SKColor.white
        addChild(instrPar6)
        
        
        // return to main menu
        let toMainFromInstr = SKLabelNode(fontNamed: "Pixeled")
        toMainFromInstr.position = CGPoint(x: size.width/2, y: size.height/2 - 900)
        toMainFromInstr.fontColor = SKColor.white
        toMainFromInstr.fontSize = 32
        toMainFromInstr.text = "Return To Main Menu"
        toMainFromInstr.name = "instToMain"
        addChild(toMainFromInstr)
    }
}
