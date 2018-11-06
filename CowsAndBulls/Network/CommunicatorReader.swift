//
//  CommunicatorReader.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 11.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation
import SwiftSocket

let CommunicatorReaderPingInterval = 0.1
let CommunicatorReaderReadTimeout = 1

protocol CommunicatorReaderDelegate : class
{
    func ping()
    
    func greetingsMessageReceived(parameter: String)
    func messageReceived(command: String, parameter: String)
}

class CommunicatorReader
{
    weak var delegate: CommunicatorReaderDelegate?
    
    var active: Bool
    
    let socket: TCPClient
    
    var data: CommunicatorMessage
    
    init(socket: TCPClient)
    {
        self.active = false
        self.socket = socket
        self.data = CommunicatorMessage.createReadMessage()
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
        loop()
    }
    
    private func onReceivedGreetings(parameter: String)
    {
        self.delegate?.greetingsMessageReceived(parameter: parameter)
    }
    
    private func onPingReceived()
    {
        self.delegate?.ping()
    }
}

extension CommunicatorReader
{
    private func loop()
    {
        DispatchQueue.global(qos: .background).async {
            if !self.active
            {
                return
            }
            
            // If message is not fully written, read from socket
            if !self.data.isFullyWritten()
            {
                // Read output from socket
                var buffer : [Byte] = []
                
                while buffer.count != Int(CommunicatorMessageLength)
                {
                    if let newInfo = self.socket.read(1, timeout: CommunicatorReaderReadTimeout)
                    {
                        for byte in newInfo
                        {
                            buffer.append(byte)
                        }
                    }
                }
                
                self.data.append(buffer: buffer)
            }
            
            // Message was received
            if self.data.isFullyWritten()
            {
                let command = self.data.getCommand()
                let parameter = self.data.getParameter()
                
                // Message received
                DispatchQueue.main.async {
                    // Upon receiving greetings, start the loop ping functionality
                    if CommunicatorCommands(rawValue: command) == .GREETINGS
                    {
                        self.onReceivedGreetings(parameter: parameter)
                        
                        return
                    }
                    
                    // Ping received
                    if CommunicatorCommands(rawValue: command) == .PING
                    {
                        self.onPingReceived()
                        
                        return
                    }
                    
                    // Message received
                    self.delegate?.messageReceived(command: command, parameter: parameter)
                }
                
                // Clear the first filled message
                self.data.clearFirstFilledMessage()
            }
            
            // Repeat
            self.loop()
        }
    }
}
