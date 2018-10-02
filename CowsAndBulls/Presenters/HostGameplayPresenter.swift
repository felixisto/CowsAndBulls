//
//  HostGameplayPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol HostGameplayPresenterDelegate : class
{
    
}

class HostGameplayPresenter
{
    weak var delegate : HostGameplayViewDelegate?
    
    required init()
    {
        
    }
}

extension HostGameplayPresenter : HostGameplayPresenterDelegate
{
    
}
