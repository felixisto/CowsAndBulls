//
//  CommunicatorCommands.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 4.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

enum CommunicatorCommands : String
{
    case PING = "PING_"
    case GREETINGS = "GREET"
    case QUIT = "QUIT_"
    case CHAT = "CHAT_"
    
    case PLAYSETUP = "SETUP"
    case READYTOPLAY = "RPLAY"
    
    case GAMEGUESS = "GUESS"
    case GAMEGUESSRESPONSE = "GRESP"
    case GAMECORRECTGUESS = "GCORR"
    
    case GAMENEXT = "GAMNX"
}
