//
//  GameOverViewController.swift

import UIKit
import GameKit

protocol GameOverViewControllerDelegate: class {
    func gameOverViewControllerDidTapMenu()
    func gameOverViewControllerDidTapRestart()
}

class GameOverViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var bestScoreLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    //MARK: - Properties
    weak var delegate: GameOverViewControllerDelegate?
    var score = 0
    var isAuthenticated: Bool? {
        didSet {
            if isAuthenticated != oldValue, isAuthenticated == true {
                UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
                UserDefaults.standard.synchronize()
            }
        }
    }
    func checkGameMode() {
		
        if GameStorage.shared.isSurvivalMode {
            score = GameStorage.shared.survivalModeBestScore
        } else {
            score = GameStorage.shared.scoreModeBestScore
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkGameMode()
        bestScoreLabel.text = "BEST SCORE: \(score)"
        backgroundView.alpha = 0.5
        isAuthenticated = UserDefaults.standard.object(forKey: "isAuthenticated") as? Bool
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - Actions
    @IBAction func didTappedRestartButton(_ sender: UIButton) {
        self.dismiss(animated:true) {
            self.delegate?.gameOverViewControllerDidTapRestart()
        }
    }
    
    @IBAction func didTappedMenuButton(_ sender: UIButton) {
        self.dismiss(animated:false) {
            self.delegate?.gameOverViewControllerDidTapMenu()
        }
    }
    
    @IBAction func didTappedShareButton(_ sender: UIButton) {
        let text = "Let's play in this cool game....."
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func didTappedLeaderboardButton(_ sender: UIButton) {
        reportScore()
    }
    
    //MARK: -  Methods
    private func reportScore() {
        authPlayerOnStart(false) { (success) in
            if success {
                self.reportScoreAndShowLeaderBoard()
            }
        }
    }
    
    private func authPlayerOnStart(_ onStart: Bool, block: @escaping (_ success: Bool) -> ()) {
        if onStart, isAuthenticated != true {
            block(false)
            return
        }
        if !onStart, isAuthenticated == true {
            block(true)
            return
        }
        
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { (controller, error) in
            if let currentController = controller {
                self.present(currentController, animated: true, completion: nil)
            } else {
                self.isAuthenticated = error == nil ? localPlayer.isAuthenticated : false
                block(localPlayer.isAuthenticated)
            }
        }
    }
    
    func reportScoreAndShowLeaderBoard() {
        let scoreReporter = GKScore(leaderboardIdentifier: kLeaderBoardId)
        scoreReporter.value = Int64(score)
        let scoreArray = [scoreReporter]
        GKScore.report(scoreArray, withCompletionHandler: nil)
        showGameCenterVC()
    }
    
    private func showGameCenterVC() {
        let gameCenterVC = GKGameCenterViewController()
        gameCenterVC.gameCenterDelegate = self as? GKGameCenterControllerDelegate
        present(gameCenterVC, animated: true, completion: nil)
    }
}
