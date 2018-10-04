//
//  PickRolePresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol PickRolePresenterDelegate : class
{
    func quit()
}

class PickRolePresenter : NSObject
{
    weak var delegate : PickRoleViewDelegate?
    
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

extension PickRolePresenter : PickRolePresenterDelegate
{
    func quit()
    {
        print("PickRolePresenter quit")
        
        communicator?.quit()
    }
}

extension PickRolePresenter : NetworkObserver
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
        print("PickRolePresenter lostConnectingAttemptingToReconnect!")
    }
    
    func reconnect()
    {
        print("PickRolePresenter reconnect!")
    }
    
    func disconnect()
    {
        print("PickRolePresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("PickRolePresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
}

