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
    func startHostServer()
    func quit()
}

class HostPresenter : NSObject
{
    weak var delegate : HostViewDelegate?
    
    var communicator: CommunicatorHost?
    
    required init(communicator: CommunicatorHost? = CommunicatorHost())
    {
        self.communicator = communicator
        
        super.init()
        
        self.communicator?.attachObserver(observer: self, key: self.description)
    }
    
    deinit {
        self.communicator?.detachObserver(key: self.description)
    }
}

extension HostPresenter : HostPresenterDelegate
{
    func startHostServer()
    {
        print("HostPresenter: starting server...")
        
        // Start server
        do
        {
            try communicator?.start()
        }
        catch
        {
            print("HostPresenter: failed to start host service! Error: \(error)")
            
            delegate?.connectionFailure(errorMessage: "Failed to start host service")
            
            return
        }
    }
    
    func quit()
    {
        print("HostPresenter: quit")
        
        communicator?.stop()
    }
}

extension HostPresenter : CommunicatorObserver
{
    func beginConnect()
    {
        print("HostPresenter found a client and is trying to connect!")
        delegate?.connectionBegin()
    }
    
    func formallyConnected(data: CommunicatorInitialConnection)
    {
        print("HostPresenter network started server!")
        delegate?.connectionSuccessful(communicator: communicator, initialData: data)
        self.communicator?.detachObserver(key: self.description)
    }
    
    func failedToConnect()
    {
        print("HostPresenter failed start server!")
        delegate?.connectionFailure(errorMessage: "Could not find player")
    }
    
    func timeout()
    {
        print("HostPresenter failed to connect with client! Timeout!")
        delegate?.timeout()
    }
    
    func lostConnectionAttemptingToReconnect()
    {
        print("HostPresenter lostConnectingAttemptingToReconnect!")
    }
    
    func reconnect()
    {
        print("HostPresenter reconnect!")
    }
    
    func opponentQuit()
    {
        print("HostPresenter disconnect!")
        delegate?.connectionFailure(errorMessage: "Disconnect")
    }
    
    func disconnect(error: String)
    {
        print("HostPresenter disconnect!")
        delegate?.connectionFailure(errorMessage: error)
    }
    
    func opponentPickedPlaySetup(guessWordLength: UInt, turnToGo: String)
    {
        
    }
    
    func opponentPickedPlaySession()
    {
        
    }
    
    func opponentGuess(guess: String)
    {
        
    }
    
    func incorrectGuessResponse(response: String)
    {
        
    }
    
    func correctGuessResponse()
    {
        
    }
}
