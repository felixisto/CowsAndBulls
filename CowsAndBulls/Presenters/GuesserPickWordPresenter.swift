//
//  GuesserPickWordPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol GuesserPickWordPresenterDelegate : class
{
    
}

class GuesserPickWordPresenter
{
    weak var delegate : GuesserPickWordViewDelegate?
    
    required init()
    {
        
    }
}

extension GuesserPickWordPresenter : GuesserPickWordPresenterDelegate
{
    
}
