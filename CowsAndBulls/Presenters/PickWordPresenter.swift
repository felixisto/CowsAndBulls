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
}

class PickWordPresenter : NSObject
{
    weak var delegate : PickWordViewDelegate?
    
    var communicator: Communicator?
    
    var connectionData: CommunicatorInitialConnection
    
    let guessWordLength: UInt
    
    var guessWordPicked: String
    var turnValue: UInt
    
    var opponentHasPickedGuessWord: Bool
    var opponentPickedTurn: UInt
    
    required init(communicator: Communicator, connectionData: CommunicatorInitialConnection, guessWordLength: UInt)
    {
        self.communicator = communicator
        self.connectionData = connectionData
        
        self.guessWordLength = guessWordLength
        
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
        
        guessWordPicked = guessWord
        
        // Generate turn value, used to decide which player will go first
        let ownIPAddress = LocalIPAddress.get()!
        
        let newTurnValue : UInt = 0
        //GameTurnRandom.generateTurnValue(currentTurnValue: turnValue, opponentTurnValue: opponentPickedTurn, currentIPAddress: connectionData.otherPlayerAddress, opponentIPAddress: connectionData.otherPlayerAddress)
        
        // If opponent has also picked word, then lets play
        if opponentHasPickedGuessWord
        {
            print("PickWordPresenter play with guess word \(guessWord) with turn value \(newTurnValue)")
            
            delegate?.play(communicator: communicator, connectionData: connectionData, withGuessWord: guessWord)
        }
        else
        {
            print("PickWordPresenter picked guess word \(guessWord)")
        }
        
        communicator?.sendGuessWordAlertAndTurnValue(turnValue: newTurnValue)
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
    }
    
    func reconnect()
    {
        print("PickWordPresenter reconnect!")
    }
    
    func disconnect()
    {
        print("PickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("PickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentSendPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        
    }
    
    func opponentDidSendPlaySession(turnValue: UInt)
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
}
