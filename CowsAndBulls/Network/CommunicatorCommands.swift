//
//  CommunicatorCommands.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 4.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

enum CommunicatorCommand : String
{
    case GREETINGS = "GREETINGS"
    case QUIT = "QUIT"
    case CHAT = "CHAT"
    case PING = "PING"
}

struct CommunicatorCommands
{
    static func deviceName() -> String
    {
        if UIDevice.current.name.indices.contains(UIDevice.current.name.firstIndex(of: " ")!)
        {
            return UIDevice.current.name.split(separator: " ").first!.description
        }
        
        return UIDevice.current.name
    }
    
    static func constructGreetingsMessage() -> String
    {
        var string = String("\(CommunicatorCommand.GREETINGS.rawValue) \(deviceName())")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructPingMessage() -> String
    {
        var string = String("\(CommunicatorCommand.PING.rawValue)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructMessage(_ command: CommunicatorCommand, text: String) -> String
    {
        var string = String("\(command.rawValue) \(text)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructQuitMessage() -> String
    {
        var string = String("\(CommunicatorCommand.QUIT.rawValue)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func extractCommand(fromMessage message: String) -> CommunicatorCommand?
    {
        guard let first = message.split(separator: " ").first else {
            return nil
        }
        
        return CommunicatorCommand(rawValue: String(first))
    }
    
    static func extractParameter(command: CommunicatorCommand, message: String) -> String?
    {
        let split = message.split(separator: " ")
        
        if split.count <= 1
        {
            return nil
        }
        
        let second = split[1]
        
        return String(second)
    }
}
