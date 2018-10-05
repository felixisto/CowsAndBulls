//
//  Communicator.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation
import SwiftSocket

let CommunicatorDefaultPort : Int32 = 1337

let CommunicatorHostConnectTimeout : Double = 3.0
let CommunicatorHostUpdateDelay : Double = 0.25

let CommunicatorClientConnectTimeout : Double = 10.0

let CommunicatorMessageEndingTag = "$%\n!#!"

let CommunicatorPingInterval : Double = 0.1
let CommunicatorPingDelayMinimum : Double = 0.3
let CommunicatorPingTimeout : Double = 30.0

// Generic interface that allows you to interact with either host communicator or client communicator
protocol Communicator
{
    func isConnected() -> Bool
    
    func attachObserver(observer: NetworkObserver?, key: String)
    func detachObserver(key: String)
    
    func quit()
    
    func sendMessageToClient(message: String)
    func sendActionMessage(message: String)
    func sendQuitMessage()
    
    func sendPlaySetupMessage(length: UInt, turnToGo: String)
    func sendAlertPickedGuessWord()
    func sendGuessWordAlertAndTurnValue(turnValue: UInt)
}

struct CommunicatorInitialConnection
{
    let dateConnected: Date
    let otherPlayerAddress: String
    let otherPlayerName: String
    let otherPlayerColor: UIColor
    
    init(dateConnected: Date, otherPlayerAddress: String, otherPlayerName: String, otherPlayerColor: UIColor)
    {
        self.dateConnected = dateConnected
        self.otherPlayerAddress = otherPlayerAddress
        self.otherPlayerName = otherPlayerName
        self.otherPlayerColor = otherPlayerColor
    }
}

class CommunicatorHost : Communicator
{
    private var observers: [String : NetworkObserver] = [:]
    
    private var server: TCPServer?
    private var client: TCPClient?
    
    private var isConnectedToClient = false
    
    private var clientMessage : String = ""
    
    private var lastPingFromClient : Date?
    private var lastPingRetryingToConnect : Bool
    
    init()
    {
        lastPingRetryingToConnect = false
    }
    
    deinit {
        destroy()
    }
    
    func isConnected() -> Bool
    {
        return isConnectedToClient
    }
    
    func create() throws
    {
        guard let address = LocalIPAddress.get() else {
            throw CommunicatorError.invalidIPAddress
        }
        
        server = TCPServer(address: address, port: CommunicatorDefaultPort)
    }
    
    func destroy()
    {
        server?.close()
        client?.close()
        
        server = nil
        client = nil
        
        isConnectedToClient = false
        
        clientMessage = ""
        
        lastPingFromClient = nil
        lastPingRetryingToConnect = false
        
        observers.removeAll()
    }
    
    func quit()
    {
        sendQuitMessage()
        destroy()
    }
    
    func start()
    {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let communicator = self else {
                return
            }
            
            guard let server = communicator.server else {
                return
            }
            
            switch server.listen()
            {
            case .success:
                while true
                {
                    guard let _ = self else {
                        return
                    }
                    
                    guard let _ = communicator.server else {
                        return
                    }
                    
                    if communicator.client == nil
                    {
                        if let client = server.accept(timeout: Int32(CommunicatorHostConnectTimeout))
                        {
                            communicator.onBeginConnection(client: client)
                        }
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    for observer in communicator.observers
                    {
                        observer.value.failedToConnect()
                    }
                }
            }
        }
    }
    
