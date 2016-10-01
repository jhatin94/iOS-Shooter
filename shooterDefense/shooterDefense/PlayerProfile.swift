//
//  PlayerProfile.swift
//  shooterDefense
//
//  Created by student on 9/21/16.
//  Copyright © 2016 Justin & Conner. All rights reserved.
//

import Foundation

class PlayerProfile {
    var playerLevel: Int
    var playerXP: Int
    var xpToNext: Int
    var highestLevelCompleted: Int
    var endlessHiScore: Int
    var xpMultiplier: Int
    // TODO: Implement kills and tracking -- don't reset!
    
    init(playerLevel:Int, playerXP:Int, xpToNextLvl:Int, highestLevelCompleted:Int, endlessHiScore:Int, xpMulti:Int) {
        self.playerLevel = 20
        self.playerXP = playerXP
        self.xpToNext = xpToNextLvl
        self.highestLevelCompleted = highestLevelCompleted
        self.endlessHiScore = endlessHiScore
        self.xpMultiplier = xpMulti
    }
}
