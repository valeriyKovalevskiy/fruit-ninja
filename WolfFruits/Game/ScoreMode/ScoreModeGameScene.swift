//
//  GameScene.swift

import SpriteKit
import GameplayKit
import AVFoundation

class ScoreModeGameScene: SKScene {
    
  // MARK: - Properties
    weak var gameDelegate: GameSceneDelegate?
    var gamePhase = GamePhase.ready
    var hearts = Hearts()
    var fruitThrowTimer = Timer()
    var introLabel = SKLabelNode()
    var backgroundMusic: SKAudioNode!
    var misses = 0
    let missesMax = 3
    let sliceFruitSound = SKAction.playSoundFileNamed("sliceFruitSound.caf", waitForCompletion: false)
    let missedFruitSound = SKAction.playSoundFileNamed("missedFruitSound.caf", waitForCompletion: false)
    let bombExplosionSound = SKAction.playSoundFileNamed("bombExplosionSound.caf", waitForCompletion: false)
    let bombSound = SKAction.playSoundFileNamed("bombSound.caf", waitForCompletion: false)
    var fruitScore = 0
    
  // MARK: - Scene cycle
  override func didMove(to view: SKView) {
    physicsWorld.gravity = CGVector(dx: 0, dy: -5)
    
    hearts = Hearts(num: missesMax)
    introLabel = childNode(withName: "introLabel") as! SKLabelNode
    introLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
    hearts.position = CGPoint(x: size.width - 120, y: size.height - 40)
    addChild(hearts)
    addBackground()
  }
    
    override func didSimulatePhysics() {
        for fruit in children {
            
            if fruit.position.y < -100 {
                fruit.removeFromParent()
                if fruit.name == "fruit_1" || fruit.name == "fruit_2" || fruit.name == "fruit_3" || fruit.name == "fruit_4" || fruit.name == "fruit_5" || fruit.name == "fruit_6" || fruit.name == "fruit_7" {
                    missFruit()
                }
            }
        }
    }

  // MARK: - Touches
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let randomSwooshNumber = 1 + arc4random_uniform(4)
    let sliceSound = SKAction.playSoundFileNamed("swoosh_\(randomSwooshNumber).caf", waitForCompletion: false)
    play(sound: sliceSound)
    
    if gamePhase == .ready {
        gamePhase = .inPlay
        startGame()
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    for t in touches {
        let location = t.location(in: self)
        let previous = t.previousLocation(in: self)
        for node in nodes(at: location) {
            if node.name == "fruit_1" || node.name == "fruit_2" || node.name == "fruit_3" || node.name == "fruit_4" || node.name == "fruit_5" || node.name == "fruit_6" || node.name == "fruit_7" {
                if let fruit = node.name {
                    GameStorage.shared.score += fruitsScore(fruit: fruit)
                }
                play(sound: sliceFruitSound)
                gameDelegate?.updateScoreLabel()
                node.removeFromParent()
                particleEffect(position: node.position, filename: "sliceHitEnemy.sks")

            }
            if node.name == "bomb" {
                bombExplode()
            }
        }
        let line = TrialLine(position: location, lastPosition: previous, width: 8, color: .red)
        addChild(line)
    }
  }

  // MARK: - Methods
    func setTimer() {
        let randomTimeFruitSpawn = Double(randomCGFloat(0.8, 3.5))
        fruitThrowTimer = Timer.scheduledTimer(withTimeInterval: randomTimeFruitSpawn, repeats: true, block: { _ in
            self.createFruits()
        })
    }
    
    func trackGameIsPaused() {
        guard GameStorage.shared.isPaused else {
            physicsWorld.speed = 1
            isUserInteractionEnabled = true
            setTimer()
            return
        }
        physicsWorld.speed = 0
        isUserInteractionEnabled = false
        fruitThrowTimer.invalidate()
    }
    
    func missFruit() {
        play(sound: missedFruitSound)
        VibrationManager.shared.heavyImpact()
        guard GameStorage.shared.score >= 0 else { return gameOver() }
        GameStorage.shared.score -= 25
        gameDelegate?.updateScoreLabel()
    }
    
    func bombExplode() {
        for case let fruit as FruitScoreMode in children {
            VibrationManager.shared.heavyImpact()
            play(sound: bombExplosionSound)
            fruit.removeFromParent()
            particleEffect(position: fruit.position, filename: "sliceHitBomb.sks")
        }
            misses += 1
            hearts.update(num: misses)
            if misses == missesMax {
                gameOver()
        }
    }
    
    func particleEffect(position: CGPoint, filename: String) {
        let emitter = SKEmitterNode(fileNamed: filename)
        emitter?.position = position
        addChild(emitter!)
    }
    
    func addBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = size
        background.zPosition = -1
        addChild(background)
    }
    
    func startGame() {
        introLabel.isHidden = true
        misses = 0
        GameStorage.shared.score = 0
        gameDelegate?.updateScoreLabel()
        hearts.reset()
        setTimer()
        startBackgroundMusic()
    }
    
    func createFruits() {
        //we can implement logics of difficulty according score
        let numberOfFruits = 1 + arc4random_uniform(UInt32(6))
        for _ in 0..<numberOfFruits {
            //fruitTossStartPosition
            let fruit = FruitScoreMode()
            fruit.position.x = randomCGFloat(0, size.width)
            fruit.position.y = -100
            addChild(fruit)
            
            if fruit.position.x < size.width / 2 {
                fruit.physicsBody?.velocity.dx = randomCGFloat(0, 200)
            }
            if fruit.position.x > size.width / 2 {
                fruit.physicsBody?.velocity.dx = randomCGFloat(0, -200)
            }
            //для айпада гравити больше 700 1150
            fruit.physicsBody?.velocity.dy = randomCGFloat(500, 800)
            fruit.physicsBody?.angularVelocity = randomCGFloat(-5, 5)
        }
    }

    func gameOver() {
        VibrationManager.shared.cancelVibration()
        if GameStorage.shared.score > GameStorage.shared.scoreModeBestScore {
            GameStorage.shared.scoreModeBestScore = GameStorage.shared.score
        }
        fruitThrowTimer.invalidate()
        gamePhase = .gameOver
        gameDelegate?.gameSceneGameOver()
    }
    
    func fruitsScore(fruit: String) -> Int {
        var score = 0
        switch fruit {
        case "fruit_1":
            score = 1
        case "fruit_2":
            score = 3
        case "fruit_3":
            score = 5
        case "fruit_4":
            score = 7
        case "fruit_5":
            score = 10
        case "fruit_6":
            score = 13
        case "fruit_7":
            score = 15
        default:
            break
        }
        return score
    }
}

extension ScoreModeGameScene {
    func startBackgroundMusic() {
        guard !GameStorage.shared.sound else {
            if let backgroundMusic = backgroundMusic {
                backgroundMusic.removeFromParent()
            }
            return
        }
        if backgroundMusic == nil {
            if let musicURL = Bundle.main.url(forResource: "ghostrifter-official-on-my-way", withExtension: "mp3") {
                backgroundMusic = SKAudioNode(url: musicURL)
                addChild(backgroundMusic)
            }
        }
    }
    
    func stopBackgroundMusic() {
        if let backgroundMusic = backgroundMusic {
            backgroundMusic.removeFromParent()
        }
    }
    
    func play(sound: SKAction) { //slice, bomb
        guard !GameStorage.shared.sound else {
            return
        }
        run(sound, withKey: "sound")
    }
}
