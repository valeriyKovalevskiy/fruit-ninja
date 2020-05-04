//
//  MenuViewController.swift
//  WolfFruits
//
//  Created by валерий on 1/23/20.
//  Copyright © 2020 Juan Francisco Dorado Torres. All rights reserved.
//

import UIKit
import StoreKit

class MenuViewController: UIViewController {
    
    let kSurvivalMode = "kSurvivalMode"
    let kScoreMode = "kScoreMode"
    
    //MARK: - Outlets
    @IBOutlet weak var vibrationButton: UIButton!
    @IBOutlet weak var soundButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - Actions
    @IBAction func didTappedVibrationButton(_ sender: UIButton) {
        vibrationButton.isSelected = !sender.isSelected
        GameStorage.shared.vibration = vibrationButton.isSelected
    }
    
    @IBAction func didTappedSoundButton(_ sender: UIButton) {
        soundButton.isSelected = !sender.isSelected
        GameStorage.shared.sound = soundButton.isSelected
    }
    
    @IBAction func didTappedRateUsButton(_ sender: UIButton) {
        SKStoreReviewController.requestReview()
    }
    
    @IBAction func didTappedShareButton(_ sender: UIButton) {
        let text = "Let's play in this cool game..."
        let activityViewController =
        UIActivityViewController(activityItems: [text],
                                 applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func didTappedScoreModeButton(_ sender: UIButton) {
        GameStorage.shared.isSurvivalMode = false
    }
    
    
    @IBAction func didTappedSurvivalModeButton(_ sender: UIButton) {
        GameStorage.shared.isSurvivalMode = true
    }
}
