//
//  CommunicatorWriter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 18.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation
import SwiftSocket

protocol CommunicatorWriterDelegate : class
{
    func pingRefresh()
}

class CommunicatorWriter
{
    weak var delegate: CommunicatorWriterDelegate?
    
    var active: Bool
    
    let socket: TCPClient
    
    init(socket: TCPClient)
    {
        self.active = false
        self.socket = socket
    }
    
    func begin()
    {
        if !active
        {
            active = true
            
            onBegin()
        }
    }
    
    func stop()
    {
        active = false
    }
    
    private func onBegin()
    {
        loopPing()
    }
    
    public func send(data: String)
    {
        let _ = socket.send(string: data)
    }
}

extension CommunicatorWriter
{
    private func loopPing()
    {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + CommunicatorReaderPingInterval, execute: {
            if !self.active
            {
                return
            }
            
            // Ping other end
            let pingMessage = CommunicatorMessage.createWriteMessage(command: CommunicatorCommands.PING.rawValue)
            self.send(data: pingMessage!.getData())
            
            // Refresh ping
            DispatchQueue.main.async {
                self.delegate?.pingRefresh()
            }
            
            self.loopPing()
        })
    }
}

