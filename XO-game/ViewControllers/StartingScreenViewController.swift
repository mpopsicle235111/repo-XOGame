//
//  StartingScreenViewController.swift
//  XO-game
//
//  Created by Anton Lebedev on 29.03.2022.
//  Copyright © 2022 plasmon. All rights reserved.
//

import UIKit

class StartingScreenViewController: UIViewController {
    

  
    @IBOutlet weak var ticTacToeNameLabel: UILabel!
    @IBOutlet weak var selectYourOpponentLabel: UILabel!
    @IBOutlet weak var selectGameTypeLabel: UILabel!
    
    @IBAction func startGameButton(_ sender: UIButton) {
        performSegue(withIdentifier: "startGameSegue", sender: sender)
    }
    
    @IBOutlet weak var opponentSelectionControl: UISegmentedControl!
    
    private var selectedOpponentSelectionStrategy: OpponentSelectionStrategy {
        switch self.opponentSelectionControl.selectedSegmentIndex {
        case 0:
            return .computer
        case 1:
            return .player
        default:
            return .computer
        }
    }
    
    @IBOutlet weak var gameTypeSelectionControl: UISegmentedControl!
    
    private var selectedGameTypeSelectionStrategy: GameTypeSelectionStrategy {
        switch self.gameTypeSelectionControl.selectedSegmentIndex {
        case 0:
            return .regular
        case 1:
            return .fiveDraw
        default:
            return .regular
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if segue.identifier == "startGameSegue" {
                 guard let destinationVC = segue.destination
                     as? GameViewController else { return }
                
                     destinationVC.selectedOpponentSelectionStrategy = self.selectedOpponentSelectionStrategy
                     destinationVC.selectedGameTypeSelectionStrategy = self.selectedGameTypeSelectionStrategy
                     
                 }
             }
        
      

    }
 

