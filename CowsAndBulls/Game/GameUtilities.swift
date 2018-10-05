//
//  GameUtilities.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 5.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

struct GameTurnRandom
{
    static func generateTurnValue(currentTurnValue: UInt, opponentTurnValue: UInt) -> UInt
    {
        if currentTurnValue == 0 && opponentTurnValue == 0
        {
            return UInt.random(in: 0...100000)
        }
        
        return 0
    }
}
