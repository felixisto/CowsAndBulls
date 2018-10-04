//
//  HostPickWordPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol HostPickWordPresenterDelegate : class
{
    func quit()
}

class HostPickWordPresenter : NSObject
{
    weak var delegate : HostPickWordViewDelegate?
    
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

extension HostPickWordPresenter : HostPickWordPresenterDelegate
{
    func quit()
    {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension HostPickWordPresenter : NetworkObserver
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
        print("HostPickWordPresenter lostConnectingAttemptingToReconnect!")
    }
    
    func reconnect()
    {
        print("HostPickWordPresenter reconnect!")
    }
    
    func disconnect()
    {
        print("HostPickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("HostPickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
}
