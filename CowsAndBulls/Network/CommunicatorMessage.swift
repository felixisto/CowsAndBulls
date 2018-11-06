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
        var param = parameter
        var paramLength = parameterLength
        
        if paramLength <= 0
        {
            paramLength = 0
            param = ""
        }
        
        self.commandLength = UInt8(command.count)
        self.parameterLength = paramLength
        
        self.data = command
        
        if param.count > paramLength
        {
            param = param[..<String.Index(encodedOffset: Int(paramLength))].description
        }
        
        self.data.append(contentsOf: param)
    }
    
    func isFullyWritten() -> Bool
    {
        return getDataBytesCount() >= CommunicatorMessageLength
    }
    
    func getCommand() -> String
    {
        return data[..<String.Index(encodedOffset: Int(commandLength))].description
    }
    
    private func getParameterWithFillerChars() -> String
    {
        var byteArray = [UInt8]()
        
        for (index, char) in data.utf8.enumerated()
        {
            if index < commandLength
            {
                continue
            }
            
            byteArray += [char]
            
            if index == CommunicatorMessageLength
            {
                break
            }
        }
        
        guard let parameter = String(bytes: byteArray, encoding: .utf8) else {
            return ""
        }
        
        return parameter
    }
    
    func getParameter() -> String
    {
        return getParameterWithFillerChars().replacingOccurrences(of: CommunicatorMessageFillerCharacter, with: "")
    }
    
    func getData() -> String
    {
        return data
    }
    
    func getDataBytesCount() -> Int
    {
        return data.utf8.count
    }
    
    mutating func clearFirstFilledMessage()
    {
        if getDataBytesCount() > CommunicatorMessageLength
        {
            let command = getCommand()
            let parameter = getParameterWithFillerChars()
            let beginIndex = String.Index(encodedOffset: command.count + parameter.count)
            
            data = data[beginIndex...].description
        }
        else
        {
            data = ""
        }
    }
    
    mutating func append(buffer: [UInt8])
    {
        guard let stringData = String(bytes: buffer, encoding: .utf8) else {
            return
        }
        
        data.append(stringData)
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
