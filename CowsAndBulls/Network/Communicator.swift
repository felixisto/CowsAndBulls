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
let CommunicatorHostBeginConnectTimeout : Double = 3.0
let CommunicatorHostUpdateDelay : Double = 0.1

let CommunicatorClientConnectTimeout : Double = 10.0
let CommunicatorClientBeginConnectTimeout : Double = 3.0

let CommunicatorPingInterval : Double = 0.1
let CommunicatorPingDelayMinimum : Double = 0.4
let CommunicatorPingTimeout : Double = 15.0

// Generic interface that allows you to interact with either host communicator or client communicator
protocol Communicator
{
    func isConnected() -> Bool
    
    func attachObserver(observer: CommunicatorObserver?, key: String)
    func detachObserver(key: String)
    
    func quit()
    
    func sendQuitMessage()
    func sendPlaySetupMessage(length: UInt, turnToGo: String)
    func sendAlertPickedGuessWordMessage()
    func sendPlaySessionMessage()
    func sendGuessMessage(guess: String)
    func sendGuessResponseMessage(response: String)
    func sendGuessCorrectMessage()
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
    private var observers: [String : CommunicatorObserverValue] = [:]
    
    private var server: TCPServer?
    private var client: TCPClient?
    private var reader: CommunicatorReader?
    
    private var isConnectedToClient = false
    
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
        reader?.stop()
        
        server = nil
        client = nil
        reader = nil
        
        isConnectedToClient = false
        
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
                        observer.value.value?.failedToConnect()
                    }
                }
            }
        }
    }
}

// Observers
extension CommunicatorHost
{
    public func attachObserver(observer: CommunicatorObserver?, key: String)
    {
        if let obs = observer
        {
            self.observers[key] = CommunicatorObserverValue(obs)
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
        self.reader = CommunicatorReader(socket: client)
        self.reader?.delegate = self
        self.reader?.begin()
        self.lastPingFromClient = Date()
        
        // Send greetings to client
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GREETINGS.rawValue, parameter: UserName().value)
        let _ = client.send(string: dataToSend!.getData())
        
        // Observers notification
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.value?.beginConnect()
            }
        }
        
        // Timeout
        // If a formal connection is not established in @CommunicatorHostBeginConnectTimeout seconds, terminate connection
        DispatchQueue.main.asyncAfter(deadline: .now() + CommunicatorHostBeginConnectTimeout, execute: { [weak self] in
            if let communicator = self
            {
                if !communicator.isConnectedToClient
                {
                    communicator.client?.close()
                    communicator.client = nil
                    communicator.reader = nil
                    communicator.lastPingFromClient = nil
                    
                    // Observers notification
                    DispatchQueue.main.async {
                        for observer in communicator.observers
                        {
                            observer.value.value?.timeout()
                        }
                    }
                }
            }
        })
    }
    
    private func onConnect(client: TCPClient, parameter: String)
    {
        print("CommunicatorHost: connected with client: \(client.address):\(client.port) on \(Date())")
        
        isConnectedToClient = true
        
        // Observers notification
        DispatchQueue.main.async {
            if let client = self.client
            {
                let dateConnected = Date()
                let otherPlayerAddress = client.address
                let otherPlayerName = parameter
                let otherPlayerColor = UIColor.red
                
                for observer in self.observers
                {
                    observer.value.value?.connect(data: CommunicatorInitialConnection(dateConnected: dateConnected, otherPlayerAddress: otherPlayerAddress, otherPlayerName: otherPlayerName, otherPlayerColor: otherPlayerColor))
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
                observer.value.value?.disconnect()
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
                observer.value.value?.disconnect(error: "Disconnected")
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
                observer.value.value?.lostConnectingAttemptingToReconnect()
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
                observer.value.value?.reconnect()
            }
        }
    }
}

// Send message to other end
extension CommunicatorHost
{
    public func sendQuitMessage()
    {
        guard let client = self.client else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.QUIT.rawValue)
        let _ = client.send(string: dataToSend!.getData())
        
        print("CommunicatorHost: sending quit message to client")
    }
    
    public func sendPlaySetupMessage(length: UInt, turnToGo: String)
    {
        guard let client = self.client else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.PLAYSETUP.rawValue, parameter1: String(length), parameter2: turnToGo)
        let _ = client.send(string: dataToSend!.getData())
        
        print("CommunicatorHost: sending play setup message to client")
    }
    
    public func sendAlertPickedGuessWordMessage()
    {
        guard let client = self.client else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.PLAYSESSION.rawValue)
        let _ = client.send(string:dataToSend!.getData())
        
        print("CommunicatorHost: sending alert picked guess word message to client")
    }
    
    public func sendPlaySessionMessage()
    {
        guard let client = self.client else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.PLAYSESSION.rawValue)
        let _ = client.send(string: dataToSend!.getData())
        
        print("CommunicatorHost: sending play session message to client")
    }
    
    func sendGuessMessage(guess: String)
    {
        guard let client = self.client else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GAMEGUESS.rawValue, parameter: guess)
        let _ = client.send(string: dataToSend!.getData())
        
        print("CommunicatorHost: sending guess message to client")
    }
    
    func sendGuessResponseMessage(response: String)
    {
        guard let client = self.client else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GAMEGUESSRESPONSE.rawValue, parameter: response)
        let _ = client.send(string: dataToSend!.getData())
        
        print("CommunicatorHost: sending guess response message to client")
    }
    
    func sendGuessCorrectMessage()
    {
        guard let client = self.client else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GAMECORRECTGUESS.rawValue, parameter: "")
        let _ = client.send(string: dataToSend!.getData())
        
        print("CommunicatorHost: sending guess correct message to client")
    }
}

