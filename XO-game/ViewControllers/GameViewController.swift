//
//  GameViewController.swift
//  XO-game
//
//  Created by Evgeny Kireev on 25/02/2019.
//  Copyright © 2019 plasmon. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet var gameboardView: GameboardView!
    @IBOutlet var firstPlayerTurnLabel: UILabel!
    @IBOutlet var secondPlayerTurnLabel: UILabel!
    @IBOutlet var winnerLabel: UILabel!
    @IBOutlet var restartButton: UIButton!
    
    private enum Player: CaseIterable {
        case first
        case second
        case computerAI
    }
    
    //Below are the three classes for State
    //This is a service which defines the winner
    //It receives gameboard (storage) with the game state
    private lazy var referee = Referee(gameboard: self.gameboard)
    //Gameboard stores the marks already placed
    private let gameboard = Gameboard()
    //If the state changes, we return to the initial state ("begin")
    //So the idea is to switch states between goToFirstState and goToNextState
    private var currentState: GameState! {
        didSet {
             self.currentState.begin()
        }
    }
    
    var selectedOpponentSelectionStrategy: OpponentSelectionStrategy = .computer
    var selectedGameTypeSelectionStrategy: GameTypeSelectionStrategy = .regular
    
    var drawCounter = 0
    var fiveCounterPlayer1 = 0
    var turnCounterPlayer2 = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.goToFirstState()
        gameboardView.onSelectPosition = { [weak self] position in
            guard let self = self else { return }
            self.currentState.addMark(at: position)
            
            //If the current step is complete, we start the next step
            if self.currentState.isCompleted {
                self.goToNextState()
                
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        //UIAlertController is a class that shows messages to user
        //Let's tell user the weird rules of this game
        //Otherwise the user can decide, that our app is not working
        //And we have to be concerned with user's satisfaction
        if selectedGameTypeSelectionStrategy == .fiveDraw {
            let alert = UIAlertController(title: "How to play 5-draw", message: "Player X places 5 marks and hopes to form a line of three marks. Then Player O places 5 marks and hopes to eliminate Player X's marks and form a line of three marks of his/her own. Then all marks are displayed and we see, who wins... A weird game)))", preferredStyle: .alert)
            //We create the special button for UIAlertcontroller
            let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            //and add this button to UIAlertcontroller
            alert.addAction(action)
            //Now we can show UIAlertController
            present(alert, animated: true, completion: nil)
        }
    }
    
    private func goToFirstState() {
         self.currentState = PlayerInputState(
            player: .first,
            gameViewController: self,
            gameboard: gameboard,
            gameboardView: gameboardView)
    }
    
    private func goToNextState() {
        
        //MARK: THE FIRST PART OF THE FORK: PLAY REGULAR TIC TAC TOE
        //At this fork we select, will it be a game of five, or a regular game
        if selectedGameTypeSelectionStrategy == .regular {
            
           //Referee checks the state of the game on each step
           if let winner = referee.determineWinner() {
                  currentState = GameEndedState(winner: winner, gameViewController: self)
                  return
           }
        
           //If the winner is not defined in 9 steps -> we have a draw
           //and proceed to GameEndedState
           drawCounter += 1
           if drawCounter == 9 {
               let winner = referee.determineWinner()
               currentState = GameEndedState(winner: winner, gameViewController: self)
               return
           }
        
         
                //Depending on the selected opponent's type, we select
                //different options in PlayerInputState
                //This part works, if opponent is another player
                if selectedOpponentSelectionStrategy == .player {
                   if let playerInputState = currentState as? PlayerInputState {
                       currentState = PlayerInputState(
                                player: playerInputState.player.next,
                                gameViewController: self,
                                gameboard: gameboard,
                                gameboardView: gameboardView)
                        }
                } else {
                    
                    //Depending on the selected opponent's type, we select
                    //different options in PlayerInputState
                    //This part works, if opponent is another player
                    if let playerInputState = currentState as? PlayerInputState { currentState = PlayerInputState(
                        player: playerInputState.player.next,
                              gameViewController: self,
                              gameboard: gameboard,
                              gameboardView: gameboardView)
                    }
                    //Change state again to change mark symbol
                    if let playerInputState = currentState as? PlayerInputState { currentState = PlayerInputState(
                            player: playerInputState.player.next,
                                  gameViewController: self,
                                  gameboard: gameboard,
                                  gameboardView: gameboardView)
                       
                            //Now calculate the position for computer to place mark
                            if let position = calculatePosition() {
                                playerInputState.addMark(at: position)
                             }
                        
                            //To check if we have exhausted all turns and have a draw
                            //let's increase the counter here
                            drawCounter += 1
                        
                            //Check, maybe the computer has won
                            if let winner = referee.determineWinner() {
                            currentState = GameEndedState(winner: winner, gameViewController: self)
                            return
                            }
                       }
                
                }
             
            
            
             //MARK: THE SECOND PART OF THE FORK (PLAY THE GAME OF FIVE)
             //if selectedGameTypeSelectionStrategy is set to .fiveDraw {
             //Here is the GameOfFive engine - the second part of the above fork
             } else {
                
                //The first player (X) places 5 marks
                fiveCounterPlayer1 += 1
                
                //When the first player has put 5 marks, it's second player's turn
                if fiveCounterPlayer1 == 5 {
                    
                      //Wipe the board
                      gameboardView.clear()
                    
                      //If we play versus a person, let the person place 5 marks
                      if selectedOpponentSelectionStrategy == .player {
                        
                         if let playerInputState = currentState as? PlayerInputState {
                             currentState = PlayerInputState(
                                      player: playerInputState.player.next,
                                      gameViewController: self,
                                      gameboard: gameboard,
                                      gameboardView: gameboardView)
                            
                            fiveCounterPlayer1 = 0
                            turnCounterPlayer2 += 1
                            
                            //Now the Player2's turn is over
                            if turnCounterPlayer2 >= 2 {
                            displayAllMarks()
                            turnCounterPlayer2 = 0
                            //Check for winner
                            if let winner = referee.determineWinner() {
                                    
                                //Check for a possible draw
                                if (referee.doesPlayerHaveWinningCombination(.first)) && (referee.doesPlayerHaveWinningCombination(.second)) {
                                
                                    self.winnerLabel.text = "A draw: no winner..."
                                    self.firstPlayerTurnLabel.isHidden = true
                                    self.secondPlayerTurnLabel.isHidden = true
                                    self.winnerLabel.isHidden = false
                                    return
                                } else {
                                
                                       currentState = GameEndedState(winner: winner, gameViewController: self)
                                       return
                                }
                            }
                            //If the winner is not defined in 10 steps -> we have a draw
                            //and proceed to GameEndedState
                            drawCounter += 1
                            
                            if drawCounter == 1 {
                                let winner = referee.determineWinner()
                                currentState = GameEndedState(winner: winner, gameViewController: self)
                                    return
                                }
                            
                             
                                
                            }
                         }
                        
                      //If we play against the computer, then the computer places 5 marks
                      } else if let playerInputState = currentState as? PlayerInputState {
                        currentState = PlayerInputState(
                                 player: playerInputState.player.next,
                                 gameViewController: self,
                                 gameboard: gameboard,
                                 gameboardView: gameboardView)
                        
                       fiveCounterPlayer1 = 0
                       turnCounterPlayer2 = 2
                        
                        //Now calculate the position for computer to place mark
                        if let position = calculatePosition() {
                            playerInputState.addMark(at: position)
                         }
                       
                       //Now the Player2's turn is over
                       if turnCounterPlayer2 >= 2 {
                       
                       displayAllMarks()
                       turnCounterPlayer2 = 0
                       //Check for winner
                       if let winner = referee.determineWinner() {
                        
                        //Check for possible draw
                        if (referee.doesPlayerHaveWinningCombination(.first)) && (referee.doesPlayerHaveWinningCombination(.second)) {
                            
                            self.winnerLabel.text = "A draw: no winner..."
                            self.firstPlayerTurnLabel.isHidden = true
                            self.secondPlayerTurnLabel.isHidden = true
                            self.winnerLabel.isHidden = false
                            return
                        } else {
                        
                                  currentState = GameEndedState(winner: winner, gameViewController: self)
                                  return
                           }
                       }
                        //If the winner is not defined in 10 steps -> we have a draw
                        //and proceed to GameEndedState
                        drawCounter += 1
                        
                        if drawCounter == 1 {
                            let winner = referee.determineWinner()
                            currentState = GameEndedState(winner: winner, gameViewController: self)
                            return
                        }
                        
                           
                       }
                    }
                    
                }
                
             }
    
   
    
    }
    
     private func calculatePosition() -> GameboardPosition? {
         var positions: [GameboardPosition] = []

         for column in 0...GameboardSize.columns - 1 {
             for row in 0...GameboardSize.rows - 1 {
                 let position = GameboardPosition(column: column, row: row)
                 if gameboardView!.canPlaceMarkView(at: position) {
                     positions.append(position)
                 }
             }
         }

         return positions.randomElement()
     }
    
    /// This func displays all marks after both players have made their respective turns
    private func displayAllMarks()  {

        for column in 0...GameboardSize.columns - 1 {
            for row in 0...GameboardSize.rows - 1 {
                let position = GameboardPosition(column: column, row: row)
               
                //For all Xses in our database we display Xses
                if gameboard.positions[position.column][position.row] == .first {
                if let playerInputState = currentState as? PlayerInputState { currentState = PlayerInputState(
                    player: .first,
                              gameViewController: self,
                              gameboard: gameboard,
                              gameboardView: gameboardView)
                   
                            
                            playerInputState.addMark(at: position)
                            
                    }
                }
                
                //For all Oses in our database we display Oses
                if gameboard.positions[position.column][position.row] == .second {
                if let playerInputState = currentState as? PlayerInputState { currentState = PlayerInputState(
                    player: .second,
                              gameViewController: self,
                              gameboard: gameboard,
                              gameboardView: gameboardView)
                   
                       
                            playerInputState.addMark(at: position)
                    }
                }
            }
        }
    }
    
    
    
    
    @IBAction func restartButtonTapped(_ sender: UIButton) {
        gameboard.clear()
        gameboardView.clear()
        
        drawCounter = 0
       
        goToFirstState()
        gameboardView.onSelectPosition = { [weak self] position in
                    guard let self = self else { return }
                    self.currentState.addMark(at: position)
                    if self.currentState.isCompleted {
                        self.goToNextState()
                    }
                }
      

    }
}

