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

let CommunicatorMessageNullCharacterValue = 65533

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
    
    mutating func append(buffer: [UInt8])
    {
        guard let stringData = String(bytes: buffer, encoding: .utf8) else {
            return
        }
        
        for e in 0..<stringData.count
        {
            // Data must start with alphanumeric or _
            if data.count == 0
            {
                let c = stringData.unicodeScalars[String.Index(encodedOffset: e)]
                
                if (!NSCharacterSet.alphanumerics.contains(c))
                {
                    continue
                }
            }
            
            let c = stringData[String.Index(encodedOffset: e)]
            
            // Do not add NULL CHARACTERS
            if c.unicodeScalars.first!.value != CommunicatorMessageNullCharacterValue
            {
                data.append(c)
            }
            
            if isFullyWritten()
            {
                break
            }
        }
        
        for _ in 0..<buffer.count-stringData.count
        {
            data.append(contentsOf: CommunicatorMessageFillerCharacter)
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
