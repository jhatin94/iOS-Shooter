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
    let currentTheme: String
    var bgColor = SKColor.black
    
    enum MenuType {
        case main
        case story
        case reset
        case instructions
        case stats
        case levelSelect
        case skins
    }
    
    init(size: CGSize, menuToDisplay: MenuType, sceneManager:GameViewController, playerProfile: PlayerProfile) {
        self.sceneManager = sceneManager
        self.playerProfile = playerProfile
        self.currentTheme = playerProfile.currentTheme
        super.init(size: size)
        
        getBgColor()
        
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
        case MenuType.skins:
            drawSkinsMenu()
            break
        }
        
    }
    
    // override init for scene
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getBgColor() {
        switch (currentTheme) {
        case "Space":
            fallthrough
        case "Digitial":
            bgColor = SKColor.black
            break
        case "Water":
            fallthrough
        case "Plane":
            bgColor = SKColor.blue
            break
        default:
            bgColor = SKColor.black
        }
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
        case "changeSkin"?:
            sceneManager.loadMenu(menuToLoad: MenuType.skins)
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
        case "skinSpace"?: // skin selection clickable nodes
            sceneManager.setCurrentTheme(newTheme: "Space", playerProfile: playerProfile)
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "skinPlane"?:
            sceneManager.setCurrentTheme(newTheme: "Plane", playerProfile: playerProfile)
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "skinWater"?:
            sceneManager.setCurrentTheme(newTheme: "Water", playerProfile: playerProfile)
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "skinDigital"?:
            sceneManager.setCurrentTheme(newTheme: "Digitial", playerProfile: playerProfile)
            sceneManager.loadMenu(menuToLoad: MenuType.main)
            break
        case "skinToMain"?:
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
        backgroundColor = bgColor
        let backgroundMenu = SKSpriteNode(imageNamed: "background" + playerProfile.currentTheme)
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -1
        addChild(backgroundMenu)
        
        // JHAT: create and add main menu title label
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 700), fontSize: 108, text: "Galaxia", name: "title"))
        
        // JHAT: story menu option
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 65, text: "Briefing", name: "story"))
        
        // JHAT: instructions menu option
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 65, text: "How To Play", name: "instructions"))
        
        // JHAT: stats menu option
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 65, text: "Stats", name: "stats"))
        
        // JHAT: skin selector option
        if (playerProfile.xpMultiplier > 1) {
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 65, text: "Change Skin", name: "changeSkin"))
        }
        
        // JHAT: reset menu option
        if (playerProfile.playerLevel >= 20) {
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 600), fontSize: 65, text: "Reset Profile", name: "reset"))
        }
        
        // developer names
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 800), fontSize: 40, text: "Devs: Hasbrouck and Hatin", name: "signature"))
        
        // JHAT: Transition to level select
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 65, text: "Play", name: "levelSelect"))
        
    }
    
    func drawStoryMenu() {
        // set background color
        backgroundColor = bgColor
        
        // story text labels
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 60, text: "The Story So Far...", name: "storyTitle0"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 300), fontSize: 40, text: "The Year is 2400...", name: "storyTitle1"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 100), fontSize: 40, text: "Humanity is being invaded by ", name: "storyTitle2"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 40, text: "an unidentified alien race. ", name: "storyTitle3"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 40, text: "   As humanitys best pilot, its", name: "storyTitle4"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 40, text: "your duty to defend Earth.", name: "storyTitle5"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 40, text: "Give them hell Pilot", name: "storyTitle6"))
       
        // return to main menu
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "storyToMain"))
    }
    
    func drawLevelSelect() {
        // get player progress from Model to determine which levels are unlocked
        let maxLevelToDisplay = playerProfile.highestLevelCompleted + 1
        let endlessUnlocked = playerProfile.xpMultiplier > 1 || maxLevelToDisplay > 5
        
        // set background color
        backgroundColor = bgColor
        
        // title label
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "Level Select", name: "levelSelectTitle"))
        
        // return to main menu
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "levelSelectToMain"))
        
        // first level always unlocked
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 60, text: "Level 1", name: "level1"))
        
        if (maxLevelToDisplay > 1) {// show level 2 label if unlocked
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 60, text: "Level 2", name: "level2"))
        }
        if (maxLevelToDisplay > 2) {
            // show level 3
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 60, text: "Level 3", name: "level3"))
        }
        if (maxLevelToDisplay > 3) {
            // show level 4
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 60, text: "Level 4", name: "level4"))
        }
        if (maxLevelToDisplay > 4) {
            // show level 5
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 60, text: "Level 5", name: "level5"))
        }
        
        // check if endless is unlocked
        if (endlessUnlocked) {
            // show endless
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 700), fontSize: 60, text: "Endless Mode", name: "level0"))
        }
    }
    
    func drawResetMenu() {
        backgroundColor = bgColor
        
        // title of page
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "Reset?", name: "resetTitle"))
        
        // description of resetting
         addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 48, text: "Congratulations Pilot!", name: "resetDescription"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 250), fontSize: 36, text: "Your ship has the best abilities", name: "resetDescription2"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 150), fontSize: 30, text: "Looking to get a higher Endless Score?", name: "resetDescription3"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 25), fontSize: 30, text: "You can reset your profile back to level 1", name: "resetDescription4"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 100), fontSize: 30, text: "Your XP and Score will be multiplied", name: "resetDescription5"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 250), fontSize: 36, text: "Earn higher scores now!", name: "resetDescription6"))
       
        if (playerProfile.xpMultiplier < 4) {
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 30, text: "You'll unlock a new skin when you reset", name: "resetDescription7"))
        }
        
        // let player reset at level 20 -- point where all abilities are maxed
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 700), fontSize: 60, text: "Reset Profile", name: "resetBtn"))
        
        // return to main menu
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "resetToMain"))
    }
    
    func drawStatsMenu() {
        backgroundColor = bgColor
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "Statistics", name: "statsTitle"))
        
        // show playerXP, level, endless score, multiplier, kills
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 48, text: "XP Earned: \(playerProfile.playerXP)", name: "xpEarned"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 48, text: "Level: \(playerProfile.playerLevel)", name: "currentLvl"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 48, text: "XP Multiplier: x\(playerProfile.xpMultiplier)", name: "multiplier"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 48, text: "Endless HiScore: \(playerProfile.endlessHiScore)", name: "endlessScore"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 48, text: "Enemies Killed: \(playerProfile.totalKills)", name: "kills"))
        
        // return to main menu
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "statsToMain"))
    }
    
    func drawInstrMenu() {
        backgroundColor = bgColor
        
        // page title
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "How To Play", name: "intructionsTitle"))
        
        // instructions text
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 400), fontSize: 40, text: "Tap to Shoot", name: "instructions1"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 300), fontSize: 40, text: "Tilt Phone to Move Ship", name: "instructions2"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 40, text: "Tap with three fingers to pause", name: "instructions3"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 50), fontSize: 40, text: "Destroy all Pesky Aliens ", name: "instructions4"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 50), fontSize: 40, text: "to advance to the Next Level", name: "instructions5"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 150), fontSize: 40, text: " If Five Aliens get by you", name: "instructions6"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 250), fontSize: 40, text: "Earth will fall", name: "instructions7"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 450), fontSize: 40, text: " The more enemies you kill", name: "instructions8"))
        
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 550), fontSize: 40, text: "The better your ship gets", name: "instructions9"))
        
        // return to main menu
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "instToMain"))
    }
    
    func drawSkinsMenu() { // only drawn after first reset
        backgroundColor = bgColor
        
        // determine unlocked themes
        let mult = playerProfile.xpMultiplier
        
        // page title
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 600), fontSize: 72, text: "Select Theme", name: "skinTitle"))
        
        // space always available
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 + 200), fontSize: 40, text: "Space Theme", name: "skinSpace"))
        
        if (mult > 1) { // plane
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2), fontSize: 40, text: "Plane Theme", name: "skinPlane"))
        }
        if (mult > 2) { // water
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 200), fontSize: 40, text: "Water Theme", name: "skinWater"))
        }
        if (mult > 3) { // digitial
            addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 400), fontSize: 40, text: "Digital Theme", name: "skinDigital"))
        }
        
        // return to main menu
        addChild(createThemedLabel(theme: currentTheme, pos: CGPoint(x: size.width/2, y: size.height/2 - 900), fontSize: 32, text: "Return To Main Menu", name: "skinToMain"))
    }
}