    private func connectionLoop()
    {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let communicator = self else
            {
                return
            }
            
            guard let client = communicator.client else
            {
                return
            }
            
            // Read output from server into the property @serverMessage
            if let bytes = client.read(1, timeout: 10)
            {
                if let string = String(bytes: bytes, encoding: .utf8)
                {
                    communicator.clientMessage.append(string)
                }
            }
            
            // Check if these variables are valid, again
            guard let _ = self else
            {
                return
            }
            
            guard let _ = communicator.client else
            {
                return
            }
            
            // Full message received?
            if communicator.clientMessage.hasSuffix(CommunicatorMessageEndingTag)
            {
                let message = communicator.clientMessage.replacingOccurrences(of: CommunicatorMessageEndingTag, with: "")
                communicator.clientMessage = ""
                
                if let command = CommunicatorCommands.extractCommand(fromMessage: message)
                {
                    switch command
                    {
                    case .GREETINGS:
                        if !communicator.isConnectedToClient
                        {
                            communicator.onConnect(client: client, command: command, message: message)
                        }
                    case .QUIT:
                        if communicator.isConnectedToClient
                        {
                            communicator.onClientQuit()
                        }
                    case .PING:
                        if communicator.isConnectedToClient
                        {
                            communicator.lastPingFromClient = Date()
                            print("\(communicator.lastPingFromClient!) Ping from client")
                        }
                    case .PLAYSETUP:
                        if communicator.isConnectedToClient
                        {
                            let param1 = CommunicatorCommands.extractFirstParameter(command: command, message: message)
                            let param2 = CommunicatorCommands.extractSecondParameter(command: command, message: message)
                            
                            if param1 != nil && param2 != nil
                            {
                                if let wordLength = UInt(param1!)
                                {
                                    // Observers notification
                                    DispatchQueue.main.async {
                                        for observer in communicator.observers
                                        {
                                            observer.value.opponentSendPlaySetup(guessWordLength: wordLength, turnToGo: param2!)
                                        }
                                    }
                                }
                            }
                        }
                    case .PLAYSESSION:
                        if communicator.isConnectedToClient
                        {
                            if let parameter = CommunicatorCommands.extractFirstParameter(command: command, message: message)
                            {
                                if let turnValue = UInt(parameter)
                                {
                                    // Observers notification
                                    DispatchQueue.main.async {
                                        for observer in communicator.observers
                                        {
                                            observer.value.opponentDidSendPlaySession(turnValue: turnValue)
                                        }
                                    }
                                }
                            }
                        }
                    default:
                        print("Bad command \(command.rawValue)!")
                    }
                }
            }
            
            // Repeat
            communicator.connectionLoop()
        }
    }
    
    private func pingLoop()
    {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + CommunicatorPingInterval, execute: { [weak self] in
            guard let communicator = self else
            {
                return
            }
            
            guard let client = communicator.client else
            {
                return
            }
            
            if communicator.isConnectedToClient
            {
                let _ = client.send(string: CommunicatorCommands.constructPingMessage())
                
                // Check if server has been pinging back
                if let lastPingFromClient = communicator.lastPingFromClient
                {
                    let currentDate = Date()
                    
                    let timeElapsedSinceLastPing = Double(currentDate.timeIntervalSince(lastPingFromClient))
                    
                    let noPingReceivedShort = timeElapsedSinceLastPing >= CommunicatorPingDelayMinimum
                    
                    // Lost connection
                    if noPingReceivedShort
                    {
                        let pingTimeout = timeElapsedSinceLastPing >= CommunicatorPingTimeout
                        
                        // Timeout, end the connection
                        if pingTimeout
                        {
                            communicator.onDisconnected()
                            return
                        }
                        else
                        {
                            // Try to reconnect
                            if !communicator.lastPingRetryingToConnect
                            {
                                communicator.lostConnectionAttemptingToReconnect()
                            }
                        }
                    }
                    // Reconnect, if connection was lost
                    else
                    {
                        if communicator.lastPingRetryingToConnect
                        {
                            communicator.reconnect()
                        }
                    }
                }
                else
                {
                    print("Communicator last ping date was not initialized properly")
                    
                    communicator.onDisconnected()
                    
                    return
                }
            }
            
            // Repeat
            communicator.pingLoop()
        })
    }
}

// Observers
extension CommunicatorHost
{
    public func attachObserver(observer: NetworkObserver?, key: String)
    {
        if let obs = observer
        {
            self.observers[key] = obs
        }
    }
    
    public func detachObserver(key: String)
    {
        self.observers.removeValue(forKey: key)
    }
}

