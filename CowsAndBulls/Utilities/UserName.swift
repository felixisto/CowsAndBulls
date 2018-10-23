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
    let value : String
    
    init()
    {
        if let n = UIDevice.current.name.split(separator: " ").first
        {
            if n.description.count <= 9
            {
                self.value = n.description
            }
            else
            {
                self.value = n.description[..<String.Index(encodedOffset: 9)].description
            }
        }
        else
        {
            self.value = "Unknown"
        }
    }
}
