//
//  CommunicatorCommands.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 4.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

let CommunicatorCommandsParemeterWhitespaceReplacement = "%20"

enum CommunicatorCommand : String
{
    case GREETINGS = "GREETINGS"
    case QUIT = "QUIT"
    case CHAT = "CHAT"
    case PING = "PING"
    
    case PLAYSETUP = "PLAYSETUP"
    case PLAYSESSION = "PLAYSESSION"
    
    case GAMEGUESS = "GAMEGUESS"
    case GAMEGUESSRESPONSE = "GAMEGUESSRESPONSE"
    case GAMECORRECTGUESS = "GAMECORRECTGUESS"
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
        let parameter = text.replacingOccurrences(of: " ", with: CommunicatorCommandsParemeterWhitespaceReplacement)
        
        var string = String("\(command.rawValue) \(parameter)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructQuitMessage() -> String
    {
        var string = String("\(CommunicatorCommand.QUIT.rawValue)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructPlaySetupMessage(length: UInt, turnToGo: String) -> String
    {
        let parameter = turnToGo.replacingOccurrences(of: " ", with: CommunicatorCommandsParemeterWhitespaceReplacement)
        
        var string = String("\(CommunicatorCommand.PLAYSETUP.rawValue) \(length) \(parameter)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructPickedGuessWordMessage() -> String
    {
        var string = String("\(CommunicatorCommand.PLAYSESSION.rawValue)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructPlaySessionMessage() -> String
    {
        var string = String("\(CommunicatorCommand.PLAYSESSION.rawValue)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructGameGuessMessage(guess: String) -> String
    {
        let parameter = guess.replacingOccurrences(of: " ", with: CommunicatorCommandsParemeterWhitespaceReplacement)
        
        var string = String("\(CommunicatorCommand.GAMEGUESS.rawValue) \(parameter)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructGameGuessResponseMessage(response: String) -> String
    {
        let parameter = response.replacingOccurrences(of: " ", with: CommunicatorCommandsParemeterWhitespaceReplacement)
        
        var string = String("\(CommunicatorCommand.GAMEGUESSRESPONSE.rawValue) \(parameter)")
        
        string.append(CommunicatorMessageEndingTag)
        
        return string
    }
    
    static func constructGameCorrectGuessMessage() -> String
    {
        var string = String("\(CommunicatorCommand.GAMECORRECTGUESS.rawValue)")
        
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
    
    static func extractFirstParameter(command: CommunicatorCommand, message: String) -> String?
    {
        let split = message.split(separator: " ")
        
        if split.count <= 1
        {
            return nil
        }
        
        let second = split[1]
        
        return second.replacingOccurrences(of: CommunicatorCommandsParemeterWhitespaceReplacement, with: " ")
    }
    
    static func extractSecondParameter(command: CommunicatorCommand, message: String) -> String?
    {
        let split = message.split(separator: " ")
        
        if split.count <= 2
        {
            return nil
        }
        
        let third = split[2]
        
        return third.replacingOccurrences(of: CommunicatorCommandsParemeterWhitespaceReplacement, with: " ")
    }
}
