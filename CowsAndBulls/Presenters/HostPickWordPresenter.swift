//
//  HostPickWordPresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol HostPickWordPresenterDelegate : class
{
    
}

class HostPickWordPresenter
{
    weak var delegate : HostPickWordViewDelegate?
    
    required init()
    {
        
    }
}

extension HostPickWordPresenter : HostPickWordPresenterDelegate
{
    
}
