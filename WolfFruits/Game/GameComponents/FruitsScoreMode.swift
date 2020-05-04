//
//  Fruits.swift

import SpriteKit

class FruitScoreMode: SKNode {
    let fruitArray = ["fruit_1", "fruit_2", "fruit_3", "fruit_4", "fruit_5", "fruit_6", "fruit_7"]
    
    override init() {
        super.init()
        
        var enemy = ""
        if randomCGFloat(0, 1) < 0.9 { //шанс получить бомбу 10% выбираем рандомное число от 0 до 1
            let n = Int(arc4random_uniform(UInt32(fruitArray.count))) + 1
            name = "fruit_\(n)"
            enemy = name ?? "fruit_1"
        } else {
            name = "bomb"
            enemy = "bomb"
        }
        let target = SKSpriteNode(imageNamed: enemy)
        target.size = CGSize(width: 70, height: 70)
        addChild(target)
        
        physicsBody = SKPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
