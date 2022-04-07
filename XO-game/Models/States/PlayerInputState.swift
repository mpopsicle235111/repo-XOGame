//
//  PlayerInputState.swift
//  XO-game
//
//  Created by Anton Lebedev on 26.03.2022.
//  Copyright © 2022 plasmon. All rights reserved.
//

import Foundation


/// The game has three states: eithe the first player places a mark, either the second player places a mark, either the game step is over
public protocol GameState {
    /// isCompleted checks, is the change of state is finalized
    var isCompleted: Bool { get }
    /// begin makes the playing field ready
    func begin()
    /// addMark is self-explanatory
    func addMark(at position: GameboardPosition)
}


public class PlayerInputState: GameState {
    //When the state is initialized, it is not over yet
    public private(set) var isCompleted = false
    public let player: Player
    
    private(set) weak var gameViewController: GameViewController?
    //Gameboard stores the positions of the marks already placed
    private(set) weak var gameboard: Gameboard?
    private(set) weak var gameboardView: GameboardView?
    
    init(player: Player, gameViewController: GameViewController, gameboard: Gameboard, gameboardView: GameboardView) {
            self.player = player
            self.gameViewController = gameViewController
            self.gameboard = gameboard
            self.gameboardView = gameboardView
    }
    
    /// Begin and set default values for player
    public func begin() {
        switch self.player {
        case .first:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = false
            self.gameViewController?.secondPlayerTurnLabel.isHidden = true
        case .second:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = true
            self.gameViewController?.secondPlayerTurnLabel.isHidden = false
        case .computerAI:
            self.gameViewController?.firstPlayerTurnLabel.isHidden = true
            self.gameViewController?.secondPlayerTurnLabel.isHidden = false
        }
            self.gameViewController?.winnerLabel.isHidden = true
    }
    
    public func addMark(at position: GameboardPosition) { guard let gameboardView = self.gameboardView, gameboardView.canPlaceMarkView(at: position) else { return }
        
        let markView: MarkView
        
        
        //First player places X, second player places O
        switch self.player {
        case .first:
            markView = XView()
        case .second:
            markView = OView()
        case .computerAI:
            markView = OView()
        }

        self.gameboard?.setPlayer(self.player, at: position)
        
        self.gameboardView?.placeMarkView(markView, at: position)
        
        self.isCompleted = true
    }

}
