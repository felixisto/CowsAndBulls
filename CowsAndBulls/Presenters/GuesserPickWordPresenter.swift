//
//  GuesserPickWordPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol GuesserPickWordPresenterDelegate : class
{
    func quit()
}

class GuesserPickWordPresenter : NSObject
{
    weak var delegate : GuesserPickWordViewDelegate?
    
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

extension GuesserPickWordPresenter : GuesserPickWordPresenterDelegate
{
    func quit()
    {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension GuesserPickWordPresenter : NetworkObserver
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
    
    func disconnect()
    {
        print("GuesserPickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("GuesserPickWordPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: error)
    }
}
