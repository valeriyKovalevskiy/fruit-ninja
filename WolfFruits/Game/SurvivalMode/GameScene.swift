//
//  GameScene.swift

import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene {
    
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
                if fruit.name == "fruit" {
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
            if node.name == "fruit" {
                GameStorage.shared.score += 1
                play(sound: sliceFruitSound)
                gameDelegate?.updateScoreLabel()
                node.removeFromParent()
                particleEffect(position: node.position, filename: "sliceHitEnemy.sks")
                //взрыв если бомба
                //звук слайс
            }
            if node.name == "bomb" {
                bombExplode()
                gameOver()
            }
        }
        //can implement custom slice line
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
        misses += 1
        play(sound: missedFruitSound)
        VibrationManager.shared.heavyImpact()
        hearts.update(num: misses)
        if misses == missesMax {
            gameOver()
        }
    }
    
    func bombExplode() {
        for case let fruit as Fruit in children {
            VibrationManager.shared.heavyImpact()
            play(sound: bombExplosionSound)
            fruit.removeFromParent()
            particleEffect(position: fruit.position, filename: "sliceHitBomb.sks")
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
		if numberOfFruits > 0 {
			print()
		}
        for _ in 0..<numberOfFruits {
            //fruitTossStartPosition
            let fruit = Fruit()
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
        if GameStorage.shared.score > GameStorage.shared.survivalModeBestScore {
            GameStorage.shared.survivalModeBestScore = GameStorage.shared.score
        }
		
        fruitThrowTimer.invalidate()
        gamePhase = .gameOver
        gameDelegate?.gameSceneGameOver()
    }
}

extension GameScene {
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
