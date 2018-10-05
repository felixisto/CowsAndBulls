//
//  NetworkObserver.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 4.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol NetworkObserver: class
{
    // Connection status
    func lostConnectingAttemptingToReconnect()
    func reconnect()
    func disconnect()
    func disconnect(error: String)
    
    // Host/Client scenes
    func beginConnect()
    func connect(data: CommunicatorInitialConnection)
    func failedToConnect()
    
    // Game Setup scene
    func opponentSendPlaySetup(guessWordLength: UInt, turnToGo: String)
    
    // Game Pick Word scene
    func opponentDidSendPlaySession(turnValue: UInt)
    
    // Game Play scene
    
}
