//
//  GameplayPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol GameplayPresenterDelegate : class
{
    func start()
    func quit()
    
    func guess(guess: String)
}

class GameplayPresenter : NSObject
{
    weak var delegate : GameplayViewDelegate?
    
    var communicator: Communicator?
    
    let initialConnectionData: CommunicatorInitialConnection
    var gameSession: GameSession
    
    required init(communicator: Communicator, connectionData: CommunicatorInitialConnection, gameSession: GameSession)
    {
        self.communicator = communicator
        self.initialConnectionData = connectionData
        self.gameSession = gameSession
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension GameplayPresenter : GameplayPresenterDelegate
{
    func start()
    {
        let playerLabel = String("\(initialConnectionData.otherPlayerName) (\(initialConnectionData.otherPlayerAddress))")
        delegate?.setupUI(guessCharacters: gameSession.guessWordNumberOfCharacters, playerLabel: playerLabel, myGuessWord: gameSession.guessWordAsString, firstToGo: gameSession.isMyTurn())
    }
    
    func quit()
    {
        print("GameplayPresenter quit")
        
        communicator?.terminate()
    }
    
    func guess(guess: String)
    {
        print("GameplayPresenter sending guess to opponent \(guess)")
        
        gameSession.guessAttempt(guess: guess)
        
        communicator?.sendGuessMessage(guess: guess)
    }
}

extension GameplayPresenter : CommunicatorObserver
{
    func beginConnect()
    {
        
    }
    
    func connect(data: CommunicatorInitialConnection)
    {
        
    }
    
    func failedToConnect()
    {
        
    }
    
    func timeout()
    {
        
    }
    
    func lostConnectingAttemptingToReconnect()
    {
        print("GameplayPresenter lostConnectingAttemptingToReconnect!")
        delegate?.lostConnectingAttemptingToReconnect()
    }
    
    func reconnect()
    {
        print("GameplayPresenter reconnect!")
        delegate?.reconnect()
    }
    
    func disconnect()
    {
        print("GameplayPresenter failed to connect!")
        delegate?.connectionFailure()
    }
    
    func disconnect(error: String)
    {
        print("GameplayPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentPickedPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        
    }
    
    func opponentPickedPlaySession()
    {
        
    }
    
    func opponentGuess(guess: String)
    {
        do
        {
            let result = try gameSession.opponentIsGuessing(guess: guess)
            
            print("GameplayPresenter received a guess message from opponent \(guess).")
            
            delegate?.setCurrentTurnValue(turn: gameSession.getGameTurn(), myTurn: gameSession.isMyTurn())
            
            delegate?.updateLog(string: gameSession.getLog(opponentName: initialConnectionData.otherPlayerName))
            
            // If not correctly guessed, send a guess response back
            if !result.hasSuccessfullyGuessed()
            {
                print("GameplayPresenter send guess response back to opponent")
                
                communicator?.sendGuessResponseMessage(response: result.messageWithGuess)
            }
            // Opponent correctly guessed, send message, show loser screen
            else
            {
                print("GameplayPresenter opponent correctly guessed our word! You lose!")
                
                communicator?.sendGuessCorrectMessage()
                
                delegate?.defeat(myGuessWord: guess)
            }
        }
        catch
        {
            
        }
    }
    
    func guessResponse(response: String)
    {
        do
        {
            try gameSession.opponentGuessResponse(response: response)
            
            print("GameplayPresenter opponent guess response \(response)")
            
            delegate?.setCurrentTurnValue(turn: gameSession.getGameTurn(), myTurn: gameSession.isMyTurn())
            
            delegate?.updateLog(string: gameSession.getLog(opponentName: initialConnectionData.otherPlayerName))
        }
        catch
        {
            
        }
    }
    
    func correctGuess()
    {
        do
        {
            try gameSession.endGame()
            
            print("GameplayPresenter opponent says you correctly guessed! You win!")
            
            // Show winners screen
            delegate?.victory(opponentGuessWord: gameSession.getLastGuessAttempt())
        }
        catch
        {
            
        }
    }
}
