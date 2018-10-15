//
//  UserName.swift
//  CowsAndBulls
//
//  Created by Kristiyan Butev on 15.10.18.
//  Copyright © 2018 Kristiyan Butev. All rights reserved.
//

import UIKit

struct UserName
{
    let name : String
    
    init()
    {
        if let n = UIDevice.current.name.split(separator: " ").first
        {
            self.name = n.description
        }
        else
        {
            self.name = "Unknown"
        }
    }
}
