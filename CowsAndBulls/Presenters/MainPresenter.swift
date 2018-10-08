//
//  MainPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

enum MainPresenterConnectionStatus
{
    case none
    case quit
    case disconnected
}

protocol MainPresenterDelegate : class
{
    
}

class MainPresenter
{
    weak var delegate : MainViewDelegate?
    
    let initialConnectionStatus : MainPresenterConnectionStatus
    
    required init(initialConnectionStatus : MainPresenterConnectionStatus = .none)
    {
        self.initialConnectionStatus = initialConnectionStatus
    }
}

extension MainPresenter : MainPresenterDelegate
{
    
}
