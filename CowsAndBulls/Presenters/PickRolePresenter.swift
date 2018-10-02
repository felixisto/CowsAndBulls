//
//  PickRolePresenter.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 2.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol PickRolePresenterDelegate : class
{
    
}

class PickRolePresenter
{
    weak var delegate : PickRoleViewDelegate?
    
    required init()
    {
        
    }
}

extension PickRolePresenter : PickRolePresenterDelegate
{
    
}
