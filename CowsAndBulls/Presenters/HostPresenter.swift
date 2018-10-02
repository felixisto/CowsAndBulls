//
//  HostPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol HostPresenterDelegate : class
{
    func hostBegin()
}

class HostPresenter
{
    weak var delegate : HostViewDelegate?
    
    var communicator: Communicator?
    
    required init()
    {
        communicator = Communicator()
        communicator?.delegate = self
    }
}

extension HostPresenter : HostPresenterDelegate
{
    func hostBegin()
    {
        print("HostPresenter: opening socket...")
        
        // Start listening
        do
        {
            try communicator?.create()
            try communicator?.startListening()
        }
        catch
        {
            print("HostPresenter: failed to connect to partner! Error: \(error)")
            
            delegate?.connectionFailure(errorMessage: "Failed to connect to partner")
            
            return
        }
    }
}

extension HostPresenter : CommunicatorDelegate
{
    func failedToConnect()
    {
        print("HostPresenter failed to connect!")
        delegate?.connectionFailure(errorMessage: "Could not find player")
    }
    
    func hostConnect()
    {
        print("HostPresenter network connected!")
        delegate?.connectionSuccessful(communicator: communicator)
    }
    
    func listenerConnect()
    {
        
    }
    
    func end()
    {
        print("HostPresenter network end!")
        delegate?.connectionFailure(errorMessage: "Disconnected")
    }
}
