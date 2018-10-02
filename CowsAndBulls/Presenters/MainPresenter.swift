//
//  MainPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol MainPresenterDelegate : class
{
    
}

class MainPresenter
{
    weak var delegate : MainViewDelegate?
    
    required init()
    {
        
    }
}

extension MainPresenter : MainPresenterDelegate
{
    
}
