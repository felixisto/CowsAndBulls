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
        for e in 0..<string.count
        {
            data.append(string[String.Index(encodedOffset: e)])
            
            if isFullyWritten()
            {
                return
            }
        }
    }
    
    mutating func fillMessage()
    {
        while !isFullyWritten()
        {
            data.append(contentsOf: CommunicatorMessageFillerCharacter)
        }
    }
}

// Factories
extension CommunicatorMessage
{
    static func createReadMessage() -> CommunicatorMessage
    {
        return CommunicatorMessage(commandLength: CommunicatorMessageCommandLength, parameterLength: CommunicatorMessageParameterLength)
    }
    
    static func createWriteMessage(command: String, parameter: String="") -> CommunicatorMessage?
    {
        guard command.count == CommunicatorMessageCommandLength else
        {
            return nil
        }
        
        var cmd = CommunicatorMessage(parameterLength: CommunicatorMessageParameterLength, command: command, parameter: parameter)
        
        cmd.fillMessage()
        
        return cmd
    }
    
    static func createWriteMessage(command: String, parameter1: String, parameter2: String) -> CommunicatorMessage?
    {
        guard command.count == CommunicatorMessageCommandLength else
        {
            return nil
        }
        
        var cmd = CommunicatorMessage(parameterLength: CommunicatorMessageParameterLength, command: command, parameter: String("\(parameter1) \(parameter2)"))
        
        cmd.fillMessage()
        
        return cmd
    }
}