// Reader delegates
extension CommunicatorHost : CommunicatorReaderDelegate
{
    func ping()
    {
        lastPingFromClient = Date()
        
        if lastPingRetryingToConnect
        {
            reconnect()
        }
        
        lastPingRetryingToConnect = false
    }
    
    func pingRefresh()
    {
        // Check if server has been pinging back
        if let lastPingFromClient = self.lastPingFromClient
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
                    onDisconnected()
                    return
                }
                else
                {
                    // Try to reconnect
                    if !lastPingRetryingToConnect
                    {
                        lostConnectionAttemptingToReconnect()
                    }
                }
            }
        }
        else
        {
            print("Communicator last ping date was not initialized properly")
            
            onDisconnected()
            
            return
        }
    }
    
    func greetingsMessageReceived(parameter: String)
    {
        guard self.client != nil else {
            return
        }
        
        if !isConnectedToClient
        {
            onConnect(client: self.client!, parameter: parameter)
        }
    }
    
    func messageReceived(command: String, parameter: String)
    {
        guard let cmd = CommunicatorCommand(rawValue: command) else {
            return
        }
        
        guard self.client != nil else {
            return
        }
        
        if !isConnectedToClient
        {
            return
        }
        
        switch cmd
        {
        case .QUIT:
            onClientQuit()
        case .PLAYSETUP:
            let parameters = parameter.split(separator: " ")
            
            guard parameters.count == 2 else {
                return
            }
            
            let param1 = parameters.first!.description
            let param2 = parameters[1].description
            
            if let wordLength = UInt(param1)
            {
                // Observers notification
                DispatchQueue.main.async {
                    for observer in self.observers
                    {
                        observer.value.value?.opponentPickedPlaySetup(guessWordLength: wordLength, turnToGo: param2)
                    }
                }
            }
        case .PLAYSESSION:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.opponentPickedPlaySession()
                }
            }
        case .GAMEGUESS:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.opponentGuess(guess: parameter)
                }
            }
        case .GAMEGUESSRESPONSE:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.guessResponse(response: parameter)
                }
            }
        case .GAMECORRECTGUESS:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.correctGuess()
                }
            }
        default: break
        }
    }
}

class CommunicatorClient : Communicator
{
    private var observers: [String : CommunicatorObserverValue] = [:]
    
    private var socket: TCPClient?
    private var reader: CommunicatorReader?
    
    private var isConnectedToServer: Bool = false
    
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
        reader?.stop()
        
        socket = nil
        reader = nil
        
        isConnectedToServer = false
        
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
                        observer.value.value?.disconnect(error: "Disconnected")
                    }
                }
            }
        }
    }
}

// Observers
// These methods are not thread safe
// Call them from main thread only
extension CommunicatorClient
{
    public func attachObserver(observer: CommunicatorObserver?, key: String)
    {
        if let obs = observer
        {
            self.observers[key] = CommunicatorObserverValue(obs)
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
        
        self.reader = CommunicatorReader(socket: socket!)
        self.reader?.delegate = self
        self.reader?.begin()
        self.lastPingFromServer = Date()
        
        // Observers notification
        DispatchQueue.main.async {
            for observer in self.observers
            {
                observer.value.value?.beginConnect()
            }
        }
        
        // Timeout
        // If a formal connection is not established in @CommunicatorHostBeginConnectTimeout seconds, terminate connection
        DispatchQueue.main.asyncAfter(deadline: .now() + CommunicatorClientBeginConnectTimeout, execute: { [weak self] in
            if let communicator = self
            {
                if !communicator.isConnectedToServer
                {
                    communicator.socket?.close()
                    communicator.socket = nil
                    communicator.reader = nil
                    communicator.lastPingFromServer = nil
                    
                    // Observers notification
                    DispatchQueue.main.async {
                        for observer in communicator.observers
                        {
                            observer.value.value?.timeout()
                        }
                    }
                }
            }
        })
    }
    
    private func onConnected(parameter: String)
    {
        print("CommunicatorClient: received greetings, sending greetings message to server on \(Date())")
        
        isConnectedToServer = true
        
        // Send greetings BACK to server
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GREETINGS.rawValue, parameter: UserName().value)
        let _ = socket?.send(string: dataToSend!.getData())
        
        // Observers notification
        DispatchQueue.main.async {
            if let socket = self.socket
            {
                let dateConnected = Date()
                let otherPlayerAddress = socket.address
                let otherPlayerName = parameter
                let otherPlayerColor = UIColor.red
                
                for observer in self.observers
                {
                    observer.value.value?.connect(data: CommunicatorInitialConnection(dateConnected: dateConnected, otherPlayerAddress: otherPlayerAddress, otherPlayerName: otherPlayerName, otherPlayerColor: otherPlayerColor))
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
                observer.value.value?.disconnect()
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
                observer.value.value?.disconnect(error: "Disconnected")
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
                observer.value.value?.lostConnectingAttemptingToReconnect()
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
                observer.value.value?.reconnect()
            }
        }
    }
}

// Send message to other end
extension CommunicatorClient
{
    public func sendQuitMessage()
    {
        guard let socket = self.socket else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.QUIT.rawValue)
        let _ = socket.send(string: dataToSend!.getData())
        
