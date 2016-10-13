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
        case reset
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
        case MenuType.reset:
            drawResetMenu()
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
        case "reset"?:
            sceneManager.loadMenu(menuToLoad: MenuType.reset)
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
        case "resetToMain"?: // reset clickable nodes
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
        case "level3"?:
            sceneManager.loadGameScene(lvl: 3)
            break
        case "level4"?:
            sceneManager.loadGameScene(lvl: 4)
            break
        case "level5"?:
            sceneManager.loadGameScene(lvl: 5)
            break
        case "level0"?:
            sceneManager.loadGameScene(lvl: 0)
            break
        default:
            break
        }
    }
    
    // MARK: methods to draw each MenuType
    func drawMainMenu() {
        // set background color and image
        backgroundColor = SKColor.black
        let backgroundMenu = SKSpriteNode(imageNamed: "background")
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -1
        addChild(backgroundMenu)
        
        // JHAT: create and add main menu title label
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 500), fontSize: 108, text: "Galaxia", name: "title"))
        
        // JHAT: story menu option
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 65, text: "Briefing", name: "story"))
        
        // JHAT: instructions menu option
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 65, text: "How To Play", name: "instructions"))
        
        // JHAT: stats menu option
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 65, text: "Stats", name: "stats"))
        
        // JHAT: reset menu option
        if (playerProfile.playerLevel >= 20) {
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 600), fontSize: 65, text: "Reset Profile", name: "reset"))
        }
        
        // developer names
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 800), fontSize: 40, text: "Devs: Hasbrouck & Hatin", name: "signature"))
        
        // JHAT: Transition to level select
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 65, text: "Play", name: "levelSelect"))
        
    }
    
    func drawStoryMenu() {
        // set background color
        backgroundColor = SKColor.black
        
        // story text labels
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 60, text: "The Story So Far...", name: "storyTitle0"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 300), fontSize: 40, text: "The Year is 2400...", name: "storyTitle1"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 100), fontSize: 40, text: "Humanity is being invaded by ", name: "storyTitle2"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 40, text: "an unidentified alien race. ", name: "storyTitle3"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 40, text: "   As humanitys best pilot, its", name: "storyTitle4"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 40, text: "your duty to defend Earth.", name: "storyTitle5"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 40, text: "Give them hell Pilot", name: "storyTitle6"))
       
        // return to main menu
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "storyToMain"))
    }
    
    func drawLevelSelect() {
        // get player progress from Model to determine which levels are unlocked
        let maxLevelToDisplay = playerProfile.highestLevelCompleted + 1
        let endlessUnlocked = playerProfile.xpMultiplier > 1 || maxLevelToDisplay > 5
        
        // set background color
        backgroundColor = SKColor.black
        
        // title label
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "Level Select", name: "levelSelectTitle"))
        
        // return to main menu
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "levelSelectToMain"))
        
        // first level always unlocked
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 60, text: "Level 1", name: "level1"))
        
        if (maxLevelToDisplay > 1) {// show level 2 label if unlocked
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 60, text: "Level 2", name: "level2"))
        }
        if (maxLevelToDisplay > 2) {
            // show level 3
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 60, text: "Level 3", name: "level3"))
        }
        if (maxLevelToDisplay > 3) {
            // show level 4
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 60, text: "Level 4", name: "level4"))
        }
        if (maxLevelToDisplay > 4) {
            // show level 5
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 60, text: "Level 5", name: "level5"))
        }
        
        // check if endless is unlocked
        if (endlessUnlocked) {
            // show endless
            addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 700), fontSize: 60, text: "Endless Mode", name: "level0"))
        }
    }
    
    func drawResetMenu() {
        backgroundColor = SKColor.black
        
        // title of page
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "Reset?", name: "resetTitle"))
        
        // description of resetting
         addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 48, text: "Congratulations Pilot!", name: "resetDescription"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 250), fontSize: 36, text: "Your ship has the best abilities", name: "resetDescription2"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 150), fontSize: 30, text: "Looking to get a higher Endless Score?", name: "resetDescription3"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 25), fontSize: 30, text: "You can reset your profile back to level 1", name: "resetDescription4"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 30, text: "Your XP and Score will be multiplied", name: "resetDescription5"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 250), fontSize: 36, text: "Earn higher scores now!", name: "resetDescription6"))
        
        // let player reset at level 20 -- point where all abilities are maxed
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 500), fontSize: 60, text: "Reset Profile", name: "resetBtn"))
        
        // return to main menu
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "resetToMain"))
    }
    
    func drawStatsMenu() {
        backgroundColor = SKColor.black
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "Statistics", name: "statsTitle"))
        
        // show playerXP, level, endless score, multiplier, kills
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 48, text: "XP Earned: \(playerProfile.playerXP)", name: "xpEarned"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 48, text: "Level: \(playerProfile.playerLevel)", name: "currentLvl"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 48, text: "XP Multiplier: x\(playerProfile.xpMultiplier)", name: "multiplier"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 48, text: "Endless HiScore: \(playerProfile.endlessHiScore)", name: "endlessScore"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 48, text: "Enemies Killed: \(playerProfile.totalKills)", name: "kills"))
        
        // return to main menu
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "statsToMain"))
    }
    
    func drawInstrMenu() {
        backgroundColor = SKColor.black
        
        // page title
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "How To Play", name: "intructionsTitle"))
        
        // instructions text
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 40, text: "Tap to Shoot", name: "instructions1"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 300), fontSize: 40, text: "Tilt Phone to Move Ship", name: "instructions2"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 40, text: "Tap with three fingers to pause", name: "instructions3"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 + 50), fontSize: 40, text: "Destroy all Pesky Aliens ", name: "instructions4"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 50), fontSize: 40, text: "to advance to the Next Level", name: "instructions5"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 150), fontSize: 40, text: " If Five Aliens get by you", name: "instructions6"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 250), fontSize: 40, text: "Earth will fall", name: "instructions7"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 450), fontSize: 40, text: " The more enemies you kill", name: "instructions8"))
        
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 550), fontSize: 40, text: "The better your ship gets", name: "instructions9"))
        
        // return to main menu
        addChild(createPixeledLabel(pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "instToMain"))
    }
}
