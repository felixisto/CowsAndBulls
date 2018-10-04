//
//  ClientPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol ClientPresenterDelegate : class
{
    func connect(hostAddress: String)
    func quit()
}

class ClientPresenter : NSObject
{
    weak var delegate : ClientViewDelegate?
    
    var communicator: CommunicatorClient?
    
    required init(communicator: CommunicatorClient? = CommunicatorClient())
    {
        self.communicator = communicator
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension ClientPresenter : ClientPresenterDelegate
{
    func connect(hostAddress: String)
    {
        print("ClientPresenter: attempting to connect to host \(hostAddress)...")
        
        // Attempt to connect
        do
        {
            try communicator?.create()
            communicator?.start(connectTo: hostAddress)
        }
        catch
        {
            print("ClientPresenter: failed to connect to partner! Error: \(error)")
            
            delegate?.connectionFailure(errorMessage: "Failed to connect to partner")
            
            return
        }
    }
    
    func quit()
    {
        print("ClientPresenter: quit.")
        
        communicator?.quit()
    }
}

extension ClientPresenter : NetworkObserver
{
    func beginConnect()
    {
        print("HostPresenter found a client and is trying to connect!")
        delegate?.connectionBegin()
    }
    
    func connect(data: CommunicatorInitialConnection)
    {
        print("ClientPresenter network connected!")
        delegate?.connectionSuccessful(communicator: communicator)
    }
    
    func failedToConnect()
    {
        print("ClientPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Could not find player")
    }
    
    func disconnect()
    {
        print("ClientPresenter disconnected!")
        delegate?.connectionFailure(errorMessage: "Disconnected")
    }
    
    func disconnect(error: String)
    {
        print("ClientPresenter disconnected!")
        delegate?.connectionFailure(errorMessage: error)
    }
}

