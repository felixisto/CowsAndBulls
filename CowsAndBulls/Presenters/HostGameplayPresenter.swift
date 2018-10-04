//
//  HostGameplayPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol HostGameplayPresenterDelegate : class
{
    func quit()
}

class HostGameplayPresenter : NSObject
{
    weak var delegate : HostGameplayViewDelegate?
    
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

extension HostGameplayPresenter : HostGameplayPresenterDelegate
{
    func quit()
    {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension HostGameplayPresenter : NetworkObserver
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
        print("HostGameplayPresenter lostConnectingAttemptingToReconnect!")
    }
    
    func reconnect()
    {
        print("HostGameplayPresenter reconnect!")
    }
    
    func disconnect()
    {
        print("HostGameplayPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("HostGameplayPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
}
