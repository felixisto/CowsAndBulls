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
    let char : Character
    let position : UInt
    
    init(char value: Character, position: UInt)
    {
        self.char = value
        self.position = position
    }
    
    static func stringToGuessCharacters(_ string: String) -> [GuessCharacter]
    {
        var guessCharacters : [GuessCharacter] = []
        
        for e in 0..<string.count
        {
            guessCharacters.append(GuessCharacter(char: string[String.Index(encodedOffset: e)], position: UInt(e)))
        }
        
        return guessCharacters
    }
    
    static func guessCharactersToString(_ guessCharacters: [GuessCharacter]) -> String
    {
        var string = ""
        
        for e in 0..<guessCharacters.count
        {
            string.append(guessCharacters[e].char)
        }
        
        return string
    }
    
    static func guessResult(guessWord guessWordConstant: [GuessCharacter], guess guessConstant: [GuessCharacter]) -> GuessResult
    {
        var characterGuesses : [GuessCharacterResult] = []
        
        var guessWord = guessWordConstant
        var guess = guessConstant
        
        while guessWord.count > 0
        {
            let guessWordChar = guessWord.first!
            
            var bestComparisonResultForThisChar = GuessCharacterResult(guessedValue: false, guessedPosition: false)
            var bestComparisonResultIndex = -1
            
            for i in 0..<guess.count
            {
                let guessChar = guess[i]
                
                let comparisonResult = GuessCharacterResult(a: guessWordChar, b: guessChar)
                
                if comparisonResult.isCow() || comparisonResult.isBull()
                {
                    if bestComparisonResultIndex == -1
                    {
                        bestComparisonResultForThisChar = comparisonResult
                        bestComparisonResultIndex = i
                    }
                    else
                    {
                        if bestComparisonResultForThisChar.isCow() && comparisonResult.isBull()
                        {
                            bestComparisonResultForThisChar = comparisonResult
                            bestComparisonResultIndex = i
                        }
                    }
                }
            }
            
            characterGuesses.append(bestComparisonResultForThisChar)
            
            if bestComparisonResultIndex != -1
            {
                guess.remove(at: bestComparisonResultIndex)
            }
            
            guessWord.remove(at: 0)
        }
        
        return GuessResult(guessWordLength: UInt(guessWordConstant.count), guess: guessCharactersToString(guessConstant), characterGuesses: characterGuesses)
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
    
    init(a: GuessCharacter, b: GuessCharacter)
    {
        self.guessedValue = a.char == b.char
        self.guessedPosition = a.position == b.position
    }
    
    func isCow() -> Bool
    {
        return guessedValue && !guessedPosition
    }
    
    func isBull() -> Bool
    {
        return guessedValue && guessedPosition
    }
    
    static func arrayToString(guessWordLength: UInt, array: [GuessCharacterResult]) -> String
    {
        var bulls = 0
        var cows = 0
        
        for c in array
        {
            if c.isCow()
            {
                cows += 1
            }
            
            if c.isBull()
            {
                bulls += 1
            }
        }
        
        if bulls == guessWordLength
        {
            return "Correct guess!"
        }
        
        if bulls == 0 && cows != 0
        {
           return String("\(cows) cows")
        }
        
        if cows == 0 && bulls != 0
        {
            return String("\(bulls) bulls")
        }
        
        if cows == 0 && bulls == 0
        {
            return "nothing";
        }
        
        return String("\(cows) cows, \(bulls) bulls")
    }
}

struct GuessResult
{
    let guessWordLength: UInt
    let message: String
    let messageWithGuess: String
    let characterGuesses : [GuessCharacterResult]
    
    init(guessWordLength: UInt, guess: String, characterGuesses: [GuessCharacterResult])
    {
        self.guessWordLength = guessWordLength
        self.message = GuessCharacterResult.arrayToString(guessWordLength: guessWordLength, array: characterGuesses)
        self.messageWithGuess = String("guessed \(guess), that's \(message)!")
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
        
        return bulls == guessWordLength
    }
}

struct GameSession
{
    static let YOU_LABEL = "You"
    static let OPPONENT_LABEL = "Opponent"
    
    let firstToGo : Bool
    
    private var gameTurn : UInt
    
    let guessWordAsString : String
    let guessWord : [GuessCharacter]
    let guessWordNumberOfCharacters : UInt
    
    private var gameIsOver: Bool
    
    private var log: String
    
    private var lastGuessAttempt: String
    
    init(firstToGo: Bool, guessWord: String)
    {
        self.firstToGo = firstToGo
        
        self.gameTurn = 1
        
        self.guessWordAsString = guessWord
        
        self.guessWord = GuessCharacter.stringToGuessCharacters(guessWord)
        self.guessWordNumberOfCharacters = UInt(guessWord.count)
        
        self.log = ""
        
        self.gameIsOver = false
        
        self.lastGuessAttempt = ""
    }
    
    func getGameTurn() -> UInt
    {
        return gameTurn
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
    
    func getLog(opponentName: String) -> String
    {
        return log.replacingOccurrences(of: GameSession.OPPONENT_LABEL, with: opponentName)
    }
    
    mutating func endGame() throws
    {
        guard !gameIsOver else
        {
            throw GameError.badLogic_GameIsOver
        }
        
        gameIsOver = true
    }
    
    mutating func guessAttempt(guess: String)
    {
        lastGuessAttempt = guess
    }
    
    mutating func opponentGuessResponse(response: String) throws
    {
        guard !gameIsOver else
        {
            throw GameError.badLogic_GameIsOver
        }
        
        guard isMyTurn() else
        {
            throw GameError.badLogic_WrongTurn
        }
        
        gameTurn += 1
        
        addGuessTextToLog(String("\(GameSession.YOU_LABEL) \(response)"))
    }
    
    mutating func opponentIsGuessing(guess guessCharactersAsString: String) throws -> GuessResult
    {
        guard !gameIsOver else
        {
            throw GameError.badLogic_GameIsOver
        }
        
        guard isOpponentTurn() else
        {
            throw GameError.badLogic_WrongTurn
        }
        
        guard guessCharactersAsString.count == guessWordNumberOfCharacters else
        {
            throw GameError.badLogic_InvalidGuessCharacterLength
        }
        
        gameTurn += 1
        
        let guessResult = GuessCharacter.guessResult(guessWord: guessWord, guess: GuessCharacter.stringToGuessCharacters(guessCharactersAsString))
        
        addGuessTextToLog(String("\(GameSession.OPPONENT_LABEL) \(guessResult.messageWithGuess)"))
        
        if guessResult.hasSuccessfullyGuessed()
        {
            gameIsOver = true
        }
        
        return guessResult
    }
    
    mutating public func addMyChatTextToLog(_ string: String)
    {
        var temp = String("\(GameSession.YOU_LABEL): \(string)\n")
        temp.append(log)
        log = temp
    }
    
    mutating public func addOpponentChatTextToLog(_ string: String)
    {
        var temp = String("\(GameSession.OPPONENT_LABEL): \(string)\n")
        temp.append(log)
        log = temp
    }
    
    mutating private func addGuessTextToLog(_ string: String)
    {
        var temp = String("\(gameTurn-1). \(string)\n")
        temp.append(log)
        log = temp
    }
    
    func getLastGuessAttempt() -> String
    {
        return lastGuessAttempt
    }
}

enum GameTurn : String
{
    case first = "First"
    case second = "Second"
    
    func nextTurn() -> GameTurn
    {
        if self == .first
        {
            return .second
        }
        
        return .first
    }
}
