//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by student on 8/30/16.
//  Copyright (c) 2016 student. All rights reserved.
//

import SpriteKit

// override operators
func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

// extension of CGPoint class to aid in calculations
extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

// categories for sprites
struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "ship")
    var monstersKilled = 0
    let numToWin = 30
    let numToLose = 5
    var monstersEscaped = 0
    
    let defaults = UserDefaults.standard
    var playerLevel = 1
    var playerXP = 0
    var xpToNext = 0
    
    let destroyedLabel = SKLabelNode(fontNamed: "Georgia")
    let escapedLabel = SKLabelNode(fontNamed: "Georgia")
    
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.white
        
       
        player.position = CGPoint(x: size.width / 2, y: 0 + player.size.height)
        
        // JHAT: Determine player xp and level
        let level = defaults.object(forKey: "level")
        let xp = defaults.object(forKey: "xp")
        
        playerLevel = level != nil ? (level! as AnyObject).intValue : 1
        playerXP = xp != nil ? (xp! as AnyObject).intValue : 0
        xpToNext = xpToNextLevel(playerLevel) - (playerXP - xpToCurrentLevel(playerLevel)) // JHAT: accurately determine player progession
        
        
        self.addChild(player)
        
        // set up physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // no gravity
        physicsWorld.contactDelegate = self
        
        // create labels
        destroyedLabel.name = "desLab"
        destroyedLabel.position = CGPoint(x: 5, y: self.frame.height-5)
        destroyedLabel.verticalAlignmentMode = .top
        destroyedLabel.horizontalAlignmentMode = .left
        destroyedLabel.text = "Killed: \(monstersKilled)"
        destroyedLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        destroyedLabel.fontSize = 30
        self.addChild(destroyedLabel)
        
        escapedLabel.name = "esLab"
        escapedLabel.position = CGPoint(x: self.frame.width - 5, y: self.frame.height - 5)
        escapedLabel.verticalAlignmentMode = .top
        escapedLabel.horizontalAlignmentMode = .right
        escapedLabel.text = "Escaped: \(monstersEscaped)"
        escapedLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        escapedLabel.fontSize = 30
        self.addChild(escapedLabel)
        
        // add BGM
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addMonster),
                SKAction.wait(forDuration: 1.0)
                ])
            ))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func updateLabel(_ label: SKLabelNode) {
        label.name == "desLab" ? (label.text = "Killed: \(monstersKilled)") : (label.text = "Escaped: \(monstersEscaped)")
    }
    
    func addMonster() {
        // create sprite
        let monster = SKSpriteNode(imageNamed: "enemy")
        
        // apply physics body to the sprite
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)
        monster.physicsBody?.isDynamic = true
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // determine where to spawn the monster on the X and Y axis
        let actualY = size.height + monster.size.height
        
        // TODO: Determine level number and select preset spawn point (separate function)
        let actualX = random(min: monster.size.width / 2, max: size.width - monster.size.width / 2)
        
        // position the monster slightly off screen on the right edge and along a random position along the yAxis
        monster.position = CGPoint(x: actualX, y: actualY)
        
        // add monster to the scene
        addChild(monster)
        
        // determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // create the actions
        // TODO: Determine level and create preset path based on spawn point above (separate function)
        let actionMove = SKAction.move(to: CGPoint(x: actualX, y: -monster.size.height / 2), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run() {
            self.monstersEscaped += 1
            self.updateLabel(self.escapedLabel)
            if (self.monstersEscaped >= self.numToLose) {
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: reveal)
            }
        }
        
        monster.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // TODO: Compare against fire rate timer
        
        // Choose a touch to work with
        guard let touch = touches.first else { return };
        
        let touchLocation = touch.location(in: self)
        
        // set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "bullet")
        projectile.position = player.position
        
        // apply physics body to prjectile sprite
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width / 2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // determine offset of location of projectile
        let offset = touchLocation - projectile.position;
        
        // do not allow down shooting
        if (offset.y < 0) { return }
        
        // TODO: determine if touch is within fire range (Field of View)
        
        // add particle emitter to projectiles
        //let emitter = SKEmitterNode(fileNamed: "trail")!
        //emitter.position = CGPointMake(player.position.x - 5, player.position.y)
        //addChild(emitter)
        
        // trigger sound effect
        run(SKAction.playSoundFileNamed("pew-pew-lei.caf", waitForCompletion: false))
        
        // add projectile
        addChild(projectile)
        
        // get the direction to shoot it
        let direction = offset.normalized();
        
        // have distance be off screen
        let range = direction * 1000
        
        // add range to current position
        let target = range + projectile.position;
        
        // create the actions
        let actionMove = SKAction.move(to: target, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        //emitter.runAction(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // assign bodies based on category
        if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // check if projectile and monster collided
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
    }
    
    func projectileDidCollideWithMonster(_ projectile: SKSpriteNode, monster: SKSpriteNode) {
        monstersKilled += 1
        self.updateLabel(self.destroyedLabel)
        if (monstersKilled >= numToWin) {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    // Utility functions
    func getSpawnPoint(_ level: Int) -> CGFloat {
        switch(level) { // JHAT: return x spawn based on level
            default:
                return 0
        }
    }
    
    func getPath(_ level: Int) -> [SKAction] {
        switch (level) { // JHAT: return array defining path for specific level
            default:
                return []
        }
    }
    
    func xpToNextLevel(_ currentLevel: Int) -> Int {
        return (25 * (currentLevel - 1) + 50) // JHAT: function to determine xp for each level
    }
    
    func xpToCurrentLevel(_ currentLevel: Int) -> Int { // JHAT: function to determine the xp earned already to accurately get current level progress
        var level = currentLevel
        var totalXP = 0
        while (level > 1) {
            totalXP += xpToNextLevel(level)
            level -= 1
        }
        return totalXP
    }
    
    // TODO: save progress between levels and when user quits or puts app in background
    func saveProgress() { // JHAT: save player progression to userdefaults
        defaults.set(playerLevel, forKey: "level")
        defaults.set(playerXP, forKey: "xp")
    }
}