// State changes
extension CommunicatorHost
{
    private func onBeginConnection(client: TCPClient)
    {
        print("CommunicatorHost: sending greetings to client: \(client.address):\(client.port), waiting to be greeted back on \(Date())")
        
        self.client = client
        self.clientMessage = ""
        self.lastPingFromClient = Date()
        
        // Send greetings to client
        let _ = client.send(string: CommunicatorCommands.constructGreetingsMessage())
        
        // Start loops
        connectionLoop()
        pingLoop()
        
        // Observers notification
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.beginConnect()
            }
        }
    }
    
    private func onConnect(client: TCPClient, command: CommunicatorCommand, message: String)
    {
        print("CommunicatorHost: connected with client: \(client.address):\(client.port) on \(Date())")
        
        isConnectedToClient = true
        
        // Observers notification
        DispatchQueue.main.async {
            if let client = self.client
            {
                let dateConnected = Date()
                let otherPlayerAddress = client.address
                let otherPlayerName = CommunicatorCommands.extractFirstParameter(command: command, message: message) ?? "Unknown"
                let otherPlayerColor = UIColor.red
                
                for observer in self.observers
                {
                    observer.value.connect(data: CommunicatorInitialConnection(dateConnected: dateConnected, otherPlayerAddress: otherPlayerAddress, otherPlayerName: otherPlayerName, otherPlayerColor: otherPlayerColor))
                }
            }
        }
    }
    
    private func onClientQuit()
    {
        print("CommunicatorHost: client quit on \(Date())")
        
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.disconnect()
            }
            
            self.destroy()
        }
    }
    
    private func onDisconnected()
    {
        print("CommunicatorHost: disconnected on \(Date())")
        
        // Copy the observers here
        let observers = self.observers
        
        // Destroy
        destroy()
        
        // Delegate notification
        DispatchQueue.main.async {
            for observer in observers
            {
                observer.value.disconnect(error: "Disconnected")
            }
        }
    }
    
    private func lostConnectionAttemptingToReconnect()
    {
        print("CommunicatorHost: lost connection attempting to reconnect on \(Date())")
        
        lastPingRetryingToConnect = true
        
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.lostConnectingAttemptingToReconnect()
            }
        }
    }
    
    private func reconnect()
    {
        print("CommunicatorHost: reconnected")
        
        lastPingRetryingToConnect = false
        
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.reconnect()
            }
        }
    }
}

// Send message to other end
extension CommunicatorHost
{
    public func sendMessageToClient(message: String)
    {
        guard let client = self.client else {
            return
        }
        
        let _ = client.send(string: message)
        
        print("CommunicatorHost: sending chat message to client")
    }
    
    public func sendActionMessage(message: String)
    {
        guard let client = self.client else {
            return
        }
        
        let _ = client.send(string: message)
        
        print("CommunicatorHost: sending action message to client")
    }
    
    public func sendQuitMessage()
    {
        guard let client = self.client else {
            return
        }
        
        let _ = client.send(string: CommunicatorCommands.constructQuitMessage())
        
        print("CommunicatorHost: sending quit message to client")
    }
    
    public func sendPlaySetupMessage(length: UInt, turnToGo: String)
    {
        guard let client = self.client else {
            return
        }
        
        let _ = client.send(string: CommunicatorCommands.constructPlaySetupMessage(length: length, turnToGo: turnToGo))
        
        print("CommunicatorHost: sending guess word length message to client")
    }
    
    public func sendAlertPickedGuessWord()
    {
        guard let client = self.client else {
            return
        }
        
        let _ = client.send(string: CommunicatorCommands.constructPickedGuessWordMessage())
        
        print("CommunicatorHost: sending notification to client that a guess word has been picked")
    }
    
    public func sendGuessWordAlertAndTurnValue(turnValue: UInt)
    {
        guard let client = self.client else {
            return
        }
        
        let _ = client.send(string: CommunicatorCommands.constructPlaySessionMessage(turnValue: turnValue))
        
        print("CommunicatorHost: sending notification to client that a guess word has been picked")
    }
}

class CommunicatorClient : Communicator
{
    private var observers: [String : NetworkObserver] = [:]
    
    private var socket: TCPClient?
    
    private var isConnectedToServer: Bool = false
    
    private var serverMessage: String = ""
    
    private var lastPingFromServer : Date?
    private var lastPingRetryingToConnect : Bool
    
    init()
    {
        lastPingRetryingToConnect = false
    }
    
    deinit {
        destroy()
    }
    
    func isConnected() -> Bool
    {
        return isConnectedToServer
    }
    
    func create() throws
    {
        
    }
    
    func destroy()
    {
        socket?.close()
        socket = nil
        
        isConnectedToServer = false
        
        serverMessage = ""
        
        lastPingFromServer = nil
        lastPingRetryingToConnect = false
        
        observers.removeAll()
    }
    
    func quit()
    {
        sendQuitMessage()
        destroy()
    }
    
