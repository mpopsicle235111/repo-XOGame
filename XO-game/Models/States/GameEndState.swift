//
//  GameEndState.swift
//  XO-game
//
//  Created by Anton Lebedev on 27.03.2022.
//  Copyright © 2022 plasmon. All rights reserved.
//

import Foundation

public class GameEndedState: GameState {
    
    
    //The turn is not completed
    public var isCompleted = false
    //and some player is introduced
    public let winner: Player?
    
    //Then we weakly plug in our screen
    private(set) weak var gameViewController: GameViewController?
    
    //Then in init we put through the player and the ViewController
    init(winner: Player?, gameViewController: GameViewController?) {
        self.winner = winner
        self.gameViewController = gameViewController
    }
    
    //The state starts
    public func begin() {
        //The label is shown
        self.gameViewController?.winnerLabel.isHidden = false
        //We unpack the winner
        //If we can unpack the winner from optional, then
        //we assign the player to the label and declare him/her as winner
        if let winner = winner
        {
          self.gameViewController?.winnerLabel.text = self.winnerName(from: winner) + " wins!"
        
        //Otherwise we declare there is no winner
        //By some reason it does not work automatically, had to
        //implement a counter in GameViewController
        } else {
          self.gameViewController?.winnerLabel.text = "A draw: no winner..."
        }
        //Then we hide the two labels
        self.gameViewController?.firstPlayerTurnLabel.isHidden = true
        self.gameViewController?.secondPlayerTurnLabel.isHidden = true
    }
    
    //The state of making a turn is no longer used -
    //game ends, we do not need to add a mark anymore
    public func addMark(at position: GameboardPosition) { }
    
    //This func states, how do we display the winner
    private func winnerName(from winner: Player) -> String {
        switch winner {
        case .first: return "The first player (X)"
        case .second: return "The second player (O)"
        case .computerAI: return "Computer AI (O)"
        }
    }
    
}
