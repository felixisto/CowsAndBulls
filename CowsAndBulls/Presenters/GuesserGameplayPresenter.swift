//
//  GuesserGameplayPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol GuesserGameplayPresenterDelegate : class
{
    func quit()
}

class GuesserGameplayPresenter : NSObject
{
    weak var delegate : GuesserGameplayViewDelegate?
    
    var communicator: Communicator?
    
    required init(communicator: Communicator)
    {
        self.communicator = communicator
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension GuesserGameplayPresenter : GuesserGameplayPresenterDelegate
{
    func quit()
    {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension GuesserGameplayPresenter : NetworkObserver
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
        print("GuesserGameplayPresenter lostConnectingAttemptingToReconnect!")
    }
    
    func reconnect()
    {
        print("GuesserGameplayPresenter reconnect!")
    }
    
    func disconnect()
    {
        print("GuesserGameplayPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("GuesserGameplayPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
}
