//
//  Models.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 4.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

struct GuessCharacter
{
    let value : Character
    
    init(_ value: Character)
    {
        self.value = value
    }
    
    static func ==(left: GuessCharacter, right: GuessCharacter) -> Bool
    {
        return left.value == right.value
    }
}

struct GuessCharacterResult
{
    let guessedValue : Bool
    let guessedPosition : Bool
    
    init(guessedValue: Bool, guessedPosition: Bool)
    {
        self.guessedValue = guessedValue
        self.guessedPosition = guessedPosition
    }
    
    func isCow() -> Bool
    {
        return guessedValue && !guessedPosition
    }
    
    func isBull() -> Bool
    {
        return guessedValue && guessedPosition
    }
}

struct GuessResult
{
    let guessWordNumberOfCharacters : UInt
    let characterGuesses : [GuessCharacterResult]
    
    init(guessWordNumberOfCharacters: UInt, characterGuesses: [GuessCharacterResult])
    {
        self.guessWordNumberOfCharacters = guessWordNumberOfCharacters
        self.characterGuesses = characterGuesses
    }
    
    func hasSuccessfullyGuessed() -> Bool
    {
        var bulls = 0
        
        for e in 0..<characterGuesses.count
        {
            if characterGuesses[e].isBull()
            {
                bulls += 1
            }
        }
        
        return bulls == guessWordNumberOfCharacters
    }
}

struct GameSession
{
    let firstToGo : Bool
    
    private var gameTurn : UInt
    
    let guessWord : [GuessCharacter]
    let guessWordNumberOfCharacters : UInt
    
    private var myGuesses : [GuessResult]
    private var opponentGuesses : [GuessResult]
    
    init(firstToGo: Bool, guessWord: [GuessCharacter])
    {
        self.firstToGo = firstToGo
        
        self.gameTurn = 1
        
        self.guessWord = guessWord
        self.guessWordNumberOfCharacters = UInt(guessWord.count)
        
        self.myGuesses = []
        self.opponentGuesses = []
    }
    
    func isMyTurn() -> Bool
    {
        if firstToGo
        {
            return gameTurn % 2 != 0
        }
        else
        {
            return gameTurn % 2 == 0
        }
    }
    
    func isOpponentTurn() -> Bool
    {
        return !isMyTurn()
    }
    
    mutating func IAmIsGuessing(guessCharacters: String) throws -> GuessResult
    {
        guard isMyTurn() else
        {
            throw GameError.badLogic_WrongTurn
        }
        
        gameTurn += 1
        
        var characters: [GuessCharacter] = []
        
        var guessCharacters : [GuessCharacterResult] = []
        
        let guessResult: GuessResult = GuessResult(guessWordNumberOfCharacters: guessWordNumberOfCharacters, characterGuesses: guessCharacters)
        
        myGuesses.append(guessResult)
        
        return guessResult
    }
    
    mutating func opponentIsGuessing(guessCharacters: String) throws -> GuessResult
    {
        guard isOpponentTurn() else
        {
            throw GameError.badLogic_WrongTurn
        }
        
        gameTurn += 1
        
        var characters: [GuessCharacter] = []
        
        var guessCharacters : [GuessCharacterResult] = []
        
        let guessResult: GuessResult = GuessResult(guessWordNumberOfCharacters: guessWordNumberOfCharacters, characterGuesses: guessCharacters)
        
        opponentGuesses.append(guessResult)
        
        return guessResult
    }
    
    func getGuessLog(myName: String, opponentName: String, printTurnNumbers: Bool, sortByLate: Bool) -> String
    {
        return ""
    }
}
