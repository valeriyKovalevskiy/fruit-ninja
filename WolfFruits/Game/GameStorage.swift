//
//  GameStorage.swift

import UIKit

class GameStorage: NSObject {
    let kGameScore = "kGameScore"
    let kGameSurvivalModeBestScore = "kGameSurvivalModeBestScore"
    let kGameScoreModeBestScore = "kGameScoreModeBestScore"
    let kGameVibration = "kGameVibaration"
    let kGameSound = "kGameSound"
    let kGameStopped = "kGameStopped"
    let kGameMode = "kGameMode"
    
    
    static let shared = GameStorage()
    
    var isPaused: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kGameStopped)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: kGameStopped)
        }
    }
    
    var isSurvivalMode: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kGameMode)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: kGameMode)
        }
    }

    
    var score: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kGameScore)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: kGameScore)
        }
    }
    
    var survivalModeBestScore: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kGameSurvivalModeBestScore)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: kGameSurvivalModeBestScore)
        }
    }
    
    var scoreModeBestScore: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: kGameScoreModeBestScore)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: kGameScoreModeBestScore)
        }
    }

    
    
    var vibration: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kGameVibration)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: kGameVibration)
        }
    }
    
    var sound: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: kGameSound)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: kGameSound)
        }
    }
    
}
