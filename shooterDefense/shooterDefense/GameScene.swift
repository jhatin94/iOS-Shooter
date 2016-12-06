//
//  GameScene.swift
//  SpriteKitSimpleGame
//
//  Created by student on 8/30/16.
//  Copyright (c) 2016 student. All rights reserved.
//

import SpriteKit

// MARK: extensions and overrides
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

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate {
    var earthImg = SKSpriteNode(imageNamed: "earth.png")
    let sceneManager: GameViewController
    var isPhone: Bool = false
    var isGamePaused: Bool = false
    var currentGameLevel: Int
    let player: SKSpriteNode
    var enemiesKilled = 0
    var numToWin = 0
    let numToLose = 5
    var enemiesEscaped = 0
    var score = 0
    var canShoot = true
    var superActive = true
    let playerProfile: PlayerProfile
    
    let destroyedLabel = SKLabelNode(fontNamed: "Pixeled")
    let escapedLabel = SKLabelNode(fontNamed: "Pixeled")
    let playerLvlLabel = SKLabelNode(fontNamed: "Pixeled")
    let playerXPToNextLabel = SKLabelNode(fontNamed: "Pixeled")
    let shotStatus = SKLabelNode(fontNamed: "Pixeled")
    let endlessScore = SKLabelNode(fontNamed: "Pixeled")
    var pauseTitle = SKLabelNode(fontNamed: "Pixeled")
    var returnToMain = SKLabelNode(fontNamed: "Pixeled")
    let superStatus = SKLabelNode(fontNamed: "Pixeled")
    var enemySpawns: [CGPoint] = []
    var loseAction: SKAction
    var finishActionMove: SKAction
    var ySpawn: CGFloat
    var ySpawn2: CGFloat
    var ENEMY_HEIGHT_WIDTH: CGFloat = 42.0 // 42 is default small enemy
    let BASE_XP_PER_KILL = 2
    var multiplierXP: Int
    
    // movement variables
    var playableRect = CGRect.zero
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let marginV = CGFloat(12.0)
    let marginH = CGFloat(12.0)
    let shipMaxSpeedPerSecond = CGFloat(800.0)
    
    // MARK: INIT
    init(size:CGSize, level:Int, sceneManager:GameViewController, playerProgress:PlayerProfile, isDevicePhone: Bool) {
        self.sceneManager = sceneManager
        self.isPhone = isDevicePhone
        self.currentGameLevel = level
        self.playerProfile = playerProgress
        self.multiplierXP = playerProgress.xpMultiplier
        self.player = SKSpriteNode(imageNamed: "ship" + playerProfile.currentTheme)
        self.loseAction = SKAction.run {}
        self.finishActionMove = SKAction.run {}
        self.ySpawn = size.height + ENEMY_HEIGHT_WIDTH // all enemies will spawn at same yPos
        self.ySpawn2 = size.height + ENEMY_HEIGHT_WIDTH - 300 // all side enemies will spawn at same yPos
        super.init(size: size)
        enemySpawns = getSpawnPoints(level)
    }
    
    // override init for scene
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        /* Setup your scene here */
        backgroundColor = SKColor.black
        initGestures()
        
        let backgroundMenu = SKSpriteNode(imageNamed: "background" + playerProfile.currentTheme)
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -2
        self.addChild(backgroundMenu)
        
        earthImg = SKSpriteNode(imageNamed: "earth.png")
        earthImg.position = CGPoint(x: frame.size.width / 2, y: 100)
        earthImg.zPosition = -1
        self.addChild(earthImg)
        
        let motherImg = SKSpriteNode(imageNamed: "mothership.png")
        motherImg.position = CGPoint(x: frame.size.width / 2, y: frame.size.height-100)
        motherImg.zPosition = -1
        self.addChild(motherImg)
        
        player.position = CGPoint(x:playableRect.midX + size.width/2, y:playableRect.midY+200)
        player.name = "ship"
        player.zPosition = 1
        player.setScale(2)
        self.addChild(player)
        
        // set up physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // no gravity
        physicsWorld.contactDelegate = self
        
        // update labels
        self.addChild(updateLabelProperties(labelToModify: destroyedLabel, pos: CGPoint(x: 5, y: self.frame.height-5), vAl: .top, hAl: .left, text: "Enemies: \((numToWin-enemiesKilled))", fontSize: 30, name: "desLab"))
        
        self.addChild(updateLabelProperties(labelToModify: escapedLabel, pos: CGPoint(x: self.frame.width - 5, y: self.frame.height - 5), vAl: .top, hAl: .right, text: "Escaped: \(enemiesEscaped)", fontSize: 30, name: "esLab"))
        
        // xp levels
        self.addChild(updateLabelProperties(labelToModify: playerLvlLabel, pos: CGPoint(x: 5, y: self.frame.height - 50), vAl: .top, hAl: .left, text: "XP Level: \(playerProfile.playerLevel)", fontSize: 30, name: "lvlLab"))
        
        self.addChild(updateLabelProperties(labelToModify: playerXPToNextLabel, pos: CGPoint(x: self.frame.width - 5, y: self.frame.height - 50), vAl: .top, hAl: .right, text: "XP To Next Level: \(playerProfile.xpToNext)", fontSize: 30, name: "xpLab"))
        
        self.addChild(updateLabelProperties(labelToModify: shotStatus, pos: CGPoint(x: self.frame.width - 50, y: 75), vAl: .bottom, hAl: .right, text: "Fire", fontSize: 30, name: "shotStatus"))
        
        self.addChild(updateLabelProperties(labelToModify: superStatus, pos: CGPoint(x: 50, y: 75), vAl: .bottom, hAl: .left, text: "Super Ready", fontSize: 30, name: "supStatus"))
        
        // update endless label if in endless
        if (currentGameLevel < 1) {
            self.addChild(updateLabelProperties(labelToModify: endlessScore, pos: CGPoint(x: self.frame.width/2, y: 50), vAl: .bottom, hAl: .center, text: "Score: \(score)", fontSize: 30, name: "scoreLab"))
        }
        
        // pause create labels
        pauseTitle = createPixeledLabel(pos: CGPoint(x: self.frame.width/2, y: self.frame.height/2 + 200), fontSize: 48, text: "PAUSED", name: "paused")
        
        returnToMain = createPixeledLabel(pos: CGPoint(x: self.frame.width/2, y: self.frame.height/2 - 100), fontSize: 36, text: "Return to Main Menu", name: "pausedToMain")
        
        // Add BGM to scene
        let backgroundMusic = SKAudioNode(fileNamed: "8-bit.mp3")
        backgroundMusic.autoplayLooped = true
        addChild(backgroundMusic)
        
        // JHAT: Display tutorial pop-up based on level
        if (playerProfile.highestLevelCompleted < currentGameLevel || currentGameLevel == 0) {
            // only show hint if not finished level or endless
            showHint()
        }
        
        // all enemies will trigger the same lose and done actions
        self.loseAction = SKAction.run() {
            self.enemiesEscaped += 1
            self.updateLabel(self.escapedLabel)
            self.earthHit()
            if (self.enemiesEscaped >= self.numToLose) {
                if (self.currentGameLevel < 1) { // If endless (level 0), save hiscore with scenemanager
                    self.sceneManager.setEndlessHiScore(endlessScore: self.score, playerProfile: self.playerProfile)
                }
                else { // save profile as is, no update needed
                    self.sceneManager.saveProgress(profileToSave: self.playerProfile)
                }
                self.sceneManager.loadLevelFinishedScene(lvl: self.currentGameLevel, success: false, score: self.score)
            }
        }
        self.finishActionMove = SKAction.removeFromParent()
        
        // enemy spawn scale based on player level at start of level
        var levelSpawnTimeScale = 3.0 - Double(playerProfile.playerLevel / 10)
        levelSpawnTimeScale = levelSpawnTimeScale <= 1 ? 1 : levelSpawnTimeScale
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addEnemy),
                SKAction.wait(forDuration: 1.0 * levelSpawnTimeScale)
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
        switch (label.name) {
        case "desLab"?:
            label.text = "Enemies: \((numToWin-enemiesKilled))"
            break
        case "esLab"?:
            label.text = "Escaped: \(enemiesEscaped)"
            break
        case "xpLab"?:
            label.text = "XP To Next Level: \(playerProfile.xpToNext)"
            break
        case "lvlLab"?:
            label.text = "XP Level: \(playerProfile.playerLevel)"
            break
        case "shotStatus"?:
            let status = canShoot ? "Fire" : "Reloading"
            label.text = "\(status)"
            break
        case "supStatus"?:
            let supStatus = superActive ? "Super Ready" : "Recharging"
            label.text = "\(supStatus)"
            break
        case "scoreLab"?:
            label.text = "Score: \(score)"
            break
        default:
            break
        }
    }
    
    func addEnemy() {
        let enemy: SKSpriteNode = getEnemyType() // get sprite and health
        enemy.name = "enemy"
        
        // apply physics body to the sprite
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        // set enemy position to spawn based on level
        let spawnPoint:Int = Int(random(min: 0, max: CGFloat(enemySpawns.count)))
        enemy.position = enemySpawns[spawnPoint]
        enemy.zPosition = 0
        
        // add enemy to the scene
        addChild(enemy)
        
        // determine speed of the enemy -- scales up with player level
        var speedScale:CGFloat = 1.05 - CGFloat(playerProfile.playerLevel) * 0.05
        speedScale = speedScale < 0 ? 0 : speedScale
        let health = enemy.userData?.value(forKey: "health") as! Int
        let actualDuration = random(min: CGFloat((2.0 + (4.0 * speedScale)) * CGFloat(health * health)), max: CGFloat((4.0 + (4.0 * speedScale)) * CGFloat(health * health)))
        
        // create the actions
        // Determine level and create preset path based on spawn point above (separate function)
        enemy.run(SKAction.sequence(getPath(currentGameLevel, spawn: enemy.position, movementScale: actualDuration)))
    }
    
    // MARK: Touch overrides
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Choose a touch to work with if game is paused
        if (isGamePaused) {
            guard let touch = touches.first else { return };
            let touchLocation = touch.location(in: self)
            let node = self.atPoint(touchLocation)
            
            if (node.name == "pausedToMain") {
                togglePause()
                sceneManager.loadMenu(menuToLoad: MenuScene.MenuType.main)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!isGamePaused) { // don't allow firing while paused
            // Choose a touch to work with
            guard let touch = touches.first else { return };
            
            let touchLocation = touch.location(in: self)
            
            // set up initial location of projectile
            let projectile = SKSpriteNode(imageNamed: "bullet")
            projectile.name = "bullet"
            projectile.position = player.position
            projectile.zPosition = 0
            
            // apply physics body to projectile sprite
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
            
            // JHAT: calculate touch angle
            let outerAngle = atan(offset.y/offset.x) * CGFloat(180 / M_PI)
            let innerAngle = outerAngle > 0 ? 90 - outerAngle : -90 - outerAngle
            
            // JHAT: determine if touch is within fire range (Field of View)
            let currentFOV: CGFloat = CGFloat(playerProfile.playerLevel * 5)
            if (abs(innerAngle) > currentFOV) {
                return
            }
            
            // if chost is valid, compare against fire rate timer
            if (canShoot) {
                canShoot = false
                updateLabel(shotStatus)
                let fireRate = 2.15 - (TimeInterval(playerProfile.playerLevel) * 0.15)
                _ = Timer.scheduledTimer(timeInterval: fireRate, target: self, selector: #selector(allowShooting), userInfo: nil, repeats: false)
            }
            else {
                return
            }
            
            // trigger sound effect
            run(SKAction.playSoundFileNamed("8-bit-shot.wav", waitForCompletion: false))
            
            // add projectile
            addChild(projectile)
            
            // get the direction to shoot it
            let direction = offset.normalized();
            
            // have distance be off screen, eventually. Distance increases with player level
            let range = direction * CGFloat(playerProfile.playerLevel * 100)
            
            // add range to current position
            let target = range + projectile.position;
            
            // create the actions
            let bulletSpeed = (playerProfile.playerLevel * 100) > 1000 ? 2.0 : 1.0 // scale bullet speed based on range
            let actionMove = SKAction.move(to: target, duration: TimeInterval(bulletSpeed))
            let actionMoveDone = SKAction.removeFromParent()
            projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        }
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
        
        guard firstBody.node != nil && secondBody.node != nil else {
            return
        }
        
        // check if projectile and enemy collided
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            let body1 = firstBody.node as! SKSpriteNode
            var body2 = secondBody.node as? SKSpriteNode
            var projWasSuper = false
            if (body2 == nil) { // JHAT: check if above cast failed, if so emitter collision
                body2 = body1 // pass in enemy twice
                projWasSuper = true
            }
            projectileDidCollideWithEnemy(body1, projectile: body2!, superColl: projWasSuper)
        }
    }
    
    func projectileDidCollideWithEnemy(_ enemy: SKSpriteNode, projectile: SKSpriteNode, superColl: Bool) {
        var health = enemy.userData?.value(forKey: "health") as! Int
        health -= 1
        enemy.userData?.setValue(health, forKey: "health")
        if (health < 1 || superColl) {
            enemiesKilled += 1
            numToWin = currentGameLevel < 1 && enemiesKilled % numToWin == 0 ? numToWin + 9999 : numToWin //JHAT: Handle case if player 'clears' endless mode
            let strength = enemy.userData?.value(forKey: "strength") as! Int
            self.updateLabel(self.destroyedLabel)
            sceneManager.gainXP(xpGained: ((BASE_XP_PER_KILL * strength) * multiplierXP), playerProfile: playerProfile)
            self.updateLabel(self.playerXPToNextLabel)
            self.updateLabel(self.playerLvlLabel)
            sceneManager.enemyKilled(playerProfile: playerProfile) // increment profile kill count
            
            // update score and label if endless
            if (currentGameLevel < 1) {
                increaseScore(baseScore: BASE_XP_PER_KILL)
                self.updateLabel(endlessScore)
            }
            
            if (enemiesKilled >= numToWin && currentGameLevel > 0) { // JHAT: Skip check on endless mode (level 0)
                if (currentGameLevel > playerProfile.highestLevelCompleted) {
                    // if level complete is higher than profile progress, update and save
                    sceneManager.setHighestLevelComplete(lvlComplete: currentGameLevel, playerProfile: playerProfile)
                }
                else { // save profile as is, no update needed
                    sceneManager.saveProgress(profileToSave: playerProfile)
                }
                
                // if last level GameOver screen is shown
                sceneManager.loadLevelFinishedScene(lvl: currentGameLevel, success: true, score: score)
            }
            if ((enemy.name == "enemy" && projectile.name != "enemy") || (enemy.name != "enemy" && projectile.name == "enemy")) { // if enemy was passed in twice only remove it once
                enemy.removeFromParent()
            }
        }
        run(SKAction.playSoundFileNamed("8-bit-explosion.wav", waitForCompletion: false))
        projectile.removeFromParent()
    }
    
    // MARK: Utility functions
    func getEnemyType() -> SKSpriteNode{
        // create sprite
        if (currentGameLevel < 1 || currentGameLevel > 3) { // get random enemy type
            let enemyType = Int(random(min: 1, max: 4))
            switch (enemyType) {
            case 1:
                let enemy1 = SKSpriteNode(imageNamed: "enemy" + playerProfile.currentTheme)
                enemy1.userData = NSMutableDictionary()
                enemy1.userData?.setValue(1, forKey: "health")
                enemy1.userData?.setValue(1, forKey: "strength")
                if (isPhone) {
                    enemy1.setScale(1.5)
                    ENEMY_HEIGHT_WIDTH *= 1.5;
                }
                return enemy1
            case 2:
                let enemy2 = SKSpriteNode(imageNamed: "enemy" + playerProfile.currentTheme + "2")
                enemy2.userData = NSMutableDictionary()
                enemy2.userData?.setValue(2, forKey: "health")
                enemy2.userData?.setValue(2, forKey: "strength")
                return enemy2
            case 3:
                let enemy3 = SKSpriteNode(imageNamed: "enemy" + playerProfile.currentTheme + "3")
                enemy3.userData = NSMutableDictionary()
                enemy3.userData?.setValue(3, forKey: "health")
                enemy3.userData?.setValue(3, forKey: "strength")
                return enemy3
            default:
                let enemy = SKSpriteNode(imageNamed: "enemy" + playerProfile.currentTheme)
                enemy.userData = NSMutableDictionary()
                enemy.userData?.setValue(1, forKey: "health")
                enemy.userData?.setValue(1, forKey: "strength")
                if (isPhone) {
                    enemy.setScale(1.5)
                    ENEMY_HEIGHT_WIDTH *= 1.5;
                }
                return enemy
            }
        }
        else { // basic levels, with simple enemy
            let enemy = SKSpriteNode(imageNamed: "enemy" + playerProfile.currentTheme)
            enemy.userData = NSMutableDictionary()
            enemy.userData?.setValue(1, forKey: "health")
            enemy.userData?.setValue(1, forKey: "strength")
            enemy.name = "enemy"
            if (isPhone) {
                enemy.setScale(1.5)
                ENEMY_HEIGHT_WIDTH *= 1.5;
            }
            return enemy
        }
    }
    
    func getSpawnPoints(_ level: Int) -> [CGPoint] { // vars x + level num + spawn num
        switch(level) { // JHAT: return spawn based on level
        case 0: // endless mode spawns
            var spawns = getSpawnPoints(1)
            
            // merge all spawns into one collection
            spawns.append(contentsOf: getSpawnPoints(2))
            spawns.append(contentsOf: getSpawnPoints(3))
            spawns.append(contentsOf: getSpawnPoints(4))
            spawns.append(contentsOf: getSpawnPoints(5))
            numToWin = 9999
            
            return spawns
        case 1: // determine where to spawn the enemy on the X and Y axis
            numToWin = 5
            let x11 = size.width / 2
            return [CGPoint(x: x11, y: ySpawn)]
        case 2:
            numToWin = 15
            let x21 = size.width / 4
            let x22 = size.width * 3 / 4
            return [CGPoint(x: x21, y: ySpawn), CGPoint(x: x22, y: ySpawn)]
        case 3:
            numToWin = 25
            let x31 = size.width / 4
            let x32 = size.width * 3 / 4
            let x33 = size.width / 2
            return [CGPoint(x: x31, y: ySpawn), CGPoint(x: x32, y: ySpawn), CGPoint(x: x33, y: ySpawn)]
        case 4:
            numToWin = 35
            let x41 = size.width / 8
            let x42 = size.width * 2 / 8
            let x43 = size.width * 3 / 8
            let x44 = size.width * 4 / 8
            let x45 = size.width * 5 / 8
            let x46 = size.width * 6 / 8
            let x47 = size.width * 7 / 8
            return [CGPoint(x: x41, y: ySpawn), CGPoint(x: x42, y: ySpawn), CGPoint(x: x43, y: ySpawn), CGPoint(x: x44, y: ySpawn),CGPoint(x: x45, y: ySpawn), CGPoint(x: x46, y: ySpawn),CGPoint(x: x47, y: ySpawn)]
        case 5:
            numToWin = 50
            let x51 = size.width / 6
            let x52 = size.width * 2 / 6
            let x53 = size.width * 3 / 6
            let x54 = size.width * 4 / 6
            let x55 = size.width * 5 / 6
            let x56 = size.width + 100 // off screen for ySpawn 2
            let x57 = CGFloat(-100.0)
            return [CGPoint(x: x51, y: ySpawn), CGPoint(x: x52, y: ySpawn), CGPoint(x: x53, y: ySpawn), CGPoint(x: x54, y: ySpawn),CGPoint(x: x55, y: ySpawn), CGPoint(x: x56, y: ySpawn2), CGPoint(x: x57, y: ySpawn2)]
        default:
            return [CGPoint(x: 0, y: 0)]
        }
    }
    
    func getPath(_ level: Int, spawn: CGPoint, movementScale: CGFloat) -> [SKAction] { // move vars actionMove + level num + path num
        switch (level) { // JHAT: return array defining path for specific level
        case 0: // endless mode paths
            
            // determine which paths to return from other levels based on spawn
            if (spawn.x < 0 || spawn.x > size.width) { // off screen spawn needs level 5 path
                return getPath(5, spawn: spawn, movementScale: movementScale)
            }
            else { // randomly choose path from other levels
                let pathLevel:Int = Int(random(min: 1, max: 6))
                return getPath(pathLevel, spawn: spawn, movementScale: movementScale)
            }
        case 1:
            let actionMove11 = SKAction.move(to: CGPoint(x: spawn.x, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove11, loseAction, finishActionMove]
        case 2:
            let actionMove21 = SKAction.move(to: CGPoint(x: spawn.x, y: size.height/2), duration: TimeInterval(movementScale/2))
            let actionMove22 = SKAction.move(to: CGPoint(x: size.width/2, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale/2))
            return [actionMove21, actionMove22, loseAction, finishActionMove]
        case 3:
            let actionMove31 = SKAction.move(to: CGPoint(x: spawn.x, y: size.height/2), duration: TimeInterval(movementScale/2))
            let actionMove32 = SKAction.move(to: CGPoint(x: size.width/2, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale/2))
            return [actionMove31, actionMove32, loseAction, finishActionMove]
        case 4:
            let actionMove41 = SKAction.move(to: CGPoint(x: spawn.x, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove41, loseAction, finishActionMove]
        case 5:
            // separate between side enemies and top enemies
            if (spawn.x < 0 || spawn.x > size.width) { // side
                let actionMove51s = SKAction.move(to: CGPoint(x: size.width / 2, y: size.height/2 - 200), duration: TimeInterval(movementScale))
                let actionMove52s = SKAction.move(to: CGPoint(x: spawn.x < 0 ? 100 : size.width - 100 , y: size.height/2 - 500), duration: TimeInterval(movementScale/2))
                let actionMove53s = SKAction.move(to: CGPoint(x: size.width / 2, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale/2))
                return [actionMove51s, actionMove52s, actionMove53s, loseAction, finishActionMove]
            }
            else { // top
                let actionMove51 = SKAction.move(to: CGPoint(x: spawn.x + 100, y: (size.height * 3)/4), duration: TimeInterval(movementScale/4))
                let actionMove52 = SKAction.move(to: CGPoint(x: spawn.x - 100, y: size.height/2), duration: TimeInterval(movementScale/4))
                let actionMove53 = SKAction.move(to: CGPoint(x: size.width/2, y: size.height / 4), duration: TimeInterval(movementScale/4))
                let actionMove54 = SKAction.move(to: CGPoint(x: player.position.x, y: -ENEMY_HEIGHT_WIDTH), duration: TimeInterval(movementScale/4))
                return [actionMove51, actionMove52, actionMove53, actionMove54, loseAction, finishActionMove]
            }
        default:
            return []
        }
    }
    
    func earthHit() {
        earthImg.removeFromParent() // remove current graphic
        
        // update earth graphic
        switch (enemiesEscaped) {
        case 1:
            earthImg = SKSpriteNode(imageNamed: "earth2.png")
            break
        case 2:
            earthImg = SKSpriteNode(imageNamed: "earth3.png")
            break
        case 3:
            earthImg = SKSpriteNode(imageNamed: "earth4.png")
            break
        case 4:
            earthImg = SKSpriteNode(imageNamed: "earth5.png")
            break
        default:
            break
        }
        
        // add new graphic
        earthImg.position = CGPoint(x: frame.size.width / 2, y: 100)
        earthImg.zPosition = -1
        self.addChild(earthImg)
    }
    
    func showHint() { // returns specific hint per level to display to user
        var hintToShow = ""
        switch currentGameLevel {
        case 0:
            hintToShow = "Good Luck Pilot!"
            break
        case 1:
            hintToShow = "Tap ahead to shoot"
            break
        case 2:
            hintToShow = "Tilt the device to move"
            break
        case 3:
            hintToShow = "Two finger tap to fire super"
            break
        case 4:
            hintToShow = "Some enemies are stronger"
            break
        case 5:
            hintToShow = "Enemies can move sideways"
            break
        default:
            break
        }
        addChild(createPixeledLabel(pos: CGPoint(x: self.frame.width/3, y: player.position.y + 150), fontSize: 30, text: hintToShow, name: "hint"))
        _ = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(hideHint), userInfo: nil, repeats: false)
    }
    
    func hideHint() { // used to hide level hints
        let hint = childNode(withName: "hint")
        hint?.removeFromParent()
    }
    
    func allowShooting() { // used to re-enable shooting
        canShoot = true
        updateLabel(shotStatus)
    }
    
    func allowSuper() { // used to enable super ability
        superActive = true
        updateLabel(superStatus)
    }
    
    func increaseScore(baseScore: Int) { // used to keep track of endless score
        score += (baseScore * multiplierXP)
    }
    
    func calculateDeltaTime(currentTime: TimeInterval){
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    // MARK: Gesture functions
    func fireSuper() {
        if (superActive && !isGamePaused) {
            superActive = false
            updateLabel(superStatus)
            
            // fire super
            let emitter = SKEmitterNode(fileNamed: "trail")!
            emitter.name = "super"
            emitter.zPosition = 0
            emitter.position = CGPoint(x: self.frame.width / 2, y: player.position.y)
            emitter.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 1000, height: 20)) // emitter dimensions
            emitter.physicsBody?.isDynamic = true
            emitter.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
            emitter.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
            emitter.physicsBody?.collisionBitMask = PhysicsCategory.None
            emitter.physicsBody?.usesPreciseCollisionDetection = true
            addChild(emitter)
            
            let fireRate = 62.0 - (TimeInterval(playerProfile.playerLevel * 2)) // set cooldown
            _ = Timer.scheduledTimer(timeInterval: fireRate, target: self, selector: #selector(allowSuper), userInfo: nil, repeats: false)
            
            // set actions and run
            let actionMove = SKAction.move(to: CGPoint(x: self.frame.width / 2, y: self.frame.height + 200), duration: 2.0)
            let actionMoveDone = SKAction.removeFromParent()
            emitter.run(SKAction.sequence([actionMove, actionMoveDone]))
            run(SKAction.playSoundFileNamed("superSound.mp3", waitForCompletion: false))
        }
    }
    
    // create gesture functions
    func initGestures() {
        // setup pause three finger touch
        let pauseTap = UITapGestureRecognizer(target: self, action: #selector(togglePause))
        pauseTap.numberOfTapsRequired = 1
        pauseTap.numberOfTouchesRequired = 3
        pauseTap.delegate = self
        view!.addGestureRecognizer(pauseTap)
        
        // setup super two finger touch
        let superTap = UITapGestureRecognizer(target: self, action: #selector(fireSuper))
        superTap.numberOfTapsRequired = 1
        superTap.numberOfTouchesRequired = 2
        superTap.delegate = self
        view!.addGestureRecognizer(superTap)
    }
    
    // pause function
    func togglePause() {
        isGamePaused = !isGamePaused
        showHidePauseLabels(show: isGamePaused)
    }
    
    // toggle pause menu
    func showHidePauseLabels(show: Bool) {
        if (!show) { // if hiding, remove old appended labels
            pauseTitle.removeFromParent()
            returnToMain.removeFromParent()
            
            // pause gameScene and motion updates
            self.view?.isPaused = false
            physicsWorld.speed = 1.0
            MotionMonitor.sharedMotionMonitor.startUpdates()
        }
        // if showing, add to scene
        else {
            addChild(pauseTitle)
            addChild(returnToMain)
        }
    }
    
    // MARK: movement from device tilt
    func movePlayer(dt:CGFloat){
        let gravityVector = MotionMonitor.sharedMotionMonitor.gravityVectorNormalized
        var xVelocity = gravityVector.dx
        xVelocity = xVelocity < -0.33 ? -0.33 : xVelocity // -.33 = 30 degrees left
        xVelocity = xVelocity > 0.33 ? 0.33 : xVelocity // +0.33 = 30 degrees right
        
        xVelocity = xVelocity * 3
        
        if abs(xVelocity) < 0.1 {
            xVelocity = 0
        }
        
        if let playerSprite = childNode(withName: "ship"){
            playerSprite.position.x += xVelocity * shipMaxSpeedPerSecond * dt
            
            if (playerSprite.constraints == nil) {
                let xRange = SKRange(lowerLimit:100,upperLimit:size.width - (100))
                let yRange = SKRange(lowerLimit:0,upperLimit:size.height)
                //sprite.constraints = [SKConstraint.positionX(xRange,Y:yRange)] // iOS 9
                playerSprite.constraints = [SKConstraint.positionX(xRange,y:yRange)]
            }
        }
    }
    
    // MARK: Game Loop
    override func update(_ currentTime: TimeInterval){
        if (currentGameLevel != 1 && !isGamePaused) {
            calculateDeltaTime(currentTime: currentTime)
            movePlayer(dt: CGFloat(dt))
        }
        
        if (isGamePaused) {
            physicsWorld.speed = 0.0
            self.view?.isPaused = true
            MotionMonitor.sharedMotionMonitor.stopUpdates()
        }
    }
}
