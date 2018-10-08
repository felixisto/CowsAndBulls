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
    func quit()
}

class GameplayPresenter : NSObject
{
    weak var delegate : GameplayViewDelegate?
    
    var communicator: Communicator?
    
    required init(communicator: Communicator, connectionData: CommunicatorInitialConnection)
    {
        self.communicator = communicator
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension GameplayPresenter : GameplayPresenterDelegate
{
    func quit()
    {
        print("GameplayPresenter quit")
        
        communicator?.quit()
    }
}

extension GameplayPresenter : NetworkObserver
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
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("GameplayPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentSendPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        
    }
    
    func opponentDidSendPlaySession(turnValue: UInt)
    {
        
    }
}
