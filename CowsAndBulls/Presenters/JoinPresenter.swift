//
//  JoinPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol JoinPresenterDelegate : class
{
    func connect(hostAddress: String)
}

class JoinPresenter
{
    weak var delegate : JoinViewDelegate?
    
    var communicator: Communicator?
    
    required init()
    {
        communicator = Communicator()
        communicator?.delegate = self
    }
}

extension JoinPresenter : JoinPresenterDelegate
{
    func connect(hostAddress: String)
    {
        print("JoinPresenter: attempting to connect to player \(hostAddress)")
        
        // Attempt to connect
        do
        {
            try communicator?.create()
            communicator?.connectTo(host: hostAddress)
        }
        catch
        {
            print("JoinPresenter: failed to connect to partner! Error: \(error)")
            
            delegate?.connectionFailure(errorMessage: "Failed to connect to partner")
            
            return
        }
    }
}

extension JoinPresenter : CommunicatorDelegate
{
    func failedToConnect()
    {
        print("JoinPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Could not find player")
    }
    
    func hostConnect()
    {
        
    }
    
    func listenerConnect()
    {
        print("JoinPresenter network connected!")
        delegate?.connectionSuccessful(communicator: communicator)
    }
    
    func end()
    {
        print("JoinPresenter network end!")
        delegate?.connectionFailure(errorMessage: "Disconnected")
    }
}

