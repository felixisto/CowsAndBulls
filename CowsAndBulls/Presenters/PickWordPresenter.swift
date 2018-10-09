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
    
    func tryToPlay(guessWord: String)
    
    func prepareForNewGame()
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
    var opponentPickedTurn: UInt
    
    required init(communicator: Communicator, connectionData: CommunicatorInitialConnection, guessWordLength: UInt, turnToGo: GameTurn)
    {
        self.communicator = communicator
        self.connectionData = connectionData
        
        self.guessWordLength = guessWordLength
        self.turnToGo = turnToGo
        
        self.guessWordPicked = ""
        self.turnValue = 0
        
        self.opponentHasPickedGuessWord = false
        self.opponentPickedTurn = 0
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension PickWordPresenter : PickWordPresenterDelegate
{
    func start()
    {
        delegate?.updateEnterXCharacterWord(length: guessWordLength)
    }
    
    func quit()
    {
        print("PickWordPresenter quit")
        
        communicator?.quit()
    }
    
    func tryToPlay(guessWord: String)
    {
        guard guessWord.count == guessWordLength else {
            return
        }
        
        // Guess word must not have repeating symbols
        var symbols : [Int] = []
        
        for c in guessWord
        {
            if let symbol = Int(String(c))
            {
                if symbols.contains(symbol)
                {
                    delegate?.invalidGuessWord(error: "Guess word must not contain same digit twice")
                    return
                }
                else
                {
                    symbols.append(symbol)
                }
            }
            else
            {
                delegate?.invalidGuessWord(error: "Guess word must contain only digits")
                return
            }
        }
        
        guessWordPicked = guessWord
        
        // If opponent has also picked word, then lets play
        if opponentHasPickedGuessWord
        {
            print("PickWordPresenter play with guess word \(guessWord)")
            
            delegate?.play(communicator: communicator, connectionData: connectionData, guessWord: guessWord, firstToGo: turnToGo == .first)
        }
        else
        {
            print("PickWordPresenter picked guess word \(guessWord)")
        }
        
        communicator?.sendPlaySessionMessage()
    }
    
    func prepareForNewGame()
    {
        self.guessWordPicked = ""
        self.turnValue = 0
        
        self.opponentHasPickedGuessWord = false
        self.opponentPickedTurn = 0
        
        self.turnToGo = self.turnToGo.nextTurn()
    }
}

extension PickWordPresenter : NetworkObserver
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
    
    func lostConnectingAttemptingToReconnect()
    {
        print("PickWordPresenter lostConnectingAttemptingToReconnect!")
        delegate?.lostConnectingAttemptingToReconnect()
    }
    
    func reconnect()
    {
        print("PickWordPresenter reconnect!")
        delegate?.reconnect()
    }
    
    func disconnect()
    {
        print("PickWordPresenter failed to connect!")
        delegate?.connectionFailure()
    }
    
    func disconnect(error: String)
    {
        print("PickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentSendPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        
    }
    
    func opponentDidSendPlaySession()
    {
        // Skip if opponent has picked guess word
        if opponentHasPickedGuessWord
        {
            return
        }
        
        print("PickWordPresenter opponent picked guess word!")
        
        opponentHasPickedGuessWord = true
        opponentPickedTurn = turnValue
        
        delegate?.setOpponentStatus(status: "Opponent picked a guess word")
        
        // If we have picked word too, play
        if guessWordPicked.count > 0
        {
            tryToPlay(guessWord: guessWordPicked)
        }
    }
    
    func opponentGuess(guess: String)
    {
        
    }
    
    func guessResponse(response: String)
    {
        
    }
    
    func correctGuess()
    {
        
    }
}
