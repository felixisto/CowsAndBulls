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

enum CommunicatorReaderState
{
    case inactive, active, reading
}

protocol CommunicatorReaderDelegate : class
{
    func ping()
    func pingRefresh()
    
    func greetingsMessageReceived(parameter: String)
    func messageReceived(command: String, parameter: String)
}

class CommunicatorReader
{
    weak var delegate: CommunicatorReaderDelegate?
    
    var state: CommunicatorReaderState = .inactive
    
    let socket: TCPClient
    
    var data: CommunicatorMessage
    
    init(socket: TCPClient)
    {
        self.socket = socket
        self.data = CommunicatorMessage.createBufferMessage()
    }
    
    func getState() -> CommunicatorReaderState
    {
        return state
    }
    
    func begin()
    {
        if state == .inactive
        {
            print("CommunicatorReader begin")
            
            state = .active
            
            loop()
        }
    }
    
    func stop()
    {
        if state != .inactive
        {
            print("CommunicatorReader stop")
            
            state = .inactive
        }
    }
}

extension CommunicatorReader
{
    private func loop()
    {
        DispatchQueue.global(qos: .background).async {
            if self.state == .inactive
            {
                return
            }
            
            // Read output from socket
            self.state = .reading
            
            if let bytes = self.socket.read(Int(CommunicatorMessageLength), timeout: CommunicatorReaderReadTimeout)
            {
                if let receivedData = String(bytes: bytes, encoding: .utf8)
                {
                    self.data.append(string: receivedData)
                }
            }
            
            self.state = .active
            
            // Message was received
            if self.data.isFullyWritten()
            {
                let command = self.data.getCommand()
                let parameter = self.data.getParameter()
                
                // Message received
                DispatchQueue.main.async {
                    // Upon receiving greetings, start the loop ping functionality
                    if CommunicatorCommand(rawValue: command) == .GREETINGS
                    {
                        self.loopPing()
                        
                        self.delegate?.greetingsMessageReceived(parameter: parameter)
                        
                        return
                    }
                    
                    // Ping received
                    if CommunicatorCommand(rawValue: command) == .PING
                    {
                        self.delegate?.ping()
                        
                        return
                    }
                    
                    // Message received
                    self.delegate?.messageReceived(command: command, parameter: parameter)
                }
                
                // Reset
                self.data.clear()
            }
            
            self.loop()
        }
    }
    
    private func loopPing()
    {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + CommunicatorReaderPingInterval, execute: {
            if self.state == .inactive
            {
                return
            }
            
            // Ping other end
            let pingMessage = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.PING.rawValue)
            
            let _ = self.socket.send(string: pingMessage!.getData())
            
            // Refresh ping
            DispatchQueue.main.async {
                self.delegate?.pingRefresh()
            }
            
            self.loopPing()
        })
    }
}
