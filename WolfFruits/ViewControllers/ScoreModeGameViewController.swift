//
//  GameViewController.swift

import UIKit
import SpriteKit
import GameplayKit

class ScoreModeGameViewController: UIViewController {
        
    @IBOutlet weak var scoreModePauseButton: UIButton!
    @IBOutlet weak var scoreModeMenuButton: UIButton!
    @IBOutlet weak var scoreModeScoreLabel: UILabel!
    
    var gameScene: ScoreModeGameScene? = nil
    override var prefersStatusBarHidden: Bool { return true }
    override var shouldAutorotate: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let scene = GKScene(fileNamed: "ScoreModeGameScene") {
            if let sceneNode = scene.rootNode as! ScoreModeGameScene? {
                gameScene = sceneNode
                sceneNode.gameDelegate = self
                sceneNode.size = view.bounds.size
                sceneNode.scaleMode = .resizeFill

                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    view.ignoresSiblingOrder = true
                }
                gameScene?.gamePhase = .ready
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "kGameOverSegue" {
            let vc = segue.destination as! GameOverViewController
            vc.delegate = self
        }
    }
    
    @IBAction func didTappedScoreModePauseButton(_ sender: UIButton) {
        scoreModePauseButton.isSelected = !sender.isSelected
        GameStorage.shared.isPaused = scoreModePauseButton.isSelected
        gameScene?.trackGameIsPaused()
        
    }
    
    @IBAction func didTappedScoreModeMenuButton(_ sender: UIButton) {
        gameScene?.stopBackgroundMusic()
        navigationController?.popViewController(animated: true)
    }
}

extension ScoreModeGameViewController: GameSceneDelegate {
    func updateScoreLabel() {
        scoreModeScoreLabel.text = "\(GameStorage.shared.score)" // отдельный счет в юд
    }
    
    func gameSceneGameOver() {
        scoreModePauseButton.isHidden = true
        scoreModeMenuButton.isHidden = true
        self.performSegue(withIdentifier: kGameOverSegue, sender: nil)
    }
}

extension ScoreModeGameViewController: GameOverViewControllerDelegate {
    func gameOverViewControllerDidTapMenu() {
        gameScene?.stopBackgroundMusic()
        navigationController?.popViewController(animated: true)
    }
    
    func gameOverViewControllerDidTapRestart() {
        scoreModePauseButton.isHidden = false
        scoreModeMenuButton.isHidden = false
        gameScene?.gamePhase = .ready
        gameScene?.introLabel.isHidden = false
    }
}
