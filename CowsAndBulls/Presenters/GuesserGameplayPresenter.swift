//
//  GuesserGameplayPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol GuesserGameplayPresenterDelegate : class
{
    
}

class GuesserGameplayPresenter
{
    weak var delegate : GuesserGameplayViewDelegate?
    
    required init()
    {
        
    }
}

extension GuesserGameplayPresenter : GuesserGameplayPresenterDelegate
{
    
}
