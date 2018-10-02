//
//  Communicator.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation
import Socket
import Dispatch

protocol CommunicatorDelegate: class
{
    func failedToConnect()
    
    func hostConnect()
    func listenerConnect()
    
    func end()
}

let CommunicatorDefaultPort : Int32 = 1337
let CommunicatorConnectTimeoutAttempts : UInt = 10
let CommunicatorConnectTimeoutDelay : Double = 1.0
let CommunicatorListenTimeoutDelay : Double = 0.25

let CommunicatorBufferSize = 4096
let CommunicatorQuitCommand = "QUIT"
let CommunicatorShutdownCommand = "SHUTDOWN"

class Communicator
{
    weak var delegate: CommunicatorDelegate?
    
    var socket: Socket?
    
    init()
    {
        self.delegate = nil
    }
    
    func create() throws
    {
        try socket = Socket.create()
        
        socket?.delegate = self
    }
    
    func destroy()
    {
        socket?.close()
        socket = nil
    }
    
    func startListening() throws
    {
        try self.socket?.listen(on: Int(CommunicatorDefaultPort))
        
        DispatchQueue.global(qos: .background).async {
            while true
            {
                guard let socket = self.socket else {
                    break
                }
                
                if self.delegate == nil
                {
                    break
                }
                
                do
                {
                    try self.socket = socket.acceptClientConnection()
                    
                    DispatchQueue.main.async {
                        self.delegate?.hostConnect()
                    }
                    
                    return
                }
                catch {}
                
                Thread.sleep(forTimeInterval: CommunicatorListenTimeoutDelay)
            }
        }
    }
    
    func connectTo(host: String)
    {
        DispatchQueue.global(qos: .background).async {
            for _ in 1...CommunicatorConnectTimeoutAttempts
            {
                guard let socket = self.socket else {
                    break
                }
                
                if self.delegate == nil
                {
                    break
                }
                
                do
                {
                    try socket.connect(to: host, port: CommunicatorDefaultPort, timeout: 10)
                    return
                }
                catch {}
                
                Thread.sleep(forTimeInterval: CommunicatorConnectTimeoutDelay)
            }
            
            self.delegate?.failedToConnect()
        }
    }
}

extension Communicator : SSLServiceDelegate
{
    func initialize(asServer: Bool) throws
    {
        
    }
    
    func deinitialize()
    {
        DispatchQueue.main.async {
            self.delegate?.end()
        }
    }
    
    func onAccept(socket: Socket) throws
    {
        print("onAccept")
    }
    
    func onConnect(socket: Socket) throws
    {
        DispatchQueue.main.async {
            self.delegate?.listenerConnect()
        }
    }
    
    func send(buffer: UnsafeRawPointer, bufSize: Int) throws -> Int
    {
        return bufSize
    }
    
    func recv(buffer: UnsafeMutableRawPointer, bufSize: Int) throws -> Int
    {
        return bufSize
    }
}