    func start(connectTo host: String)
    {
        socket = TCPClient(address: host, port: CommunicatorDefaultPort)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let communicator = self else {
                return
            }
            
            guard let socket = communicator.socket else {
                return
            }
            
            var success = false
            
            for _ in 0...Int(CommunicatorClientConnectTimeout)
            {
                if socket.connect(timeout: 1000).isSuccess
                {
                    communicator.onBeginConnection()
                    
                    success = true
                    break
                }
            }
            
            guard let _ = self else {
                return
            }
            
            guard let _ = communicator.socket else {
                return
            }
            
            if !success
            {
                DispatchQueue.main.async {
                    for observer in communicator.observers
                    {
                        observer.value.disconnect(error: "Disconnected")
                    }
                }
            }
        }
    }
    
    private func connectionLoop()
    {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let communicator = self else
            {
                return
            }
            
            guard let socket = communicator.socket else
            {
                return
            }
            
            // Read output from server into the property @serverMessage
            if let bytes = socket.read(1, timeout: 10)
            {
                if let string = String(bytes: bytes, encoding: .utf8)
                {
                    self?.serverMessage.append(string)
                }
            }
            
            // Check if these variables are valid, again
            guard let _ = self else
            {
                return
            }
            
            guard let _ = communicator.socket else
            {
                return
            }
            
            // Full message received?
            if communicator.serverMessage.hasSuffix(CommunicatorMessageEndingTag)
            {
                let message = communicator.serverMessage.replacingOccurrences(of: CommunicatorMessageEndingTag, with: "")
                communicator.serverMessage = ""
                
                if let command = CommunicatorCommands.extractCommand(fromMessage: message)
                {
                    switch command
                    {
                    case .GREETINGS:
                        if !communicator.isConnectedToServer
                        {
                            communicator.onConnected(command: command, message: message)
                        }
                    case .QUIT:
                        if communicator.isConnectedToServer
                        {
                            communicator.onServerQuit()
                        }
                    case .PING:
                        if communicator.isConnectedToServer
                        {
                            communicator.lastPingFromServer = Date()
                            print("\(communicator.lastPingFromServer!) Ping from server")
                        }
                    case .PLAYSETUP:
                        if communicator.isConnectedToServer
                        {
                            let param1 = CommunicatorCommands.extractFirstParameter(command: command, message: message)
                            let param2 = CommunicatorCommands.extractSecondParameter(command: command, message: message)
                            
                            if param1 != nil && param2 != nil
                            {
                                if let wordLength = UInt(param1!)
                                {
                                    // Observers notification
                                    DispatchQueue.main.async {
                                        for observer in communicator.observers
                                        {
                                            observer.value.opponentSendPlaySetup(guessWordLength: wordLength, turnToGo: param2!)
                                        }
                                    }
                                }
                            }
                        }
                    case .PLAYSESSION:
                        if communicator.isConnectedToServer
                        {
                            if let parameter = CommunicatorCommands.extractFirstParameter(command: command, message: message)
                            {
                                if let turnValue = UInt(parameter)
                                {
                                    // Observers notification
                                    DispatchQueue.main.async {
                                        for observer in communicator.observers
                                        {
                                            observer.value.opponentDidSendPlaySession(turnValue: turnValue)
                                        }
                                    }
                                }
                            }
                        }
                    default:
                        print("Bad command \(command.rawValue)!")
                    }
                }
            }
            
            // Repeat
            communicator.connectionLoop()
        }
    }
    
    private func pingLoop()
    {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + CommunicatorPingInterval, execute: { [weak self] in
            guard let communicator = self else
            {
                return
            }
            
            guard let socket = communicator.socket else
            {
                return
            }
            
            // Ping server
            if communicator.isConnectedToServer
            {
                let _ = socket.send(string: CommunicatorCommands.constructPingMessage())
                
                // Check if server has been pinging back
                if let lastPingFromServer = communicator.lastPingFromServer
                {
                    let currentDate = Date()
                    
                    let timeElapsedSinceLastPing = Double(currentDate.timeIntervalSince(lastPingFromServer))
                    
                    let noPingReceivedShort = timeElapsedSinceLastPing >= CommunicatorPingDelayMinimum
                    
                    // Lost connection
                    if noPingReceivedShort
                    {
                        let pingTimeout = timeElapsedSinceLastPing >= CommunicatorPingTimeout
                        
                        // Timeout, end the connection
                        if pingTimeout
                        {
                            communicator.onDisconnected()
                            return
                        }
                        else
                        {
                            // Try to reconnect
                            if !communicator.lastPingRetryingToConnect
                            {
                                communicator.lostConnectionAttemptingToReconnect()
                            }
                        }
                    }
                        // Reconnect, if connection was lost
                    else
                    {
                        if communicator.lastPingRetryingToConnect
                        {
                            communicator.reconnect()
                        }
                    }
                }
                else
                {
                    print("Communicator last ping date was not initialized properly")
                    
                    communicator.onDisconnected()
                    
                    return
                }
            }
            
            // Repeat
            communicator.pingLoop()
        })
    }
}

