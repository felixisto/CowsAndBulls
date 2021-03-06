//
//  NetworkObserver.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 4.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

struct CommunicatorObserverValue
{
    weak var observer : CommunicatorObserver?
    
    init(_ observer: CommunicatorObserver)
    {
        self.observer = observer
    }
    
    var value : CommunicatorObserver? {
        get {
           return observer
        }
    }
}

protocol CommunicatorObserver: class
{
    // Connection status
    func lostConnectionAttemptingToReconnect()
    func reconnect()
    func opponentQuit()
    func disconnect(error: String)
    
    // Host/Client scenes
    func beginConnect()
    func formallyConnected(data: CommunicatorInitialConnection)
    func failedToConnect()
    func timeout()
    
    // Game Setup scene
    func opponentPickedPlaySetup(guessWordLength: UInt, turnToGo: String)
    
    // Game Pick Word scene
    func opponentPickedPlaySession()
    func nextGame()
    
    // Game Play scene
    func opponentGuess(guess: String)
    func incorrectGuessResponse(response: String)
    func correctGuessResponse()
    func opponentChatMessage(message: String)
}
