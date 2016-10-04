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
    var isPhone: Bool = false
    var currentGameLevel: Int
    let player = SKSpriteNode(imageNamed: "ship")
    var enemiesKilled = 0
    var numToWin = 0
    let numToLose = 5
    var enemiesEscaped = 0
    var score = 0
    var canShoot = true
    let playerProfile: PlayerProfile
    
    let destroyedLabel = SKLabelNode(fontNamed: "Pixeled")
    let escapedLabel = SKLabelNode(fontNamed: "Pixeled")
    let playerLvlLabel = SKLabelNode(fontNamed: "Pixeled")
    let playerXPToNextLabel = SKLabelNode(fontNamed: "Pixeled")
    let shotStatus = SKLabelNode(fontNamed: "Pixeled")
    let endlessScore = SKLabelNode(fontNamed: "Pixeled")
    var enemySpawns: [CGPoint] = []
    var loseAction: SKAction
    var finishActionMove: SKAction
    var ySpawn: CGFloat
    let ENEMY_HEIGHT_WIDTH: CGFloat = 42.0
    let BASE_XP_PER_KILL = 2
    var multiplierXP: Int
    
    // movement variables
    var playableRect = CGRect.zero
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    let marginV = CGFloat(12.0)
    let marginH = CGFloat(12.0)
    let shipMaxSpeedPerSecond = CGFloat(800.0)
    
    init(size:CGSize, level:Int, sceneManager:GameViewController, playerProgress:PlayerProfile, isDevicePhone: Bool) {
        self.sceneManager = sceneManager
        self.isPhone = isDevicePhone
        self.currentGameLevel = level
        self.playerProfile = playerProgress
        self.multiplierXP = playerProgress.xpMultiplier
        self.loseAction = SKAction.run {}
        self.finishActionMove = SKAction.run {}
        self.ySpawn = size.height + ENEMY_HEIGHT_WIDTH // all enemies will spawn at same yPos
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
        
        let backgroundMenu = SKSpriteNode(imageNamed: "background")
        backgroundMenu.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundMenu.zPosition = -2
        addChild(backgroundMenu)
        
        let earthImg = SKSpriteNode(imageNamed: "earth.png")
        earthImg.position = CGPoint(x: frame.size.width / 2, y: 100)
        earthImg.zPosition = -1
        addChild(earthImg)
        
        let motherImg = SKSpriteNode(imageNamed: "mothership.png")
        motherImg.position = CGPoint(x: frame.size.width / 2, y: frame.size.height-100)
        motherImg.zPosition = -1
        addChild(motherImg)
        
        player.position = CGPoint(x:playableRect.midX + size.width/2, y:playableRect.midY+200)
        player.name = "ship"
        player.setScale(2)
        self.addChild(player)
        
        // set up physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // no gravity
        physicsWorld.contactDelegate = self
        
        // create labels
        self.addChild(updateLabelProperties(labelToModify: destroyedLabel, pos: CGPoint(x: 5, y: self.frame.height-5), vAl: .top, hAl: .left, text: "Enemies: \((numToWin-enemiesKilled))", fontSize: 30, name: "desLab"))
        
        self.addChild(updateLabelProperties(labelToModify: escapedLabel, pos: CGPoint(x: self.frame.width - 5, y: self.frame.height - 5), vAl: .top, hAl: .right, text: "Escaped: \(enemiesEscaped)", fontSize: 30, name: "esLab"))
        
        // xp levels
        self.addChild(updateLabelProperties(labelToModify: playerLvlLabel, pos: CGPoint(x: 5, y: self.frame.height - 50), vAl: .top, hAl: .left, text: "XP Level: \(playerProfile.playerLevel)", fontSize: 30, name: "lvlLab"))
        
        self.addChild(updateLabelProperties(labelToModify: playerXPToNextLabel, pos: CGPoint(x: self.frame.width - 5, y: self.frame.height - 50), vAl: .top, hAl: .right, text: "XP To Next Level: \(playerProfile.xpToNext)", fontSize: 30, name: "xpLab"))
        
        self.addChild(updateLabelProperties(labelToModify: shotStatus, pos: CGPoint(x: self.frame.width - 50, y: 75), vAl: .bottom, hAl: .right, text: "Fire", fontSize: 30, name: "shotStatus"))
        
        // update endless label if in endless
        if (currentGameLevel < 1) {
            self.addChild(updateLabelProperties(labelToModify: endlessScore, pos: CGPoint(x: self.frame.width/2, y: 50), vAl: .bottom, hAl: .center, text: "Score: \(score)", fontSize: 30, name: "scoreLab"))
        }
        
        // TODO: add BGM
        //let backgroundMusic = SKAudioNode(fileNamed: "background-music-aac.caf")
        //backgroundMusic.autoplayLooped = true
        //addChild(backgroundMusic)
        
        // JHAT: Display tutorial pop-up based on level
        if (playerProfile.highestLevelCompleted < currentGameLevel || currentGameLevel == 0) {
            // only show hint if not finished level or endless
            showHint()
        }
        
        // all enemies will trigger the same lose and done actions
        self.loseAction = SKAction.run() {
            self.enemiesEscaped += 1
            self.updateLabel(self.escapedLabel)
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
        case "scoreLab"?:
            label.text = "Score: \(score)"
            break
        default:
            break
        }
    }
    
    func addEnemy() {
        // create sprite
        let enemy = SKSpriteNode(imageNamed: "enemy")
        if (isPhone) {
            enemy.setScale(2)
        }
        
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
        
        // determine speed of the enemy -- scales up with player level
        var speedScale:CGFloat = 1.05 - CGFloat(playerProfile.playerLevel) * 0.05
        speedScale = speedScale < 0 ? 0 : speedScale
        let actualDuration = random(min: CGFloat(2.0 + (4.0 * speedScale)), max: CGFloat(4.0 + (4.0 * speedScale)))
        
        // create the actions
        // Determine level and create preset path based on spawn point above (separate function)
        enemy.run(SKAction.sequence(getPath(currentGameLevel, spawn: enemy.position, movementScale: actualDuration)))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        
        // add particle emitter to projectiles -- TODO: implement emitter somewhere!
        //let emitter = SKEmitterNode(fileNamed: "trail")!
        //emitter.position = CGPointMake(player.position.x - 5, player.position.y)
        //addChild(emitter)
        
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
        
        guard firstBody.node != nil && secondBody.node != nil else { 
            return
        }
        
        // check if projectile and enemy collided
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
            projectileDidCollideWithEnemy(firstBody.node as! SKSpriteNode, enemy: secondBody.node as! SKSpriteNode)
        }
    }
    
    func projectileDidCollideWithEnemy(_ projectile: SKSpriteNode, enemy: SKSpriteNode) {
        enemiesKilled += 1
        numToWin = currentGameLevel < 1 && enemiesKilled % numToWin == 0 ? numToWin + 9999 : numToWin //JHAT: Handle case if player 'clears' endless mode
        self.updateLabel(self.destroyedLabel)
        sceneManager.gainXP(xpGained: (BASE_XP_PER_KILL * multiplierXP), playerProfile: playerProfile)
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
        run(SKAction.playSoundFileNamed("8-bit-explosion.wav", waitForCompletion: false))
        projectile.removeFromParent()
        enemy.removeFromParent()
    }
    
    // Utility functions
    func getSpawnPoints(_ level: Int) -> [CGPoint] {
        switch(level) { // JHAT: return spawn based on level
        case 0: // endless mode spawns
            numToWin = 9999
            // TODO: Add more spawns
            let xSpawn = size.width / 2
            return [CGPoint(x: xSpawn, y: ySpawn)]
        case 1: // determine where to spawn the enemy on the X and Y axis
            numToWin = 5
            let actualX = size.width / 2
            return [CGPoint(x: actualX, y: ySpawn)]
        case 2:
            numToWin = 15
            let x1 = size.width / 4
            let x2 = size.width * 3 / 4
            return [CGPoint(x: x1, y: ySpawn), CGPoint(x: x2, y: ySpawn)]
        case 3:
            numToWin = 25
            let x3 = size.width / 4
            let x4 = size.width * 3 / 4
            let x5 = size.width / 2
            return [CGPoint(x: x3, y: ySpawn), CGPoint(x: x4, y: ySpawn), CGPoint(x: x5, y: ySpawn)]
        case 4:
            numToWin = 35
            let x7 = size.width / 8
            let x8 = size.width * 2 / 8
            let x9 = size.width * 3 / 8
            let x10 = size.width * 4 / 8
            let x11 = size.width * 5 / 8
            let x12 = size.width * 6 / 8
            let x13 = size.width * 7 / 8
            return [CGPoint(x: x7, y: ySpawn), CGPoint(x: x8, y: ySpawn), CGPoint(x: x9, y: ySpawn), CGPoint(x: x10, y: ySpawn),CGPoint(x: x11, y: ySpawn), CGPoint(x: x12, y: ySpawn),CGPoint(x: x13, y: ySpawn)]
        case 5:
            numToWin = 50
            // TODO: Create final spawns
            let xSpawn1 = size.width / 2
            return [CGPoint(x: xSpawn1, y: ySpawn)]
        default:
            return [CGPoint(x: 0, y: 0)]
        }
    }
    
    func getPath(_ level: Int, spawn: CGPoint, movementScale: CGFloat) -> [SKAction] {
        switch (level) { // JHAT: return array defining path for specific level
        case 0: // endless mode paths
            // TODO: add more paths
            let actionMove0 = SKAction.move(to: CGPoint(x: spawn.x, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove0, loseAction, finishActionMove]
        case 1:
            let actionMove = SKAction.move(to: CGPoint(x: spawn.x, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove, loseAction, finishActionMove]
        case 2:
            let actionMove1 = SKAction.move(to: CGPoint(x: spawn.x, y: size.height/2), duration: TimeInterval(movementScale))
            let actionMove2 = SKAction.move(to: CGPoint(x: size.width/2, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove1, actionMove2, loseAction, finishActionMove]
        case 3:
            let actionMove3 = SKAction.move(to: CGPoint(x: spawn.x, y: size.height/2), duration: TimeInterval(movementScale))
            let actionMove4 = SKAction.move(to: CGPoint(x: size.width/2, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove3, actionMove4, loseAction, finishActionMove]
        case 4:
            let actionMove5 = SKAction.move(to: CGPoint(x: spawn.x, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove5, loseAction, finishActionMove]
        case 5:
            // TODO: create final paths
            let actionMove6 = SKAction.move(to: CGPoint(x: spawn.x, y: -ENEMY_HEIGHT_WIDTH / 2), duration: TimeInterval(movementScale))
            return [actionMove6, loseAction, finishActionMove]
        default:
                return []
        }
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
        case 3: //TODO: Add more level specific hints
            break
        case 4:
            break
        case 5:
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
                let xRange = SKRange(lowerLimit:100,upperLimit:size.width - (100)) // TODO: test limits
                let yRange = SKRange(lowerLimit:0,upperLimit:size.height)
                //sprite.constraints = [SKConstraint.positionX(xRange,Y:yRange)] // iOS 9
                playerSprite.constraints = [SKConstraint.positionX(xRange,y:yRange)]
            }
        }
    }
    
    //Mark Game Loop
    override func update(_ currentTime: TimeInterval){
        if (currentGameLevel != 1) {
            calculateDeltaTime(currentTime: currentTime)
            movePlayer(dt: CGFloat(dt))
        }
    }
}