// Observers
// These methods are not thread safe
// Call them from main thread only
extension CommunicatorClient
{
    public func attachObserver(observer: NetworkObserver?, key: String)
    {
        if let obs = observer
        {
            self.observers[key] = obs
        }
    }
    
    public func detachObserver(key: String)
    {
        self.observers.removeValue(forKey: key)
    }
}

// State changes
extension CommunicatorClient
{
    private func onBeginConnection()
    {
        print("CommunicatorClient: beginning new connection with server on \(Date())")
        
        self.serverMessage = ""
        self.lastPingFromServer = Date()
        
        // Start loops
        connectionLoop()
        pingLoop()
        
        // Observers notification
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.beginConnect()
            }
        }
    }
    
    private func onConnected(command: CommunicatorCommand, message: String)
    {
        print("CommunicatorClient: received greetings, sending greetings message to server on \(Date())")
        
        isConnectedToServer = true
        
        // Send greetings BACK to server
        let _ = socket?.send(string: CommunicatorCommands.constructGreetingsMessage())
        
        // Observers notification
        DispatchQueue.main.async {
            if let socket = self.socket
            {
                let dateConnected = Date()
                let otherPlayerAddress = socket.address
                let otherPlayerName = CommunicatorCommands.extractFirstParameter(command: command, message: message) ?? "Unknown"
                let otherPlayerColor = UIColor.red
                
                for observer in self.observers
                {
                    observer.value.connect(data: CommunicatorInitialConnection(dateConnected: dateConnected, otherPlayerAddress: otherPlayerAddress, otherPlayerName: otherPlayerName, otherPlayerColor: otherPlayerColor))
                }
            }
        }
    }
    
    private func onServerQuit()
    {
        print("CommunicatorClient: server quit on \(Date())")
        
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.disconnect()
            }
            
            self.destroy()
        }
    }
    
    private func onDisconnected()
    {
        print("CommunicatorClient: disconnected on \(Date())")
        
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.disconnect(error: "Disconnected")
            }
            
            self.destroy()
        }
    }
    
    private func lostConnectionAttemptingToReconnect()
    {
        print("CommunicatorClient: lost connection attempting to reconnect on \(Date())")
        
        lastPingRetryingToConnect = true
        
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.lostConnectingAttemptingToReconnect()
            }
        }
    }
    
    private func reconnect()
    {
        print("CommunicatorClient: reconnected on \(Date())")
        
        lastPingRetryingToConnect = false
        
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.reconnect()
            }
        }
    }
}

// Send message to other end
extension CommunicatorClient
{
    public func sendMessageToClient(message: String)
    {
        guard let socket = self.socket else {
            return
        }
        
        let _ = socket.send(string: message)
        
        print("CommunicatorClient: sending chat message to server")
    }
    
    public func sendActionMessage(message: String)
    {
        guard let socket = self.socket else {
            return
        }
        
        let _ = socket.send(string: message)
        
        print("CommunicatorClient: sending action message to server")
    }
    
    public func sendQuitMessage()
    {
        guard let socket = self.socket else {
            return
        }
        
        let _ = socket.send(string: CommunicatorCommands.constructQuitMessage())
        
        print("CommunicatorClient: sending quit message to server")
    }
    
    public func sendPlaySetupMessage(length: UInt, turnToGo: String)
    {
        guard let socket = self.socket else {
            return
        }
        
        let _ = socket.send(string: CommunicatorCommands.constructPlaySetupMessage(length: length, turnToGo: turnToGo))
        
        print("CommunicatorClient: sending guess word length message to server")
    }
    
    public func sendAlertPickedGuessWord()
    {
        guard let socket = self.socket else {
            return
        }
        
        let _ = socket.send(string: CommunicatorCommands.constructPickedGuessWordMessage())
        
        print("CommunicatorClient: sending notification to client that a guess word has been picked")
    }
    
    public func sendGuessWordAlertAndTurnValue(turnValue: UInt)
    {
        guard let socket = self.socket else {
            return
        }
        
        let _ = socket.send(string: CommunicatorCommands.constructPlaySessionMessage(turnValue: turnValue))
        
        print("CommunicatorClient: sending notification to client that a guess word has been picked")
    }
}

// Utilities
extension CommunicatorClient
{
    func hostURL(host: String) -> URL?
    {
        guard let url = URL(string: String("http://\(host):\(CommunicatorDefaultPort)")) else {
            return nil
        }
        
        return url
    }
}
