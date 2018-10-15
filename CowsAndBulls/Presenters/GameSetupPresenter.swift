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
    func didSelectTurnToGo(turnToGo: String)
    
    func pickCurrentPlaySetupAndSendToOpponent()
    func playSetupMismatchesOpponentPlayerSetup()
    func playSetupMatchesOpponentPlayerSetup()
}

class GameSetupPresenter : NSObject
{
    weak var delegate : GameSetupViewDelegate?
    
    var communicator: Communicator?
    
    var connectionData: CommunicatorInitialConnection
    var selectedGuessWordCharacterCount: UInt
    var selectedTurnToGo: GameTurn
    var sentRequestToOpponent: Bool
    var opponentPickedGuessWordCharacterCount: UInt
    var opponentPickedTurnToGo: GameTurn
    var opponentSentRequest: Bool
    
    var wordLengthPickerDelegate: GameSetupWordLengthPickerViewDelegate?
    var wordLengthPickerDataSource: GameSetupWordLengthPickerViewDataSource?
    var turnPickerDelegate: GameSetupTurnPickerViewDelegate?
    var turnPickerDataSource: GameSetupTurnPickerViewDataSource?
    
    required init(communicator: Communicator, connectionData: CommunicatorInitialConnection)
    {
        self.communicator = communicator
        self.connectionData = connectionData
        self.selectedGuessWordCharacterCount = GameConstants.GuessWordCharacterCountMin
        self.selectedTurnToGo = .first
        self.sentRequestToOpponent = false
        self.opponentPickedGuessWordCharacterCount = 0
        self.opponentPickedTurnToGo = .first
        self.opponentSentRequest = false
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
    
    private func opponentHasSameSetupParameters() -> Bool
    {
        return selectedGuessWordCharacterCount != 0 && selectedGuessWordCharacterCount == opponentPickedGuessWordCharacterCount && selectedTurnToGo != opponentPickedTurnToGo
    }
}

extension GameSetupPresenter : GameSetupPresenterDelegate
{
    func start()
    {
        print("GameSetupPresenter start")
        
        delegate?.updateConnectionData(playerAddress: connectionData.otherPlayerAddress, playerName: connectionData.otherPlayerName, playerColor: connectionData.otherPlayerColor)
        
        self.wordLengthPickerDataSource = GameSetupWordLengthPickerViewDataSource(minNumber: GameConstants.GuessWordCharacterCountMin, maxNumber: GameConstants.GuessWordCharacterCountMax)
        self.wordLengthPickerDelegate = GameSetupWordLengthPickerViewDelegate(minNumber: GameConstants.GuessWordCharacterCountMin, maxNumber: GameConstants.GuessWordCharacterCountMax, actionDelegate: delegate as? GameSetupActionDelegate)
        
        delegate?.updateNumberOfCharactersPicker(dataSource: wordLengthPickerDataSource, delegate: wordLengthPickerDelegate)
        
        self.turnPickerDataSource = GameSetupTurnPickerViewDataSource(values: [GameTurn.first.rawValue, GameTurn.second.rawValue])
        self.turnPickerDelegate = GameSetupTurnPickerViewDelegate(values: [GameTurn.first.rawValue, GameTurn.second.rawValue], actionDelegate: delegate as? GameSetupActionDelegate)
        
        delegate?.updateTurnToGoPicker(dataSource: turnPickerDataSource, delegate: turnPickerDelegate)
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
    
    func didSelectTurnToGo(turnToGo: String)
    {
        if let turn = GameTurn(rawValue: turnToGo)
        {
            print("GameSetupPresenter selected turn to go \(turnToGo)")
            
            selectedTurnToGo = turn
        }
    }
    
    func pickCurrentPlaySetupAndSendToOpponent()
    {
        print("GameSetupPresenter sending play setup to opponent with guess word length \(selectedGuessWordCharacterCount) and \(selectedTurnToGo.rawValue) turn value")
        
        // If the opponent has already sent their play setup, compare and we may agree go to the next screen right here
        if opponentSentRequest
        {
            if opponentHasSameSetupParameters()
            {
                sentRequestToOpponent = true
                
                // Send message to opponent
                communicator?.sendPlaySetupMessage(length: selectedGuessWordCharacterCount, turnToGo: selectedTurnToGo.rawValue)
                
                // Match
                delegate?.playSetupMatch()
            }
            else
            {
                // Mismatch
                delegate?.playSetupMismatch()
            }
            
            return
        }
        
        // Else, send the character count to opponent
        sentRequestToOpponent = true
        
        communicator?.sendPlaySetupMessage(length: selectedGuessWordCharacterCount, turnToGo: selectedTurnToGo.rawValue)
    }
    
    func playSetupMismatchesOpponentPlayerSetup()
    {
        // Skip all of this, if no requests have been sent by either side
        if !sentRequestToOpponent && !opponentSentRequest
        {
            return
        }
        
        print("GameSetupPresenter we disagree with the opponent game setup values! Try again")
        
        if !sentRequestToOpponent
        {
            communicator?.sendPlaySetupMessage(length: selectedGuessWordCharacterCount, turnToGo: selectedTurnToGo.rawValue)
        }
        
        sentRequestToOpponent = false
        opponentSentRequest = false
    }
    
    func playSetupMatchesOpponentPlayerSetup()
    {
        // Skip all of this, if either mine or the opponent guess word length is zero
        guard selectedGuessWordCharacterCount == opponentPickedGuessWordCharacterCount && selectedGuessWordCharacterCount != 0 else {
            return
        }
        
        print("GameSetupPresenter we have agreed with the opponent on the game setup values! Guess words will be \(selectedGuessWordCharacterCount) characters long and we are \(selectedTurnToGo.rawValue) to go!")
        
        delegate?.goToPickWord(communicator: communicator, connectionData: connectionData, guessWordLength: selectedGuessWordCharacterCount, turnToGo: selectedTurnToGo)
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
        delegate?.lostConnectingAttemptingToReconnect()
    }
    
    func reconnect()
    {
        print("GameSetupPresenter reconnect!")
        delegate?.reconnect()
    }
    
    func disconnect()
    {
        print("GameSetupPresenter failed to connect!")
        delegate?.connectionFailure()
    }
    
    func disconnect(error: String)
    {
        print("GameSetupPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentPickedPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        // Zero value means mismatch, always
        guard guessWordLength > 0 else {
            delegate?.playSetupMismatch()
            return
        }
        
        // We need a valid Turn value
        guard let opponentTurnToGo = GameTurn(rawValue: turnToGo) else {
            return
        }
        
        print("GameSetupPresenter opponent selected guess word length \(guessWordLength)!")
        
        opponentSentRequest = true
        opponentPickedGuessWordCharacterCount = guessWordLength
        opponentPickedTurnToGo = opponentTurnToGo
        
        delegate?.updateOpponentPlaySetup(guessWordLength: opponentPickedGuessWordCharacterCount, turnToGo: opponentPickedTurnToGo.rawValue)
        
        // If we have already sent our play setup to the opoonent, try to see if the parameters match here
        // We may go to the next screen here
        if sentRequestToOpponent
        {
            if opponentHasSameSetupParameters()
            {
                delegate?.playSetupMatch()
            }
            else
            {
                delegate?.playSetupMismatch()
            }
        }
    }
    
    func opponentPickedPlaySession()
    {
        
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

