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
    static let Enemy   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    let sceneManager: GameViewController
    var currentGameLevel: Int
    let player = SKSpriteNode(imageNamed: "ship")
    var enemiesKilled = 0
    let numToWin = 30
    let numToLose = 5
    var enemiesEscaped = 0
    
    let defaults = UserDefaults.standard
    var playerLevel = 1
    var playerXP = 0
    var xpToNext = 0
    
    let destroyedLabel = SKLabelNode(fontNamed: "Pixeled")
    let escapedLabel = SKLabelNode(fontNamed: "Pixeled")
    var enemySpawns: [CGPoint] = []
    let ENEMY_HEIGHT_WIDTH: CGFloat = 42.0
    
    init(size: CGSize, level:Int, sceneManager:GameViewController) {
        self.sceneManager = sceneManager
        self.currentGameLevel = level
        super.init(size: size)
        enemySpawns = getSpawnPoints(level)
        // TODO: Read player progression from model
    }
    
    // override init for scene
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.black
        
        let backgroundMenu = SKSpriteNode(imageNamed: "background")
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -1
        addChild(backgroundMenu)
        
       
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
        destroyedLabel.text = "Killed: \(enemiesKilled)"
        destroyedLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        destroyedLabel.fontSize = 30
        destroyedLabel.fontName = "Pixeled"
        self.addChild(destroyedLabel)
        
        escapedLabel.name = "esLab"
        escapedLabel.position = CGPoint(x: self.frame.width - 5, y: self.frame.height - 5)
        escapedLabel.verticalAlignmentMode = .top
        escapedLabel.horizontalAlignmentMode = .right
        escapedLabel.text = "Escaped: \(enemiesEscaped)"
        escapedLabel.fontColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        escapedLabel.fontSize = 30
        escapedLabel.fontName = "Pixeled"
        self.addChild(escapedLabel)
        
        // add BGM
        let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addEnemy),
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
        label.name == "desLab" ? (label.text = "Killed: \(enemiesKilled)") : (label.text = "Escaped: \(enemiesEscaped)")
    }
    
    func addEnemy() {
        // create sprite
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        // apply physics body to the sprite
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // set enemy position to spawn based on level
        let spawnPoint:Int = Int(random(min: 0, max: CGFloat(enemySpawns.count)))
        enemy.position = enemySpawns[spawnPoint]
        
        // add enemy to the scene
        addChild(enemy)
        
        // determine speed of the enemy
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // create the actions
        // TODO: Determine level and create preset path based on spawn point above (separate function)
        let actionMove = SKAction.move(to: CGPoint(x: enemy.position.x, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(actualDuration))
        
        let actionMoveDone = SKAction.removeFromParent()
        
        let loseAction = SKAction.run() {
            self.enemiesEscaped += 1
            self.updateLabel(self.escapedLabel)
            if (self.enemiesEscaped >= self.numToLose) {
                self.sceneManager.loadLevelFinishedScene(lvl: self.currentGameLevel, success: false)
            }
        }
        
        enemy.run(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
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
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
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
        
        // TODO: have range be dependent on level
        // have distance be off screen
        let range = direction * 2000
        
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
        
        // check if projectile and enemy collided
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithEnemy(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
        }
    }
    
    func projectileDidCollideWithEnemy(_ projectile: SKSpriteNode, enemy: SKSpriteNode) {
        enemiesKilled += 1
        self.updateLabel(self.destroyedLabel)
        if (enemiesKilled >= numToWin && currentGameLevel > 0) { // JHAT: Skip check on endless mode (level 0)
            // TODO: if last level, show GameOver screen instead
            sceneManager.loadLevelFinishedScene(lvl: currentGameLevel, success: true)
        }
        projectile.removeFromParent()
        enemy.removeFromParent()
    }
    
    // Utility functions
    func getSpawnPoints(_ level: Int) -> [CGPoint] {
        switch(level) { // JHAT: return spawn based on level
        case 1: // determine where to spawn the enemy on the X and Y axis
            let actualY = size.height + ENEMY_HEIGHT_WIDTH
            let actualX = size.width / 2
            return [CGPoint(x: actualX, y: actualY)]
        default:
            return [CGPoint(x: 0, y: 0)]
        }
    }
    
    func getPath(_ level: Int, spawn: CGPoint) -> [SKAction] {
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

