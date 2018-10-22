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
    
    static public func guessWordIsValid(guessWord: String) -> Bool
    {
        var symbols : [Int] = []
        
        for c in guessWord
        {
            if let symbol = Int(String(c))
            {
                if symbols.contains(symbol)
                {
                    return false
                }
                else
                {
                    symbols.append(symbol)
                }
            }
            else
            {
                return false
            }
        }
        
        return true
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
        
        communicator?.sendQuitMessage()
        
        communicator?.stop()
    }
    
    func guess(guess: String)
    {
        if GameplayPresenter.guessWordIsValid(guessWord: guess)
        {
            print("GameplayPresenter sending guess to opponent \(guess)")
            
            gameSession.guessAttempt(guess: guess)
            
            communicator?.sendGuessMessage(guess: guess)
        }
        else
        {
            
        }
    }
}

extension GameplayPresenter : CommunicatorObserver
{
    func beginConnect()
    {
        
    }
    
    func formallyConnected(data: CommunicatorInitialConnection)
    {
        
    }
    
    func failedToConnect()
    {
        
    }
    
    func timeout()
    {
        
    }
    
    func lostConnectionAttemptingToReconnect()
    {
        print("GameplayPresenter lostConnectingAttemptingToReconnect!")
        delegate?.lostConnectingAttemptingToReconnect()
    }
    
    func reconnect()
    {
        print("GameplayPresenter reconnect!")
        delegate?.reconnect()
    }
    
    func opponentQuit()
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
                
                communicator?.sendGuessIncorrectResponseMessage(response: result.messageWithGuess)
            }
            // Opponent correctly guessed, send message, show loser screen
            else
            {
                print("GameplayPresenter opponent correctly guessed our word! You lose!")
                
                communicator?.sendGuessCorrectResponseMessage()
                
                delegate?.defeat(myGuessWord: guess)
            }
        }
        catch
        {
            
        }
    }
    
    func incorrectGuessResponse(response: String)
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
    
    func correctGuessResponse()
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
