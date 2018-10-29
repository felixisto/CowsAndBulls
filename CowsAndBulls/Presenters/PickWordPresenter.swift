//
//  PickWordPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol PickWordPresenterDelegate : class
{
    func start()
    func quit()
    
    func goToGameplayScreen(guessWord: String)
}

class PickWordPresenter : NSObject
{
    weak var delegate : PickWordViewDelegate?
    
    var communicator: Communicator?
    
    var connectionData: CommunicatorInitialConnection
    
    let guessWordLength: UInt
    var turnToGo: GameTurn
    
    var guessWordPicked: String
    var turnValue: UInt
    
    var opponentHasPickedGuessWord: Bool
    
    var waitingForNextGame: Bool
    
    required init(communicator: Communicator, connectionData: CommunicatorInitialConnection, guessWordLength: UInt, turnToGo: GameTurn)
    {
        self.communicator = communicator
        self.connectionData = connectionData
        
        self.guessWordLength = guessWordLength
        self.turnToGo = turnToGo
        
        self.guessWordPicked = ""
        self.turnValue = 0
        
        self.opponentHasPickedGuessWord = false
        
        self.waitingForNextGame = false
        
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
    
    private func prepareForNewGame()
    {
        self.guessWordPicked = ""
        self.turnValue = 0
        
        self.opponentHasPickedGuessWord = false
        
        self.turnToGo = self.turnToGo.nextTurn()
    }
}

extension PickWordPresenter : PickWordPresenterDelegate
{
    func start()
    {
        delegate?.updateConnectionData(playerAddress: connectionData.otherPlayerAddress, playerName: connectionData.otherPlayerName, playerColor: connectionData.otherPlayerColor)
        
        delegate?.updateEnterXCharacterWord(length: guessWordLength)
    }
    
    func quit()
    {
        print("PickWordPresenter quit")
        
        communicator?.sendQuitMessage()
        
        communicator?.stop()
    }
    
    func goToGameplayScreen(guessWord: String)
    {
        guard !waitingForNextGame else {
            return
        }
        
        guard guessWord.count == guessWordLength else {
            return
        }
        
        // Guess word must not have repeating symbols
        if !PickWordPresenter.guessWordIsValid(guessWord: guessWord)
        {
            delegate?.invalidGuessWord(error: "Guess word must be made of non-repeating digit characters")
            return
        }
        
        guessWordPicked = guessWord
        
        // If opponent has also picked word, then lets play
        if opponentHasPickedGuessWord
        {
            print("PickWordPresenter play with guess word \(guessWord)")
            
            let gameSession = GameSession(firstToGo: turnToGo == .first, guessWord: guessWord)
            
            delegate?.goToGameplayScreen(communicator: communicator, connectionData: connectionData, gameSession: gameSession)
            
            waitingForNextGame = true
        }
        else
        {
            print("PickWordPresenter picked guess word \(guessWord)")
        }
        
        communicator?.sendAlertPickedGuessWordMessage()
    }
}

extension PickWordPresenter : CommunicatorObserver
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
        print("PickWordPresenter lostConnectingAttemptingToReconnect!")
        delegate?.lostConnectingAttemptingToReconnect()
    }
    
    func reconnect()
    {
        print("PickWordPresenter reconnect!")
        delegate?.reconnect()
    }
    
    func opponentQuit()
    {
        print("PickWordPresenter failed to connect!")
        delegate?.connectionFailure()
    }
    
    func disconnect(error: String)
    {
        print("PickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentPickedPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        
    }
    
    func opponentPickedPlaySession()
    {
        guard !waitingForNextGame else {
            return
        }
        
        guard !opponentHasPickedGuessWord else
        {
            return
        }
        
        // Skip if opponent has picked guess word
        if opponentHasPickedGuessWord
        {
            return
        }
        
        print("PickWordPresenter opponent picked guess word!")
        
        opponentHasPickedGuessWord = true
        
        delegate?.setOpponentStatus(status: "Opponent picked a guess word!")
        
        // If we have picked word too, play
        if guessWordPicked.count > 0
        {
            goToGameplayScreen(guessWord: guessWordPicked)
        }
    }
    
    func nextGame()
    {
        guard waitingForNextGame else
        {
            return
        }
        
        print("PickWordPresenter opponent is calling for next game!")
        
        waitingForNextGame = false
        
        prepareForNewGame()
        
        delegate?.nextGame()
    }
    
    func opponentGuess(guess: String)
    {
        
    }
    
    func incorrectGuessResponse(response: String)
    {
        
    }
    
    func correctGuessResponse()
    {
        
    }
    
    func opponentChatMessage(message: String)
    {
        
    }
}
