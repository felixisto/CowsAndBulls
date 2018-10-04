//
//  NetworkObserver.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 4.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol NetworkObserver: class
{
    func beginConnect()
    
    func connect(data: CommunicatorInitialConnection)
    
    func failedToConnect()
    
    func lostConnectingAttemptingToReconnect()
    func reconnect()
    
    func disconnect()
    func disconnect(error: String)
}
