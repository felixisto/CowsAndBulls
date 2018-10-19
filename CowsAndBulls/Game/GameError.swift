//
//  GameErrord.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 5.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

enum GameError : Error
{
    case badLogic
    case badLogic_GameIsOver
    case badLogic_WrongTurn
    case badLogic_InvalidGuessCharacterLength
}
