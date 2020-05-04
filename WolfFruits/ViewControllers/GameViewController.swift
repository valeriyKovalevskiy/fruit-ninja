//
//  GameViewController.swift
//  SwiftyNinja
//
//  Created by Juan Francisco Dorado Torres on 02/12/19.
//  Copyright © 2019 Juan Francisco Dorado Torres. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    var gameScene: GameScene? = nil
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
        
        if let scene = GKScene(fileNamed: "GameScene") {
            if let sceneNode = scene.rootNode as! GameScene? {
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
    
    @IBAction func didTappedPauseButton(_ sender: UIButton) {
        pauseButton.isSelected = !sender.isSelected
        GameStorage.shared.isPaused = pauseButton.isSelected
        gameScene?.trackGameIsPaused()
    }
    
    @IBAction func didTappedMenuButton(_ sender: UIButton) {
        gameScene?.stopBackgroundMusic()
        navigationController?.popViewController(animated: true)
    }
}

extension GameViewController: GameSceneDelegate {
    func updateScoreLabel() {
        scoreLabel.text = "\(GameStorage.shared.score)"
    }
    
    func gameSceneGameOver() {
        pauseButton.isHidden = true
        menuButton.isHidden = true
        self.performSegue(withIdentifier: kGameOverSegue, sender: nil)
    }
}

extension GameViewController: GameOverViewControllerDelegate {
    func gameOverViewControllerDidTapMenu() {
        gameScene?.stopBackgroundMusic()
        navigationController?.popViewController(animated: true)
    }
    
    func gameOverViewControllerDidTapRestart() {
        pauseButton.isHidden = false
        menuButton.isHidden = false
        gameScene?.gamePhase = .ready
        gameScene?.introLabel.isHidden = false
    }
}
