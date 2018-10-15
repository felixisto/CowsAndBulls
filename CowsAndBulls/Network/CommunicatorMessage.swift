//
//  CommunicatorMessage.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 11.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

let CommunicatorMessageLength : UInt8 = 50
let CommunicatorMessageCommandLength : UInt8 = 5
let CommunicatorMessageParameterLength : UInt8 = CommunicatorMessageLength-CommunicatorMessageCommandLength

let CommunicatorMessageFillerCharacter = "\t"

struct CommunicatorMessage
{
    let commandLength: UInt8
    let parameterLength: UInt8
    
    private var data: String
    
    private init(commandLength: UInt8, parameterLength: UInt8)
    {
        self.commandLength = commandLength
        self.parameterLength = parameterLength
        self.data = ""
    }
    
    private init(parameterLength: UInt8, command: String, parameter: String)
    {
        self.commandLength = UInt8(command.count)
        self.parameterLength = parameterLength
        
        self.data = command
        self.data.append(contentsOf: parameter)
    }
    
    func isFullyWritten() -> Bool
    {
        return data.count == CommunicatorMessageLength
    }
    
    func getCommand() -> String
    {
        return data[..<String.Index(encodedOffset: Int(commandLength))].description
    }
    
    func getParameter() -> String
    {
        let parameter = data[String.Index(encodedOffset: Int(commandLength))...].description
        
        return parameter.replacingOccurrences(of: CommunicatorMessageFillerCharacter, with: "")
    }
    
    func getData() -> String
    {
        return data
    }
    
    mutating func clear()
    {
        data = ""
    }
    
    mutating func append(string: String)
    {
        if string.count == 0
        {
            return
        }
        
        var str = string
        
        while data.count < CommunicatorMessageLength
        {
            data.append(str.first!)
            
            str = str[String.Index(encodedOffset: 1)...].description
            
            if str.count == 0
            {
                return
            }
        }
    }
    
    mutating func fillMessage()
    {
        while data.count < CommunicatorMessageLength
        {
            data.append(contentsOf: CommunicatorMessageFillerCharacter)
        }
    }
}

// Factories
extension CommunicatorMessage
{
    static func createBufferMessage(commandLength: UInt8=CommunicatorMessageCommandLength, parameterLength: UInt8=CommunicatorMessageParameterLength) -> CommunicatorMessage
    {
        return CommunicatorMessage(commandLength: commandLength, parameterLength: parameterLength)
    }
    
    static func createWriteMessage(commandLength: UInt8=CommunicatorMessageCommandLength, parameterLength: UInt8=CommunicatorMessageParameterLength, command: String, parameter: String="") -> CommunicatorMessage?
    {
        guard command.count == commandLength else {
            return nil
        }
        
        guard parameter.count <= parameterLength else {
            return nil
        }
        
        var cmd = CommunicatorMessage(commandLength: commandLength, parameterLength: parameterLength)
        
        cmd.data = command
        cmd.data.append(contentsOf: parameter)
        
        cmd.fillMessage()
        
        return cmd
    }
    
    static func createWriteMessage(commandLength: UInt8=CommunicatorMessageCommandLength, parameterLength: UInt8=CommunicatorMessageParameterLength, command: String, parameter1: String, parameter2: String) -> CommunicatorMessage?
    {
        guard command.count == commandLength else {
            return nil
        }
        
        guard parameter1.count + parameter2.count + 1 <= parameterLength else {
            return nil
        }
        
        var cmd = CommunicatorMessage(commandLength: commandLength, parameterLength: parameterLength)
        
        cmd.data = command
        cmd.data.append(contentsOf: parameter1)
        cmd.data.append(contentsOf: " ")
        cmd.data.append(contentsOf: parameter2)
        
        cmd.fillMessage()
        
        return cmd
    }
}