        print("CommunicatorClient: sending quit message to server")
    }
    
    public func sendPlaySetupMessage(length: UInt, turnToGo: String)
    {
        guard let socket = self.socket else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.PLAYSETUP.rawValue, parameter1: String(length), parameter2: turnToGo)
        let _ = socket.send(string: dataToSend!.getData())
        
        print("CommunicatorClient: sending play setup message to server")
    }
    
    public func sendAlertPickedGuessWordMessage()
    {
        guard let socket = self.socket else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.PLAYSESSION.rawValue)
        let _ = socket.send(string:dataToSend!.getData())
        
        print("CommunicatorClient: sending alert picked guess word message to server")
    }
    
    public func sendPlaySessionMessage()
    {
        guard let socket = self.socket else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.PLAYSESSION.rawValue)
        let _ = socket.send(string: dataToSend!.getData())
        
        print("CommunicatorClient: sending play session message to server")
    }
    
    func sendGuessMessage(guess: String)
    {
        guard let socket = self.socket else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GAMEGUESS.rawValue, parameter: guess)
        let _ = socket.send(string: dataToSend!.getData())
        
        print("CommunicatorClient: sending guess message to server")
    }
    
    func sendGuessResponseMessage(response: String)
    {
        guard let socket = self.socket else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GAMEGUESSRESPONSE.rawValue, parameter: response)
        let _ = socket.send(string: dataToSend!.getData())
        
        print("CommunicatorClient: sending guess response message to server")
    }
    
    func sendGuessCorrectMessage()
    {
        guard let socket = self.socket else {
            return
        }
        
        let dataToSend = CommunicatorMessage.createWriteMessage(command: CommunicatorCommand.GAMECORRECTGUESS.rawValue, parameter: "")
        let _ = socket.send(string: dataToSend!.getData())
        
        print("CommunicatorClient: sending guess correct message to server")
    }
}

// Reader delegates
extension CommunicatorClient : CommunicatorReaderDelegate
{
    func ping()
    {
        lastPingFromServer = Date()
        
        if lastPingRetryingToConnect
        {
            reconnect()
        }
        
        lastPingRetryingToConnect = false
    }
    
    func pingRefresh()
    {
        // Check if server has been pinging back
        if let lastPingFromServer = self.lastPingFromServer
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
                    onDisconnected()
                    return
                }
                else
                {
                    // Try to reconnect
                    if !lastPingRetryingToConnect
                    {
                        lostConnectionAttemptingToReconnect()
                    }
                }
            }
        }
        else
        {
            print("Communicator last ping date was not initialized properly")
            
            onDisconnected()
            
            return
        }
    }
    
    func greetingsMessageReceived(parameter: String)
    {
        guard self.socket != nil else {
            return
        }
        
        if !isConnectedToServer
        {
            onConnected(parameter: parameter)
        }
    }
    
    func messageReceived(command: String, parameter: String)
    {
        guard let cmd = CommunicatorCommand(rawValue: command) else {
            return
        }
        
        guard self.socket != nil else {
            return
        }
        
        if !isConnectedToServer
        {
            return
        }
        
        switch cmd
        {
        case .QUIT:
            onServerQuit()
        case .PLAYSETUP:
            let parameters = parameter.split(separator: " ")
            
            guard parameters.count == 2 else {
                return
            }
            
            let param1 = parameters.first!.description
            let param2 = parameters[1].description
            
            if let wordLength = UInt(param1)
            {
                // Observers notification
                DispatchQueue.main.async {
                    for observer in self.observers
                    {
                        observer.value.value?.opponentPickedPlaySetup(guessWordLength: wordLength, turnToGo: param2)
                    }
                }
            }
        case .PLAYSESSION:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.opponentPickedPlaySession()
                }
            }
        case .GAMEGUESS:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.opponentGuess(guess: parameter)
                }
            }
        case .GAMEGUESSRESPONSE:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.guessResponse(response: parameter)
                }
            }
        case .GAMECORRECTGUESS:
            // Observers notification
            DispatchQueue.main.async {
                for observer in self.observers
                {
                    observer.value.value?.correctGuess()
                }
            }
        default: break
        }
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
