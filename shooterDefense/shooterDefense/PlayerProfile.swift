//
//  PlayerProfile.swift
//  shooterDefense
//
//  Created by student on 9/21/16.
//  Copyright © 2016 Justin & Conner. All rights reserved.
//

import Foundation

class PlayerProfile {
    // resettable data
    var playerLevel: Int
    var playerXP: Int
    var xpToNext: Int
    var highestLevelCompleted: Int
    var currentTheme: String
    
    // constant data
    var endlessHiScore: Int
    var xpMultiplier: Int
    var totalKills: Int
    
    
    init(playerLevel:Int, playerXP:Int, xpToNextLvl:Int, highestLevelCompleted:Int, endlessHiScore:Int, xpMulti:Int, kills: Int, theme: String) {
        self.playerLevel = playerLevel
        self.playerXP = playerXP
        self.xpToNext = xpToNextLvl
        self.highestLevelCompleted = highestLevelCompleted
        self.endlessHiScore = endlessHiScore
        self.xpMultiplier = xpMulti
        self.totalKills = kills
        self.currentTheme = theme
    }
}
