//
//  Lifes.swift

import SpriteKit

class Hearts: SKNode {
    var heartArray = [SKSpriteNode]()
    var heartCount = Int()
    
    let blackHeart = SKTexture(imageNamed: "heartBlack")
    let redHeart = SKTexture(imageNamed: "heartRed")
    
    init(num: Int = 0) {
        super.init()
        
        heartCount = num
        
        for i in 0..<num {
            let heart = SKSpriteNode(imageNamed: "heartRed")
            heart.size = CGSize(width: 40, height: 40)
            heart.position.x = -CGFloat(i)*50
            addChild(heart)
            heartArray.append(heart)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(num: Int) {
        guard num <= heartCount else { return }
        heartArray[heartArray.count - num].texture = blackHeart
    }
    
    func reset() {
        for heart in heartArray {
            heart.texture = redHeart
        }
    }
}
