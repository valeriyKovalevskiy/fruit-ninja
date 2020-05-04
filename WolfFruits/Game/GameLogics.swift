//
//  GameLogics.swift

import UIKit

func randomCGFloat(_ lowerLimit: CGFloat, _ upperLimit: CGFloat) -> CGFloat {
    lowerLimit + CGFloat(arc4random()) / CGFloat(UInt32.max) * (upperLimit - lowerLimit)
}

//score same as phyra
protocol GameSceneDelegate: class {
    func gameSceneGameOver()
    func updateScoreLabel()
}

enum GamePhase {
    case ready
    case inPlay
    case gameOver
}
