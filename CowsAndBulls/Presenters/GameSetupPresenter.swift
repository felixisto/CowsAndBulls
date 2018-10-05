//
//  GameSetupPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol GameSetupPresenterDelegate : class
{
    func start()
    func quit()
    
    func didSelectGuessWordCharacterCount(number: UInt)
    func pickAndSendGuessWorCharacterCountToOpponent()
    func guessWordCharacterCountMismatch()
    func guessWordCharacterCountMatch()
}

class GameSetupPresenter : NSObject
{
    weak var delegate : GameSetupViewDelegate?
    
    var communicator: Communicator?
    
    var connectionData: CommunicatorInitialConnection
    var selectedGuessWordCharacterCount: UInt
    var pickedGuessWordCharacterCount: Bool
    var opponentPickedGuessWordCharacterCount: UInt
    
    var rolePickerDelegate: GameSetupPickerViewDelegate?
    var rolePickerDataSource: GameSetupPickerViewDataSource?
    
    required init(communicator: Communicator, connectionData: CommunicatorInitialConnection)
    {
        self.communicator = communicator
        self.connectionData = connectionData
        self.selectedGuessWordCharacterCount = GameConstants.GuessWordCharacterCountMin
        self.pickedGuessWordCharacterCount = false
        self.opponentPickedGuessWordCharacterCount = 0
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
    
    private func updateGuessWordLengthSelection() -> Bool
    {
        // If we have selected a guess word length, compare
        if pickedGuessWordCharacterCount
        {
            return selectedGuessWordCharacterCount == opponentPickedGuessWordCharacterCount
        }
        
        // If we havent selected it, wait until selection
        return false
    }
}

extension GameSetupPresenter : GameSetupPresenterDelegate
{
    func start()
    {
        print("GameSetupPresenter start")
        
        delegate?.updateConnectionData(playerAddress: connectionData.otherPlayerAddress, playerName: connectionData.otherPlayerName, playerColor: connectionData.otherPlayerColor)
        
        self.rolePickerDataSource = GameSetupPickerViewDataSource(minNumber: GameConstants.GuessWordCharacterCountMin, maxNumber: GameConstants.GuessWordCharacterCountMax)
        self.rolePickerDelegate = GameSetupPickerViewDelegate(minNumber: GameConstants.GuessWordCharacterCountMin, maxNumber: GameConstants.GuessWordCharacterCountMax, actionDelegate: delegate as? GameSetupActionDelegate)
        
        delegate?.updateNumberOfCharactersPicker(dataSource: self.rolePickerDataSource, delegate: self.rolePickerDelegate)
    }
    
    func quit()
    {
        print("GameSetupPresenter quit")
        
        communicator?.quit()
    }
    
    func didSelectGuessWordCharacterCount(number: UInt)
    {
        print("GameSetupPresenter selected guess word character count \(number)")
        
        selectedGuessWordCharacterCount = number
    }
    
    func pickAndSendGuessWorCharacterCountToOpponent()
    {
        print("GameSetupPresenter sending guess word character count \(selectedGuessWordCharacterCount) to opponent")
        
        // If the opponent has already sent their character count to use, just compare
        if opponentPickedGuessWordCharacterCount != 0
        {
            if selectedGuessWordCharacterCount == opponentPickedGuessWordCharacterCount
            {
                // Send message to opponent
                communicator?.sendGuessWordLength(length: selectedGuessWordCharacterCount)
                
                // Match
                delegate?.guessWordCharacterCountMatch()
                
                return
            }
        }
        
        // Else, send the character count to opponent
        pickedGuessWordCharacterCount = true
        
        // Send message to opponent
        communicator?.sendGuessWordLength(length: selectedGuessWordCharacterCount)
    }
    
    func guessWordCharacterCountMismatch()
    {
        // Skip all of this, if the opponent guess word length is already zero
        guard opponentPickedGuessWordCharacterCount > 0 else {
            return
        }
        
        print("GameSetupPresenter selected guess word character does not match with opponent's selection")
        
        pickedGuessWordCharacterCount = false
        opponentPickedGuessWordCharacterCount = 0
        
        communicator?.sendGuessWordLength(length: 0)
    }
    
    func guessWordCharacterCountMatch()
    {
        // Skip all of this, if either mine or the opponent guess word length is zero
        guard selectedGuessWordCharacterCount == opponentPickedGuessWordCharacterCount && selectedGuessWordCharacterCount != 0 else {
            return
        }
        
        print("GameSetupPresenter selected guess word character match! Guess words will be \(selectedGuessWordCharacterCount) characters long!")
        
        delegate?.goToPickWord(communicator: communicator, withGuessWordLength: selectedGuessWordCharacterCount)
    }
}

extension GameSetupPresenter : NetworkObserver
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
        print("GameSetupPresenter lostConnectingAttemptingToReconnect!")
    }
    
    func reconnect()
    {
        print("GameSetupPresenter reconnect!")
    }
    
    func disconnect()
    {
        print("GameSetupPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("GameSetupPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentDidSelectGuessWordCharacterCount(number: UInt)
    {
        // If the given number is zero, then the opponent is disagreeing with the given guess character length
        guard number > 0 else {
            delegate?.guessWordCharacterCountMismatch()
            return
        }
        
        print("GameSetupPresenter opponent selected guess word length \(number)!")
        
        opponentPickedGuessWordCharacterCount = number
        
        delegate?.opponentDidSelectGuessWordCharacterCount(number: opponentPickedGuessWordCharacterCount)
        
        // If we have picked a guess word length, we may go to the next screen or we may tell the opponent that we are disagreeing
        if pickedGuessWordCharacterCount
        {
            // Match
            if updateGuessWordLengthSelection()
            {
                delegate?.guessWordCharacterCountMatch()
            }
            // Mismatch
            else
            {
                delegate?.guessWordCharacterCountMismatch()
            }
        }
    }
    
    func opponentDidSendPlaySession(turnValue: UInt)
    {
        
    }
}

